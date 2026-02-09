# Zarli Flutter Plugin

The official Flutter plugin for the Zarli iOS SDK. Monetize your Flutter apps with high-performance, interactive HTML5 playable ads.

## Features

* **Interstitial Ads**: Full-screen ads that cover the interface of their host app
* **Rewarded Ads**: Ads that reward users for watching short videos and interacting with playable ads
* **AdMob Mediation**: Seamless integration with Google AdMob mediation

## Platform Support

- ✅ **iOS** 13.0+
- 🚧 **Android** (Coming soon)

## Installation

### 1. Add dependency

Add `zarli_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  zarli_flutter: ^0.0.5
```

### 2. Configure iOS

#### Option A: Swift Package Manager (Recommended for Flutter 3.24+)

This plugin supports Swift Package Manager (SPM), which simplifies dependency management and removes the need for CocoaPods.

1.  **Enable SPM** in your Flutter project:
    ```bash
    flutter config --enable-swift-package-manager
    ```
2.  **That's it!** Flutter will automatically resolve the `zarli-ios-sdk` dependency using the plugin's `Package.swift`.

#### Option B: CocoaPods (Legacy)

If you are not using SPM, CocoaPods will automatically handle the installation via the `.podspec`.

1.  Make sure your `ios/Podfile` targets iOS 13.0 or higher.
    ```ruby
    platform :ios, '13.0'
    ```
2.  Run `pod install` in your `ios` directory.

## Usage

### 1. Initialize the SDK

Initialize in your `main()` function:

```dart
import 'package:zarli_flutter/zarli_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ZarliFlutter.initialize(
    apiKey: "YOUR_ZARLI_API_KEY"
  );
  
  runApp(const MyApp());
}
```

### 2. Set User & Content Context (Recommended)

To improve ad targeting and revenue, set the user and content context before loading ads. This is preferred over passing data via AdMob extras.

```dart
await ZarliFlutter.setContext(
  contentUrl: "https://zarli.ai/content/123", // URL of the content being viewed
  hashedEmail: ZarliFlutter.hashEmail("user@example.com"), // Hash email for privacy
  currentSeriesName: "My Series", // Optional
  currentEpisodeNumber: 1 // Optional
);
```

### 3. Interstitial Ads

```dart
import 'package:zarli_flutter/zarli_flutter.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  ZarliInterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _interstitialAd = ZarliInterstitialAd(
      adUnitId: "YOUR_AD_UNIT_ID",
    );
    
    _interstitialAd!.onAdLoaded = () {
      print("Ad loaded!");
    };
    
    _interstitialAd!.onAdFailedToLoad = (error) {
      print("Ad failed to load: $error");
    };
    
    _interstitialAd!.load();
  }

  void _showAd() {
    if (_interstitialAd != null && _interstitialAd!.isLoaded) {
      _interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showAd,
      child: Text("Show Ad"),
    );
  }
}
```

### 4. Rewarded Ads

```dart
final ad = ZarliRewardedAd(adUnitId: "YOUR_REWARDED_AD_UNIT_ID");

// Set callbacks
ad.onUserEarnedReward = (amount, type) {
  print("User earned $amount $type");
  // Grant reward to user (coins, lives, etc.)
};

ad.onAdLoaded = () {
  print("Rewarded ad loaded!");
};

ad.onAdFailedToLoad = (error) {
  print("Failed to load: $error");
};

// Load
await ad.load();

// Show when ready
if (ad.isLoaded) {
  await ad.show();
}
```

## Migrating from CocoaPods to SPM

If you're upgrading to Flutter 3.24+ and want to migrate:

1. **Enable SPM:**
   ```bash
   flutter config --enable-swift-package-manager
   ```

2. **Remove CocoaPods dependencies:**
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   cd ..
   ```

3. **Add SPM packages** (follow Method 1 steps above)

4. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Troubleshooting

### SPM Issues

**"Package not found" error:**
- Ensure you're using Flutter 3.24+
- Verify SPM is enabled: `flutter config --enable-swift-package-manager`
- Clean build: `flutter clean && flutter pub get`

**Build errors after adding package:**
- Open `ios/Runner.xcworkspace` in Xcode
- Product > Clean Build Folder (Cmd+Shift+K)
- Rebuild

### CocoaPods Issues

**"Pod install failed":**
- Update CocoaPods: `sudo gem install cocoapods`
- Update repo: `pod repo update`
- Try again: `cd ios && pod install`

**"ZarliAdapterAdMob not found":**
- Verify the plugin is in `pubspec.yaml`
- Run `flutter pub get`
- Run `cd ios && pod install`

### General Issues

**Ads not loading:**
- Verify SDK initialization in `main()`
- Check API key is correct
- Ensure iOS deployment target is 13.0+ in Xcode
- Check console logs for error messages

**App crashes on ad load:**
- Verify you've added required `Info.plist` entries (see iOS SDK README)
- Ensure ATT permission is requested (iOS 14+)

## Requirements

* **iOS**: 13.0+
* **Flutter**: 3.3.0+ (3.24+ for SPM support)
* **Xcode**: 14.0+

## Version Compatibility

| Flutter Version | Recommended Method | Status |
|----------------|-------------------|--------|
| 3.24+ | Swift Package Manager | ✅ Recommended |
| 3.3 - 3.23 | CocoaPods | ✅ Supported |
| < 3.3 | Not supported | ❌ |

## Additional Resources

- [Zarli iOS SDK Documentation](https://github.com/zarli-ai/zarli-ios-sdk)
- [AdMob Mediation Guide](https://github.com/zarli-ai/zarli-ios-sdk#admob-mediation)
- [Example App](./example)

## Support

For issues or questions:
- Email: support@zarli.ai
- GitHub Issues: [zarli-ai/zarli-flutter](https://github.com/zarli-ai/zarli-flutter/issues)

## License

MIT License - Copyright (c) 2026 Zarli AI
