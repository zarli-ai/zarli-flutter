import Flutter
import UIKit
import ZarliSDKSwift

public class SwiftZarliFlutterPlugin: NSObject, FlutterPlugin {
    
    private let channel: FlutterMethodChannel
    
    // Keep strong references to ads
    private var interstitialAds: [String: ZarliInterstitialAd] = [:]
    private var rewardedAds: [String: ZarliRewardedAd] = [:]
    
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "API Key is required", details: nil))
            return
        }
        
        let config = ZarliConfiguration(apiKey: apiKey)
        ZarliSDK.shared.initialize(configuration: config) { success in
            result(nil)
        }
    }
    
    // MARK: - Interstitial
    
    private func handleLoadInterstitialAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adUnitId is required", details: nil))
            return
        }
        
        let ad = ZarliInterstitialAd(adUnitId: adUnitId)
        ad.delegate = self
        interstitialAds[adUnitId] = ad
        ad.load()
        
        result(nil)
    }
    
    private func handleShowInterstitialAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adUnitId is required", details: nil))
            return
        }
        
        if let ad = interstitialAds[adUnitId], ad.isReady {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                ad.show(from: rootVC)
                result(nil)
            } else {
                result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
            }
        } else {
            result(FlutterError(code: "AD_NOT_READY", message: "Ad is not ready", details: nil))
        }
    }
    
    // MARK: - Rewarded
    
    private func handleLoadRewardedAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adUnitId is required", details: nil))
            return
        }
        
        let ad = ZarliRewardedAd(adUnitId: adUnitId)
        ad.delegate = self
        rewardedAds[adUnitId] = ad
        ad.load()
        
        result(nil)
    }
    
    private func handleShowRewardedAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "adUnitId is required", details: nil))
            return
        }
        
        if let ad = rewardedAds[adUnitId], ad.isReady {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                ad.show(from: rootVC)
                result(nil)
            } else {
                result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
            }
        } else {
            result(FlutterError(code: "AD_NOT_READY", message: "Ad is not ready", details: nil))
        }
    }
}

// MARK: - Interstitial Delegate

extension SwiftZarliFlutterPlugin: ZarliInterstitialAdDelegate {
    public func adDidLoad(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdLoaded", arguments: ["adUnitId": ad.adUnitId])
    }
    
    public func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        channel.invokeMethod("onInterstitialAdFailedToLoad", arguments: ["adUnitId": ad.adUnitId, "error": error.localizedDescription])
        // Clean up
        interstitialAds.removeValue(forKey: ad.adUnitId)
    }
    
    public func adDidShow(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdShowed", arguments: ["adUnitId": ad.adUnitId])
    }
    
    public func adDidDismiss(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdDismissed", arguments: ["adUnitId": ad.adUnitId])
        // Clean up
        interstitialAds.removeValue(forKey: ad.adUnitId)
    }
    
    public func adDidClick(_ ad: ZarliInterstitialAd) {
        channel.invokeMethod("onInterstitialAdClicked", arguments: ["adUnitId": ad.adUnitId])
    }
}

// MARK: - Rewarded Delegate

extension SwiftZarliFlutterPlugin: ZarliRewardedAdDelegate {
    public func adDidLoad(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdLoaded", arguments: ["adUnitId": ad.adUnitId])
    }
    
    public func ad(_ ad: ZarliRewardedAd, didFailToLoad error: Error) {
        channel.invokeMethod("onRewardedAdFailedToLoad", arguments: ["adUnitId": ad.adUnitId, "error": error.localizedDescription])
        // Clean up
        rewardedAds.removeValue(forKey: ad.adUnitId)
    }
    
    public func adDidShow(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdShowed", arguments: ["adUnitId": ad.adUnitId])
    }
    
    public func adDidDismiss(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdDismissed", arguments: ["adUnitId": ad.adUnitId])
        // Clean up
        rewardedAds.removeValue(forKey: ad.adUnitId)
    }
    
    public func adDidClick(_ ad: ZarliRewardedAd) {
        channel.invokeMethod("onRewardedAdClicked", arguments: ["adUnitId": ad.adUnitId])
    }
    
    public func ad(_ ad: ZarliRewardedAd, didEarnReward reward: ZarliReward) {
        channel.invokeMethod("onRewardedAdEarnedReward", arguments: [
            "adUnitId": ad.adUnitId,
            "amount": reward.amount,
            "type": reward.type
        ])
    }
}
