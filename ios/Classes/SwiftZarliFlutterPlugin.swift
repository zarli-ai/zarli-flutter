import Flutter
import UIKit
import ZarliSDKSwift

public class SwiftZarliFlutterPlugin: NSObject, FlutterPlugin {
    
    private let channel: FlutterMethodChannel
    
    // Map adObjectId -> Ad Wrapper
    private var ads: [String: Any] = [:]
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zarli_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftZarliFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "loadInterstitialAd":
            handleLoadInterstitialAd(call, result: result)
        case "showInterstitialAd":
            handleShowInterstitialAd(call, result: result)
        case "loadRewardedAd":
            handleLoadRewardedAd(call, result: result)
        case "showRewardedAd":
            handleShowRewardedAd(call, result: result)
        case "disposeAd":
            handleDisposeAd(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var apiKey: String?
        
        if let args = call.arguments as? [String: Any] {
            apiKey = args["apiKey"] as? String
        }
        
        // Fallback to Info.plist
        if apiKey == nil {
            apiKey = Bundle.main.object(forInfoDictionaryKey: "ZarliAPIKey") as? String
        }
        
        guard let finalApiKey = apiKey, !finalApiKey.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "API Key is required. Pass it in initialize() or set 'ZarliAPIKey' in Info.plist", details: nil))
            return
        }
        
        let config = ZarliConfiguration(apiKey: finalApiKey)
        ZarliSDK.shared.initialize(configuration: config) { success in
            // We can return success even if SDK was already initialized
            result(nil)
        }
    }
    
    // MARK: - Generic Helpers
    
    private func getTopViewController() -> UIViewController? {
        // Try to find the active window scene
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            ?? scenes.first(where: { $0.activationState == .foregroundInactive }) as? UIWindowScene
        
        let window = windowScene?.windows.first(where: { $0.isKeyWindow })
            ?? UIApplication.shared.keyWindow
            
        var topController = window?.rootViewController
        
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        
        return topController
    }
    
    private func handleDisposeAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adObjectId = args["adObjectId"] as? String else {
            result(nil) // Be forgiving
            return
        }
        ads.removeValue(forKey: adObjectId)
        result(nil)
    }
    
    // MARK: - Interstitial
    
    private func handleLoadInterstitialAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String,
              let adObjectId = args["adObjectId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adUnitId and adObjectId are required", details: nil))
            return
        }
        
        let adWrapper = FlutterInterstitialAd(adUnitId: adUnitId, adObjectId: adObjectId, channel: channel)
        ads[adObjectId] = adWrapper
        adWrapper.load()
        
        result(nil)
    }
    
    private func handleShowInterstitialAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adObjectId = args["adObjectId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adObjectId is required", details: nil))
            return
        }
        
        guard let adWrapper = ads[adObjectId] as? FlutterInterstitialAd else {
            result(FlutterError(code: "AD_NOT_FOUND", message: "Ad not found for objectId: \(adObjectId)", details: nil))
            return
        }
        
        if let rootVC = getTopViewController() {
            if adWrapper.isReady {
                adWrapper.show(from: rootVC)
                result(nil)
            } else {
                result(FlutterError(code: "AD_NOT_READY", message: "Ad is not ready", details: nil))
            }
        } else {
            result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
        }
    }
    
    // MARK: - Rewarded
    
    private func handleLoadRewardedAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String,
              let adObjectId = args["adObjectId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adUnitId and adObjectId are required", details: nil))
            return
        }
        
        let adWrapper = FlutterRewardedAd(adUnitId: adUnitId, adObjectId: adObjectId, channel: channel)
        ads[adObjectId] = adWrapper
        adWrapper.load()
        
        result(nil)
    }
    
    private func handleShowRewardedAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adObjectId = args["adObjectId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adObjectId is required", details: nil))
            return
        }
        
        guard let adWrapper = ads[adObjectId] as? FlutterRewardedAd else {
            result(FlutterError(code: "AD_NOT_FOUND", message: "Ad not found for objectId: \(adObjectId)", details: nil))
            return
        }
        
        if let rootVC = getTopViewController() {
            if adWrapper.isReady {
                adWrapper.show(from: rootVC)
                result(nil)
            } else {
                result(FlutterError(code: "AD_NOT_READY", message: "Ad is not ready", details: nil))
            }
        } else {
            result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
        }
    }
}

// MARK: - Ad Wrappers

class FlutterInterstitialAd: NSObject, ZarliInterstitialAdDelegate {
    let adUnitId: String
    let adObjectId: String
    let channel: FlutterMethodChannel
    let ad: ZarliInterstitialAd
    
    var isReady: Bool {
        return ad.isReady
    }
    
    init(adUnitId: String, adObjectId: String, channel: FlutterMethodChannel) {
        self.adUnitId = adUnitId
        self.adObjectId = adObjectId
        self.channel = channel
        self.ad = ZarliInterstitialAd(adUnitId: adUnitId)
        super.init()
        self.ad.delegate = self
    }
    
    func load() {
        ad.load()
    }
    
    func show(from viewController: UIViewController) {
        ad.show(from: viewController)
    }
    
    // Delegate Methods
    func adDidLoad(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdLoaded", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        channel.invokeMethod("onInterstitialAdFailedToLoad", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId, "error": error.localizedDescription])
    }
    
    func adDidShow(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdShowed", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func adDidDismiss(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdDismissed", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func adDidClick(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdClicked", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
}

class FlutterRewardedAd: NSObject, ZarliRewardedAdDelegate {
    let adUnitId: String
    let adObjectId: String
    let channel: FlutterMethodChannel
    let ad: ZarliRewardedAd
    
    var isReady: Bool {
        return ad.isReady
    }
    
    init(adUnitId: String, adObjectId: String, channel: FlutterMethodChannel) {
        self.adUnitId = adUnitId
        self.adObjectId = adObjectId
        self.channel = channel
        self.ad = ZarliRewardedAd(adUnitId: adUnitId)
        super.init()
        self.ad.delegate = self
    }
    
    func load() {
        ad.load()
    }
    
    func show(from viewController: UIViewController) {
        ad.show(from: viewController)
    }
    
    // Delegate Methods
    func adDidLoad(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdLoaded", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func ad(_ ad: ZarliRewardedAd, didFailToLoad error: Error) {
        channel.invokeMethod("onRewardedAdFailedToLoad", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId, "error": error.localizedDescription])
    }
    
    func adDidShow(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdShowed", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func adDidDismiss(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdDismissed", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func adDidClick(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdClicked", arguments: ["adObjectId": adObjectId, "adUnitId": adUnitId])
    }
    
    func ad(_ ad: ZarliRewardedAd, didEarnReward reward: ZarliReward) {
        channel.invokeMethod("onRewardedAdEarnedReward", arguments: [
            "adObjectId": adObjectId,
            "adUnitId": adUnitId,
            "amount": reward.amount,
            "type": reward.type
        ])
    }
}
