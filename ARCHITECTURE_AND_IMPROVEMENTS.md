# Zarli Flutter Plugin: Architecture & Improvement Plan

## 1. High-Level Architecture

The `zarli-flutter` plugin currently operates as a **thin bridge** between the Dart/Flutter layer and the native `zarli-ios-sdk`. It strictly mirrors the native SDK's API without adding significant abstraction or state management logic.

### 1.1 Communication Flow
1.  **Dart Layer (`ZarliFlutter`)**: 
    - Exposes static methods (`initialize`, `loadInterstitialAd`, `showInterstitialAd`).
    - Exposes a single global `stream` (`adEvents`) for all ad events across all ad units.
2.  **Method Channel (`zarli_flutter`)**: 
    - Serializes function calls and arguments (e.g., `adUnitId`) into JSON-like messages.
    - Transmits them asynchronously to the iOS native host.
3.  **Native iOS Layer (`SwiftZarliFlutterPlugin`)**:
    - Implements `FlutterPlugin`.
    - Function Router: Switches on method names (e.g., `"loadInterstitialAd"`).
    - **Ad Registry**: Maintains local dictionaries (`interstitialAds`, `rewardedAds`) to hold strong references to active `ZarliInterstitialAd` and `ZarliRewardedAd` objects.
    - **Delegation**: Acts as the `delegate` for *all* created ads. It receives callbacks (`adDidLoad`, `adDidFailToLoad`), serializes the data, and invokes methods back on the Dart `MethodChannel`.

### 1.2 "Thin Wrapper" Assessment
**Yes**, the current implementation is a classic "thin wrapper."
- **1-to-1 Mapping**: Each Dart method maps directly to a Swift method.
- **No State Machine**: The Dart side doesn't track if an ad is loaded or loading; it relies on the consumer (the app developer) to listen to events and track state.
- **Direct Event Piping**: Native events are piped directly to a raw stream without filtering or object-oriented encapsulation (e.g., you get a `ZarliAdEvent` struct, not an `Ad` object with listeners).

---

## 2. Proposed Improvements

To elevate the plugin from a raw wrapper to a production-grade SDK, we recommend the following enhancements.

### Goal 1: Reduce Mobile App Developer Overhead

The current approach places a heavy burden on the developer to implement boilerplate code (streams subscriptions, state flags like `isLoading`, `isReady`).

#### 1. Object-Oriented Dart Ad Classes
Instead of static methods and global streams, expose dedicated classes.
*   **Current**:
    ```dart
    ZarliFlutter.loadInterstitialAd(id);
    ZarliFlutter.adEvents.listen((e) { if (e.id == id) ... });
    ```
*   **Proposed**:
    ```dart
    final ad = ZarliInterstitialAd(adUnitId: id);
    await ad.load();
    ad.show();
    ```
    *   **Implementation**: Create a Dart class that handles the method channel calls internally and filters the global stream for events relevant only to *this* instance.

#### 2. Automatic State Management
The Dart class should track its own state (`loading`, `loaded`, `error`).
- **Feature**: `ad.isReady` property in Dart.
- **Feature**: `await ad.load()` should return a `Future` that completes when the ad is actually loaded (or throws on error), rather than just "request sent". This flattens the async flow and removes the need for stream listeners for basic loading.

#### 3. Info.plist / AndroidManifest Initialization
- **Current**: Developer must call `initialize(apiKey: ...)` in `main.dart`.
- **Proposed**: Allow reading the API Key from `Info.plist` (`ZarliAPIKey`). This allows configuration management outside of code and is standard for SDKs (like AdMob/Firebase).

#### 4. Type-Safe Error Handling
- Map native error domains/codes to Dart Exceptions (`ZarliNetworkException`, `ZarliNoFillException`) instead of generic strings.

---

### Goal 2: Security, Quality, and Performance

#### 1. Memory Safety & Lifecycle (Code Quality)
*   **Issue**: The Swift code interacts with `interstitialAds` dictionary. If `load()` is called twice for the same ID, the first ad instance is overwritten and deallocated. If it was in the middle of a network request, that request might dangle or crash on callback.
*   **Fix**: 
    - Implement a `dispose()` method in the Dart class that calls a native `dispose` to clean up the specific ad instance.
    - Return unique "Instance IDs" (UUIDs) for each loaded ad, not just `adUnitId`. This allows loading *multiple* ads for the same Ad Unit ID (e.g., preloading the next level's ad while showing the current one).

#### 2. Secure Billing & Impression Tracking
*   **Issue**: `zarli-flutter` should ensure that sensitive billing URLs or revenue data are not exposed to the Dart layer if not necessary.
*   **Fix**: Keep all impression tracking and billing pings strictly within the `zarli-ios-sdk` native layer (which it seems to do). The wrapping plugin should *only* expose "User earned reward" events, not the raw dollar value unless required for analytics.

#### 3. Faster Ad Loading (Performance)
*   **Issue**: Ads are loaded lazily when requested.
*   **Fix**: **Auto-In-Memory Caching**.
    - Implement a `ZarliAdManager` in native code that caches the next ad for a given Unit ID automatically.
    - When `load()` is requested, if an ad is in the cache, return it immediately.
    - If sending a bid request, ensure the network call happens on a background queue (Native SDK likely handles this, but Plugin should verify it doesn't block the UI thread during serialization).

#### 4. UI Hierarchy Safety
*   **Issue**: `UIApplication.shared.keyWindow?.rootViewController`. This is fragile (deprecated in iOS 13+, fails with SceneDelegate).
*   **Fix**: update `show()` logic to use `UIWindowScene` to find the active window and top-most view controller. This prevents ads from failing to show in complex apps with multiple windows or navigation stacks.

### Summary of Tasks

| Priority | Task | Impact |
| :--- | :--- | :--- |
| **High** | Refactor Dart API to Object-Oriented `ZarliInterstitialAd` / `ZarliRewardedAd` classes. | massively improves DX |
| **High** | Implement UUID-based Ad tracking in Native layer (allow multiple ads per UnitID). | Fixes race conditions & bugs |
| **Medium** | Support `Info.plist` for API Key. | Standardizes integration |
| **Medium** | Fix `rootViewController` lookup in Swift. | Fixes potential crashes/UI bugs |
