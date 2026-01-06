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

    switch (call.method) {
      // Interstitial
      case 'onInterstitialAdLoaded':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialLoaded, adUnitId: adUnitId));
        break;
      case 'onInterstitialAdFailedToLoad':
        final error = args['error'] as String? ?? 'Unknown error';
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialFailedToLoad,
            adUnitId: adUnitId,
            data: error));
        break;
      case 'onInterstitialAdShowed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialShowed, adUnitId: adUnitId));
        break;
      case 'onInterstitialAdDismissed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialDismissed, adUnitId: adUnitId));
        break;
      case 'onInterstitialAdClicked':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.interstitialClicked, adUnitId: adUnitId));
        break;

      // Rewarded
      case 'onRewardedAdLoaded':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedLoaded, adUnitId: adUnitId));
        break;
      case 'onRewardedAdFailedToLoad':
        final error = args['error'] as String? ?? 'Unknown error';
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedFailedToLoad,
            adUnitId: adUnitId,
            data: error));
        break;
      case 'onRewardedAdShowed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedShowed, adUnitId: adUnitId));
        break;
      case 'onRewardedAdDismissed':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedDismissed, adUnitId: adUnitId));
        break;
      case 'onRewardedAdClicked':
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedClicked, adUnitId: adUnitId));
        break;
      case 'onRewardedAdEarnedReward':
        final amount = args['amount'] as int? ?? 1;
        final type = args['type'] as String? ?? 'reward';
        _eventStreamController.add(ZarliAdEvent(
            type: ZarliAdEventType.rewardedEarnedReward,
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
  Future<void> initialize({required String apiKey}) async {
    await methodChannel.invokeMethod<void>('initialize', {'apiKey': apiKey});
  }

  @override
  Future<void> loadInterstitialAd(String adUnitId) async {
    await methodChannel
        .invokeMethod<void>('loadInterstitialAd', {'adUnitId': adUnitId});
  }

  @override
  Future<void> showInterstitialAd(String adUnitId) async {
    await methodChannel
        .invokeMethod<void>('showInterstitialAd', {'adUnitId': adUnitId});
  }

  @override
  Future<void> loadRewardedAd(String adUnitId) async {
    await methodChannel
        .invokeMethod<void>('loadRewardedAd', {'adUnitId': adUnitId});
  }

  @override
  Future<void> showRewardedAd(String adUnitId) async {
    await methodChannel
        .invokeMethod<void>('showRewardedAd', {'adUnitId': adUnitId});
  }
}
