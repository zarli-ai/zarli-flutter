# Local Development Guide

This guide is for **Zarli SDK contributors** who need to test against a local bidding server during development.

## iOS Development

To use a local bidding server in debug builds, set the `ZARLI_USE_LOCAL_SERVER` environment variable in your Xcode scheme:

1. Open your Xcode scheme: **Product → Scheme → Edit Scheme**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Environment Variables**, add:
   - **Name**: `ZARLI_USE_LOCAL_SERVER`
   - **Value**: `1`

### How It Works

- **Debug builds**: When `ZARLI_USE_LOCAL_SERVER=1` is set, the SDK uses `http://localhost:8081`
- **Production builds**: Always use `https://bidding.zarli.ai` (environment variable is ignored)

### Example Configuration

```dart
// In your Flutter app's main.dart
await ZarliFlutter.initialize(
  apiKey: "your-api-key",
);
```

No code changes are needed. The environment variable controls the server URL automatically in debug builds.

## Running the Local Bidding Server

Ensure your local bidding server is running on port 8081:

```bash
cd /path/to/ads_bidding_server
go run ./cmd/server --local --debug
```

## Troubleshooting

**Q: The SDK is still using the production server even with the environment variable set.**

A: Ensure you're running a **debug build**, not a release build. The environment variable only works in debug configurations.

**Q: How do I verify which server the SDK is using?**

A: Check the Xcode console logs. The SDK logs the configured base URL during initialization:
```
ZarliSDK configured for LOCAL SERVER: http://localhost:8081
```
or
```
ZarliSDK configured for PRODUCTION (default): https://bidding.zarli.ai
```
