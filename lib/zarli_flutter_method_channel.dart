import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zarli_flutter_platform_interface.dart';

/// An implementation of [ZarliFlutterPlatform] that uses method channels.
class MethodChannelZarliFlutter extends ZarliFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zarli_flutter');

  final StreamController<ZarliAdEvent> _eventStreamController =
      StreamController<ZarliAdEvent>.broadcast();

  MethodChannelZarliFlutter() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    final args = call.arguments as Map<dynamic, dynamic>;
    final adUnitId = args['adUnitId'] as String? ?? 'unknown';
    // adObjectId might be missing for legacy events if any (but we updated native code)
    final adObjectId = args['adObjectId'] as String? ?? '';

    switch (call.method) {
      // Interstitial
      case 'onInterstitialAdLoaded':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialLoaded,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onInterstitialAdFailedToLoad':
        final error = args['error'] as String? ?? 'Unknown error';
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialFailedToLoad,
            adObjectId: adObjectId,
            adUnitId: adUnitId,
            data: error));
        break;
      case 'onInterstitialAdShowed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialShowed,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onInterstitialAdDismissed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialDismissed,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onInterstitialAdClicked':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialClicked,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;

      // Rewarded
      case 'onRewardedAdLoaded':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedLoaded,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onRewardedAdFailedToLoad':
        final error = args['error'] as String? ?? 'Unknown error';
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedFailedToLoad,
            adObjectId: adObjectId,
            adUnitId: adUnitId,
            data: error));
        break;
      case 'onRewardedAdShowed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedShowed,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onRewardedAdDismissed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedDismissed,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onRewardedAdClicked':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedClicked,
            adObjectId: adObjectId,
            adUnitId: adUnitId));
        break;
      case 'onRewardedAdEarnedReward':
        final amount = args['amount'] as int? ?? 1;
        final type = args['type'] as String? ?? 'reward';
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedEarnedReward,
            adObjectId: adObjectId,
            adUnitId: adUnitId,
            data: {'amount': amount, 'type': type}));
        break;
      default:
        // Handle unknown methods
        break;
    }
  }

  @override
  Stream<ZarliAdEvent> get adEvents => _eventStreamController.stream;

  @override
  Future<void> initialize({String? apiKey, bool useLocalServer = false}) async {
    final Map<String, dynamic> args = {};
    if (apiKey != null) {
      args['apiKey'] = apiKey;
    }
    args['useLocalServer'] = useLocalServer;
    await methodChannel.invokeMethod<void>('initialize', args);
  }

  @override
  Future<void> loadInterstitialAd(String adUnitId, String adObjectId) async {
    await methodChannel.invokeMethod<void>('loadInterstitialAd', {
      'adUnitId': adUnitId,
      'adObjectId': adObjectId,
    });
  }

  @override
  Future<void> showInterstitialAd(String adObjectId) async {
    await methodChannel
        .invokeMethod<void>('showInterstitialAd', {'adObjectId': adObjectId});
  }

  @override
  Future<void> loadRewardedAd(String adUnitId, String adObjectId) async {
    await methodChannel.invokeMethod<void>('loadRewardedAd', {
      'adUnitId': adUnitId,
      'adObjectId': adObjectId,
    });
  }

  @override
  Future<void> showRewardedAd(String adObjectId) async {
    await methodChannel.invokeMethod<void>('showRewardedAd', {
      'adObjectId': adObjectId,
    });
  }

  @override
  Future<void> setContext({
    String? hashedEmail,
    String? currentSeriesName,
    int? currentEpisodeNumber,
    String? contentUrl,
  }) async {
    await methodChannel.invokeMethod<void>('setContext', {
      'hashedEmail': hashedEmail, // New key for clarity
      'currentSeriesName': currentSeriesName,
      'currentEpisodeNumber': currentEpisodeNumber,
      'contentUrl': contentUrl,
    });
  }

  @override
  Future<void> disposeAd(String adObjectId) async {
    await methodChannel
        .invokeMethod<void>('disposeAd', {'adObjectId': adObjectId});
  }
}
