import 'package:flutter/material.dart';
import 'package:zarli_flutter/zarli_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Zarli SDK
  // Replace with your actual API key
  await ZarliFlutter.initialize(apiKey: "YOUR_ZARLI_API_KEY");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zarli Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AdDemoScreen(),
    );
  }
}

class AdDemoScreen extends StatefulWidget {
  const AdDemoScreen({super.key});

  @override
  State<AdDemoScreen> createState() => _AdDemoScreenState();
}

class _AdDemoScreenState extends State<AdDemoScreen> {
  // Replace with your actual Ad Unit ID
  final String _adUnitId = "YOUR_AD_UNIT_ID";

  ZarliRewardedAd? _rewardedAd;
  bool _isLoading = false;
  String _statusMessage = "Tap the button to load an ad";
  int _rewardCount = 0;

  @override
  void initState() {
    super.initState();
    // Pre-load the first ad
    _loadAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Loading ad...";
    });

    // Dispose previous ad if exists
    _rewardedAd?.dispose();

    _rewardedAd = ZarliRewardedAd(adUnitId: _adUnitId);

    // Set up callbacks
    _rewardedAd!.onUserEarnedReward = (amount, type) {
      setState(() {
        _rewardCount += amount;
        _statusMessage = "🎉 Reward earned! +$amount $type";
      });
    };

    _rewardedAd!.onAdDismissed = () {
      if (mounted) {
        setState(() {
          _statusMessage = "Ad dismissed. Loading next ad...";
        });
        // Pre-load the next ad
        _loadAd();
      }
    };

    _rewardedAd!.onAdFailedToShow = (error) {
      if (mounted) {
        setState(() {
          _statusMessage = "Failed to show ad: $error";
          _isLoading = false;
        });
      }
    };

    try {
      await _rewardedAd!.load();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Ad ready! Tap to watch";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Failed to load ad: $e";
        });
      }
    }
  }

  Future<void> _showAd() async {
    if (_rewardedAd == null || !_rewardedAd!.isLoaded) {
      setState(() {
        _statusMessage = "Ad not ready yet. Please wait...";
      });
      return;
    }

    try {
      await _rewardedAd!.show();
    } catch (e) {
      setState(() {
        _statusMessage = "Failed to show ad: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdReady = _rewardedAd?.isLoaded ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Zarli Flutter Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reward counter
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.stars, size: 48, color: Colors.amber),
                    const SizedBox(height: 8),
                    Text(
                      '$_rewardCount',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const Text(
                      'Total Rewards',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Status message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Main button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: (isAdReady && !_isLoading) ? _showAd : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.play_circle_fill, size: 32),
                  label: Text(
                    _isLoading
                        ? "Loading..."
                        : isAdReady
                        ? "I'm Feeling Lucky!"
                        : "Please Wait...",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Retry button (only shown if failed)
              if (!isAdReady &&
                  !_isLoading &&
                  _statusMessage.contains('Failed'))
                TextButton.icon(
                  onPressed: _loadAd,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Loading Ad'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
