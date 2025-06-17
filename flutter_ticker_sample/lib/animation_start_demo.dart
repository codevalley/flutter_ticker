import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ticker/ticker.dart';

class AnimationStartDemoScreen extends StatefulWidget {
  const AnimationStartDemoScreen({super.key});

  @override
  State<AnimationStartDemoScreen> createState() =>
      _AnimationStartDemoScreenState();
}

class _AnimationStartDemoScreenState extends State<AnimationStartDemoScreen> {
  int _counter = 0;
  final Random _random = Random();

  // References to ticker widgets for direct text updates
  final GlobalKey<TickerWidgetState> _defaultTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _currentTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _lastTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _randomTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _specificTickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _counter = 123;

    // Initialize all tickers with the same starting value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAllTickers();
    });
  }

  void _updateAllTickers() {
    final newValue = _counter.toString();

    _defaultTickerKey.currentState?.setText(newValue);
    _currentTickerKey.currentState?.setText(newValue);
    _lastTickerKey.currentState?.setText(newValue);
    _randomTickerKey.currentState?.setText(newValue);
    _specificTickerKey.currentState?.setText(newValue);
  }

  void _incrementCounter() {
    setState(() {
      _counter += _random.nextInt(100) + 1; // Random increment between 1-100
      _updateAllTickers();
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter = (_counter - (_random.nextInt(50) + 1)).clamp(0, 9999);
      _updateAllTickers();
    });
  }

  void _randomizeCounter() {
    setState(() {
      _counter = _random.nextInt(9999);
      _updateAllTickers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Start Configuration Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Current Value: $_counter',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              const SizedBox(height: 20),

              // Default behavior (starts from first character)
              _buildTickerCard(
                'Default (First Character)',
                'Default: Initial animation starts from \'0\'',
                TickerWidget(
                  key: _defaultTickerKey,
                  text: _counter.toString(),
                  textSize: 40,
                  textColor: Colors.blue,
                  characterLists: [TickerUtils.provideNumberList()],
                  animationDuration: 1200,
                  gravity: Alignment.center,
                  // No animationStartConfig - uses default behavior (first character)
                ),
              ),

              // No initial animation (current behavior)
              _buildTickerCard(
                'No Animation (Current)',
                'Shows value immediately without animation',
                TickerWidget(
                  key: _currentTickerKey,
                  text: _counter.toString(),
                  textSize: 40,
                  textColor: Colors.green,
                  characterLists: [TickerUtils.provideNumberList()],
                  animationDuration: 1200,
                  gravity: Alignment.center,
                  animationStartConfig:
                      const TickerAnimationStartConfig.current(),
                ),
              ),

              // Start from last character (9)
              _buildTickerCard(
                'Start from Last (9)',
                'Initial animation starts from \'9\'',
                TickerWidget(
                  key: _lastTickerKey,
                  text: _counter.toString(),
                  textSize: 40,
                  textColor: Colors.orange,
                  characterLists: [TickerUtils.provideNumberList()],
                  animationDuration: 1200,
                  gravity: Alignment.center,
                  animationStartConfig: const TickerAnimationStartConfig.last(),
                ),
              ),

              // Start from random character
              _buildTickerCard(
                'Start from Random',
                'Initial animation starts from a random digit',
                TickerWidget(
                  key: _randomTickerKey,
                  text: _counter.toString(),
                  textSize: 40,
                  textColor: Colors.purple,
                  characterLists: [TickerUtils.provideNumberList()],
                  animationDuration: 1200,
                  gravity: Alignment.center,
                  animationStartConfig: TickerAnimationStartConfig.random(
                    random: _random,
                  ),
                ),
              ),

              // Start from specific character (5)
              _buildTickerCard(
                'Start from Specific (5)',
                'Initial animation starts from \'5\'',
                TickerWidget(
                  key: _specificTickerKey,
                  text: _counter.toString(),
                  textSize: 40,
                  textColor: Colors.red,
                  characterLists: [TickerUtils.provideNumberList()],
                  animationDuration: 1200,
                  gravity: Alignment.center,
                  animationStartConfig:
                      const TickerAnimationStartConfig.specific('5'),
                ),
              ),

              const SizedBox(height: 30),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    child: const Text('Increment'),
                  ),
                  ElevatedButton(
                    onPressed: _decrementCounter,
                    child: const Text('Decrement'),
                  ),
                  ElevatedButton(
                    onPressed: _randomizeCounter,
                    child: const Text('Randomize'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Information card
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animation Start Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This demo shows different ways to configure where the INITIAL ticker animation starts from:\n\n'
                        '• Default: Initial animation starts from the first character (e.g., \'0\') - maintains backward compatibility\n'
                        '• No Animation: Shows target value immediately without initial animation\n'
                        '• Last: Initial animation starts from the last character (e.g., \'9\')\n'
                        '• Random: Initial animation starts from a random character\n'
                        '• Specific: Initial animation starts from a specific character you define\n\n'
                        'Note: This configuration ONLY applies to the first/initial animation. All subsequent animations maintain natural fluidity by starting from the current character.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTickerCard(String title, String description, Widget ticker) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ticker,
          ],
        ),
      ),
    );
  }
}
