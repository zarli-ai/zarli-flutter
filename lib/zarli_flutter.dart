import 'dart:async';
import 'zarli_flutter_platform_interface.dart';

export 'zarli_flutter_platform_interface.dart'
    show ZarliAdEvent, ZarliAdEventType;

class ZarliFlutter {
  /// Initializes the Zarli SDK with the given API Key.
  ///
  /// This must be called before loading any ads.
  ///
  /// [apiKey] is your unique API key provided by Zarli.
  static Future<void> initialize({required String apiKey}) {
    return ZarliFlutterPlatform.instance.initialize(apiKey: apiKey);
  }

  /// Loads an Interstitial Ad for the given [adUnitId].
  static Future<void> loadInterstitialAd(String adUnitId) {
    return ZarliFlutterPlatform.instance.loadInterstitialAd(adUnitId);
  }

  /// Shows an Interstitial Ad for the given [adUnitId].
  ///
  /// You should wait for the [ZarliAdEventType.interstitialLoaded] event before calling this.
  static Future<void> showInterstitialAd(String adUnitId) {
    return ZarliFlutterPlatform.instance.showInterstitialAd(adUnitId);
  }

  /// Loads a Rewarded Ad for the given [adUnitId].
  static Future<void> loadRewardedAd(String adUnitId) {
    return ZarliFlutterPlatform.instance.loadRewardedAd(adUnitId);
  }

  /// Shows a Rewarded Ad for the given [adUnitId].
  ///
  /// You should wait for the [ZarliAdEventType.rewardedLoaded] event before calling this.
  static Future<void> showRewardedAd(String adUnitId) {
    return ZarliFlutterPlatform.instance.showRewardedAd(adUnitId);
  }

  /// Stream of ad events.
  static Stream<ZarliAdEvent> get adEvents =>
      ZarliFlutterPlatform.instance.adEvents;
}
