# Zarli Flutter Plugin - Integration Guide

Complete step-by-step guide to integrate Zarli ads into your Flutter app using AdMob mediation.

## Prerequisites

- Flutter 3.3.0+ installed
- iOS deployment target 13.0+
- Xcode 14.0+
- Active AdMob account
- Active Zarli account with API key

## Step 1: Install the Plugin

Add `zarli_flutter` and `google_mobile_ads` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_mobile_ads: ^5.1.0
  zarli_flutter: ^0.0.5
```

Run:
```bash
flutter pub get
```

## Step 2: Configure iOS

### 2.1 Update Info.plist

Add your AdMob App ID and Zarli API Key to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
<key>ZarliAPIKey</key>
<string>zk_live_YOUR_ZARLI_API_KEY</string>
```

### 2.2 Set iOS Deployment Target

In `ios/Podfile`, ensure the platform is iOS 13.0+:

```ruby
platform :ios, '13.0'
```

### 2.3 Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

## Step 3: Initialize SDKs in Your App

Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zarli_flutter/zarli_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  await MobileAds.instance.initialize();

  // Initialize Zarli SDK
  await ZarliFlutter.initialize(
    apiKey: "zk_live_YOUR_ZARLI_API_KEY", // Optional if set in Info.plist
  );

  runApp(const MyApp());
}
```

## Step 4: Configure AdMob Mediation

### 4.1 Create a Mediation Group

1. Go to [AdMob Console](https://apps.admob.com/) > **Mediation**
2. Click **Create Mediation Group**
3. Select **Rewarded** (or **Interstitial** depending on your ad type)
4. Choose your app and ad unit
5. Click **Add Custom Event**

### 4.2 Configure Custom Event

Fill in the custom event details:

- **Class Name**: `ZarliAdMobMediationAdapter`
- **Label**: `Zarli` (or any descriptive name)
- **Parameter**: Leave empty (Zarli uses the API key from Info.plist)

**CRITICAL**: The class name must be exactly `ZarliAdMobMediationAdapter` (case-sensitive).

### 4.3 Set eCPM

Set your eCPM bid for Zarli (e.g., $10.00). This determines when Zarli ads are shown in the waterfall.

### 4.4 Save and Activate

Click **Save** and ensure the mediation group is **Active**.

## Step 5: Create Ad Units in AdMob

1. Go to **Apps** > **Ad Units** > **Add Ad Unit**
2. Select **Rewarded** or **Interstitial**
3. Configure settings and create
4. Copy the **Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)

## Step 6: Implement Ads in Your Flutter App

### Rewarded Ad Example

```dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final String _adUnitId = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX";
  
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    setState(() => _isLoading = true);

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Ad loaded successfully');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Ad failed to show: $error');
              ad.dispose();
              _loadAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load: $error');
          setState(() => _isLoading = false);
        },
      ),
    );
  }

  void _showAd() {
    if (_rewardedAd == null) {
      _loadAd();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        // Grant reward to user
      },
    );

    setState(() => _rewardedAd = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: Center(
        child: ElevatedButton(
          onPressed: (_rewardedAd != null && !_isLoading) ? _showAd : null,
          child: Text(_isLoading ? 'Loading...' : 'Watch Ad'),
        ),
      ),
    );
  }
}
```

## Step 7: Test Your Integration

### 7.1 Use Test Mode

For initial testing, use AdMob's test Ad Unit IDs:

- **Rewarded**: `ca-app-pub-3940256099942544/1712485313`
- **Interstitial**: `ca-app-pub-3940256099942544/4411468910`

### 7.2 Run Your App

```bash
flutter run
```

### 7.3 Verify Logs

Check the console for:
- `ZarliSDK initialized` (in DEBUG builds)
- `Ad loaded successfully`
- No "No ad to show" errors

### 7.4 Test on Both iPhone and iPad

Ensure ads load on both device types (use simulators or physical devices).

## Troubleshooting

### "No ad to show" Error

**Symptoms**: `LoadAdError(code: 1, ..., adapterResponses: [])`

**Causes**:
1. **Wrong Ad Unit Type**: Verify your Ad Unit is "Rewarded" not "Rewarded Interstitial"
2. **Adapter Class Name**: Check that `ZarliAdMobMediationAdapter` is spelled correctly in the mediation group
3. **New Ad Unit**: AdMob needs time to propagate new Ad Units (wait 1-2 hours)
4. **Device-Specific**: Test on both iPhone and iPad with different Ad Unit IDs if needed

### Adapter Not Found

**Symptoms**: Build errors or adapter not loading

**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### API Key Issues

**Symptoms**: Zarli SDK initialization fails

**Solution**: Ensure your API key in `Info.plist` matches the one in `main.dart` (or use only one location).

## Production Checklist

Before releasing to production:

- [ ] Replace test Ad Unit IDs with production IDs
- [ ] Verify Zarli API key is correct
- [ ] Test on physical devices (iPhone and iPad)
- [ ] Confirm mediation group is **Active** in AdMob
- [ ] Set appropriate eCPM for Zarli in mediation waterfall
- [ ] Test ad loading in different network conditions
- [ ] Implement proper error handling and retry logic

## Support

- **Zarli Support**: support@zarli.ai
- **Documentation**: [zarli-flutter README](https://pub.dev/packages/zarli_flutter)
- **AdMob Mediation**: [Google AdMob Docs](https://developers.google.com/admob/ios/mediation)
