import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'zarli_flutter_platform_interface.dart';

export 'zarli_flutter_platform_interface.dart'
    show ZarliAdEvent, ZarliAdEventType;

/// Entry point for the Zarli SDK.
class ZarliFlutter {
  /// Initializes the Zarli SDK.
  ///
  /// This must be called before loading any ads.
  ///
  /// [apiKey] is optional. If not provided, the plugin attempts to read
  /// 'ZarliAPIKey' from Info.plist (iOS) or AndroidManifest.xml (Android).
  /// [useLocalServer] - If true, points the SDK to local bidding server (typically for development).
  static Future<void> initialize(
      {String? apiKey, bool useLocalServer = false}) {
    return ZarliFlutterPlatform.instance
        .initialize(apiKey: apiKey, useLocalServer: useLocalServer);
  }

  /// Sets the user and content context for better ad targeting.
  ///
  /// Sets the user and content context for better ad targeting.
  ///
  /// [hashedEmail] - The user's email address, hashed using SHA-256.
  /// Use [ZarliFlutter.hashEmail] to generate this hash from a raw email.
  /// [currentSeriesName] - The name of the series being watched.
  /// [currentEpisodeNumber] - The number of the episode being watched.
  /// [contentUrl] - Content URL
  static Future<void> setContext({
    String? hashedEmail,
    String? currentSeriesName,
    int? currentEpisodeNumber,
    String? contentUrl,
  }) {
    return ZarliFlutterPlatform.instance.setContext(
      hashedEmail: hashedEmail,
      currentSeriesName: currentSeriesName,
      currentEpisodeNumber: currentEpisodeNumber,
      contentUrl: contentUrl,
    );
  }

  /// Hashes an email address using SHA-256 for privacy compliance.
  ///
  /// Use this before passing an email to [setContext].
  static String hashEmail(String email) {
    // 1. Trim whitespace
    // 2. Convert to lowercase
    // 3. Compute SHA-256 hash
    final cleanEmail = email.trim().toLowerCase();
    final bytes = utf8.encode(cleanEmail);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Abstract base class for Zarli Ads.
abstract class ZarliAd {
  final String adUnitId;
  final String _adObjectId;

  // Internal state
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  StreamSubscription<ZarliAdEvent>? _subscription;
  Completer<void>? _loadCompleter;

  ZarliAd({required this.adUnitId}) : _adObjectId = _generateUniqueId();

  /// Loads the ad.
  ///
  /// Returns a Future that completes when the ad is successfully loaded.
  /// Throws an exception if loading fails.
  Future<void> load() async {
    if (_isLoaded) return;
    if (_loadCompleter != null) return _loadCompleter!.future;

    _loadCompleter = Completer<void>();

    // Subscribe to global stream filtered by this ID
    _subscription = ZarliFlutterPlatform.instance.adEvents
        .where((event) => event.adObjectId == _adObjectId)
        .listen(_handleEvent);

    try {
      await _loadNative();
    } catch (e) {
      _loadCompleter?.completeError(e);
      _loadCompleter = null;
      _subscription?.cancel();
    }

    return _loadCompleter!.future;
  }

  /// Disposes the ad and cleans up native resources.
  ///
  /// You must call this when you are done with the ad.
  Future<void> dispose() async {
    _subscription?.cancel();
    _subscription = null;
    await ZarliFlutterPlatform.instance.disposeAd(_adObjectId);
  }

  // Abstract methods
  Future<void> _loadNative();
  void _handleEvent(ZarliAdEvent event);

  static String _generateUniqueId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'ad_${timestamp}_$random';
  }
}

/// Represents a full-screen interstitial ad.
class ZarliInterstitialAd extends ZarliAd {
  /// Called when the ad is shown.
  void Function()? onAdShowed;

  /// Called when the ad is dismissed.
  void Function()? onAdDismissed;

  /// Called when the ad is clicked.
  void Function()? onAdClicked;

  /// Called when the ad fails to show.
  void Function(String error)? onAdFailedToShow;

  ZarliInterstitialAd({required String adUnitId}) : super(adUnitId: adUnitId);

  @override
  Future<void> _loadNative() {
    return ZarliFlutterPlatform.instance
        .loadInterstitialAd(adUnitId, _adObjectId);
  }

  /// Shows the interstitial ad.
  ///
  /// The ad must be loaded before showing.
  Future<void> show() async {
    if (!_isLoaded) {
      throw Exception('Ad must be loaded before showing.');
    }
    await ZarliFlutterPlatform.instance.showInterstitialAd(_adObjectId);
  }

  @override
  void _handleEvent(ZarliAdEvent event) {
    switch (event.type) {
      case ZarliAdEventType.interstitialLoaded:
        _isLoaded = true;
        _loadCompleter?.complete();
        _loadCompleter = null;
        break;
      case ZarliAdEventType.interstitialFailedToLoad:
        _isLoaded = false;
        final error = event.data as String? ?? 'Unknown error';
        _loadCompleter?.completeError(error);
        _loadCompleter = null;
        dispose(); // Auto-dispose on load failure
        break;
      case ZarliAdEventType.interstitialShowed:
        onAdShowed?.call();
        break;
      case ZarliAdEventType.interstitialDismissed:
        onAdDismissed?.call();
        dispose(); // Auto-dispose after show
        break;
      case ZarliAdEventType.interstitialClicked:
        onAdClicked?.call();
        break;
      default:
        break;
    }
  }
}

/// Represents a rewarded ad.
class ZarliRewardedAd extends ZarliAd {
  /// Called when the ad is shown.
  void Function()? onAdShowed;

  /// Called when the ad is dismissed.
  void Function()? onAdDismissed;

  /// Called when the ad is clicked.
  void Function()? onAdClicked;

  /// Called when the user executes the action to earn a reward.
  void Function(int amount, String type)? onUserEarnedReward;

  /// Called when the ad fails to show.
  void Function(String error)? onAdFailedToShow;

  ZarliRewardedAd({required String adUnitId}) : super(adUnitId: adUnitId);

  @override
  Future<void> _loadNative() {
    return ZarliFlutterPlatform.instance.loadRewardedAd(adUnitId, _adObjectId);
  }

  /// Shows the rewarded ad.
  ///
  /// The ad must be loaded before showing.
  Future<void> show() async {
    if (!_isLoaded) {
      throw Exception('Ad must be loaded before showing.');
    }
    await ZarliFlutterPlatform.instance.showRewardedAd(_adObjectId);
  }

  @override
  void _handleEvent(ZarliAdEvent event) {
    switch (event.type) {
      case ZarliAdEventType.rewardedLoaded:
        _isLoaded = true;
        _loadCompleter?.complete();
        _loadCompleter = null;
        break;
      case ZarliAdEventType.rewardedFailedToLoad:
        _isLoaded = false;
        final error = event.data as String? ?? 'Unknown error';
        _loadCompleter?.completeError(error);
        _loadCompleter = null;
        dispose(); // Auto-dispose on load failure
        break;
      case ZarliAdEventType.rewardedShowed:
        onAdShowed?.call();
        break;
      case ZarliAdEventType.rewardedDismissed:
        onAdDismissed?.call();
        dispose(); // Auto-dispose after show
        break;
      case ZarliAdEventType.rewardedClicked:
        onAdClicked?.call();
        break;
      case ZarliAdEventType.rewardedEarnedReward:
        if (event.data is Map) {
          final map = event.data as Map;
          final amount = map['amount'] as int? ?? 1;
          final type = map['type'] as String? ?? 'reward';
          onUserEarnedReward?.call(amount, type);
        }
        break;
      default:
        break;
    }
  }
}
