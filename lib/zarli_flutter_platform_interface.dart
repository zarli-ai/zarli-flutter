import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'zarli_flutter_method_channel.dart';

abstract class ZarliFlutterPlatform extends PlatformInterface {
  /// Constructs a ZarliFlutterPlatform.
  ZarliFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZarliFlutterPlatform _instance = MethodChannelZarliFlutter();

  /// The default instance of [ZarliFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelZarliFlutter].
  static ZarliFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZarliFlutterPlatform] when
  /// they register themselves.
  static set instance(ZarliFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the SDK.
  Future<void> initialize({required String apiKey}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Loads an interstitial ad.
  Future<void> loadInterstitialAd(String adUnitId) {
    throw UnimplementedError('loadInterstitialAd() has not been implemented.');
  }

  /// Shows a loaded interstitial ad.
  Future<void> showInterstitialAd(String adUnitId) {
    throw UnimplementedError('showInterstitialAd() has not been implemented.');
  }

  /// Loads a rewarded ad.
  Future<void> loadRewardedAd(String adUnitId) {
    throw UnimplementedError('loadRewardedAd() has not been implemented.');
  }

  /// Shows a loaded rewarded ad.
  Future<void> showRewardedAd(String adUnitId) {
    throw UnimplementedError('showRewardedAd() has not been implemented.');
  }

  /// Stream of ad events (loaded, failed, showed, dismissed, reward earned).
  Stream<ZarliAdEvent> get adEvents {
    throw UnimplementedError('adEvents has not been implemented.');
  }
}

/// Represents an event from the Native SDK.
class ZarliAdEvent {
  final ZarliAdEventType type;
  final String adUnitId;
  final dynamic data; // Error message or Reward amount

  ZarliAdEvent({
    required this.type,
    required this.adUnitId,
    this.data,
  });
}

enum ZarliAdEventType {
  interstitialLoaded,
  interstitialFailedToLoad,
  interstitialShowed,
  interstitialDismissed,
  interstitialClicked,
  rewardedLoaded,
  rewardedFailedToLoad,
  rewardedShowed,
  rewardedDismissed,
  rewardedClicked,
  rewardedEarnedReward,
}
