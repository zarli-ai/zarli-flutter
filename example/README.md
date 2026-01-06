# zarli_flutter_example

Example application demonstrating the `zarli_flutter` plugin.

## Setup

1. **Get your Zarli API Key**:
   - Sign up dashboard access at [dashboard.zarli.ai/signup](https://dashboard.zarli.ai/signup)
   - Navigate to your dashboard to get your API key

2. **Get your Ad Unit ID**:
   - Create an ad unit in your Zarli dashboard
   - Copy the Ad Unit ID

3. **Update the code**:
   - Open `lib/main.dart`
   - Replace `YOUR_ZARLI_API_KEY` with your actual API key
   - Replace `YOUR_AD_UNIT_ID` with your actual Ad Unit ID

## Running

```bash
cd example
flutter run
```

## What it demonstrates

- SDK initialization
- Loading a rewarded ad
- Showing a rewarded ad
- Handling ad callbacks (rewards, dismissal, errors)
- Auto-reloading ads after dismissal
