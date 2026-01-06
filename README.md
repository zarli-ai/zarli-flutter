# Zarli Flutter Plugin

The official Flutter plugin for the Zarli iOS SDK.

## Features

* **Interstitial Ads**: Full-screen ads that cover the interface of their host app.
* **Rewarded Ads**: Ads that reward users for watching short videos and interacting with playable ads.

## Platform Support

- ✅ **iOS** 13.0+

## Installation

Add `zarli_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  zarli_flutter: ^0.0.1
```

## Usage

### Initialization

Initialize the SDK in your `main()` function:

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

### Loading an Ad

```dart
final ad = ZarliRewardedAd(adUnitId: "YOUR_AD_UNIT_ID");

// Set callbacks
ad.onUserEarnedReward = (amount, type) {
  print("User earned $amount $type");
};

// Load
await ad.load();

// Show
if (ad.isLoaded) {
  await ad.show();
}
```

## Requirements

* iOS 13.0+
* Flutter 3.3.0+

## License

MIT
