import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ticker/flutter_ticker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ticker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Ticker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BasicDemoScreen()),
                );
              },
              child: const Text('Basic Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PerformanceDemoScreen()),
                );
              },
              child: const Text('Performance Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SlideDirectionDemoScreen()),
                );
              },
              child: const Text('Slide Direction Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

// Base screen with common functionality for all demo screens
abstract class BaseDemoScreen extends StatefulWidget {
  const BaseDemoScreen({super.key});
}

abstract class BaseDemoScreenState<T extends BaseDemoScreen> extends State<T> {
  static final Random random = Random();
  Timer? _timer;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isActive = true;
    _scheduleUpdate();
  }

  @override
  void dispose() {
    _isActive = false;
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleUpdate() {
    _timer = Timer(Duration(milliseconds: random.nextInt(1750) + 250), () {
      if (_isActive) {
        onUpdate();
        _scheduleUpdate();
      }
    });
  }

  // To be implemented by subclasses
  void onUpdate();

  // Helper method to generate random numbers
  String getRandomNumber(int digits) {
    final digitsInPowerOf10 = pow(10, digits).toInt();
    return (random.nextInt(digitsInPowerOf10) +
            digitsInPowerOf10 * (random.nextInt(8) + 1))
        .toString();
  }

  // Helper method to generate random characters
  String generateChars(String charList, int numDigits) {
    final result = StringBuffer();
    for (int i = 0; i < numDigits; i++) {
      result.write(charList[random.nextInt(charList.length)]);
    }
    return result.toString();
  }
}

// Basic Demo Screen
class BasicDemoScreen extends BaseDemoScreen {
  const BasicDemoScreen({super.key});

  @override
  State<BasicDemoScreen> createState() => _BasicDemoScreenState();
}

class _BasicDemoScreenState extends BaseDemoScreenState<BasicDemoScreen> {
  final String alphabetList = "abcdefghijklmnopqrstuvwxyz";

  final GlobalKey<TickerWidgetState> _ticker1Key = GlobalKey();
  final GlobalKey<TickerWidgetState> _ticker2Key = GlobalKey();
  final GlobalKey<TickerWidgetState> _ticker3Key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ticker with downward scrolling
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Downward Scrolling',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TickerWidget(
                      key: _ticker1Key,
                      text: "12345678",
                      textSize: 30,
                      textColor: Colors.blue,
                      characterLists: [TickerUtils.provideNumberList()],
                      preferredScrollingDirection: ScrollingDirection.down,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ticker with upward scrolling and currency
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Upward Scrolling (Currency)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TickerWidget(
                          key: _ticker2Key,
                          text: "0.00",
                          textSize: 30,
                          textColor: Colors.green,
                          characterLists: [
                            TickerUtils.provideNumberList() + "."
                          ],
                          preferredScrollingDirection: ScrollingDirection.up,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ticker with any direction scrolling (alphabets)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Any Direction Scrolling (Alphabets)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TickerWidget(
                      key: _ticker3Key,
                      text: "flutter",
                      textSize: 30,
                      textColor: Colors.orange,
                      characterLists: [TickerUtils.provideAlphabeticalList()],
                      preferredScrollingDirection: ScrollingDirection.any,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onUpdate() {
    setState(() {
      final digits = BaseDemoScreenState.random.nextInt(2) + 6;

      // Update the number ticker
      _ticker1Key.currentState?.setText(getRandomNumber(digits));

      // Update the currency ticker
      final currencyFloat =
          (BaseDemoScreenState.random.nextDouble() * 100).toString();
      _ticker2Key.currentState?.setText(
          currencyFloat.substring(0, min(digits, currencyFloat.length)));

      // Update the alphabet ticker
      _ticker3Key.currentState?.setText(generateChars(alphabetList, digits));
    });
  }
}

// Performance Demo Screen
class PerformanceDemoScreen extends BaseDemoScreen {
  const PerformanceDemoScreen({super.key});

  @override
  State<PerformanceDemoScreen> createState() => _PerformanceDemoScreenState();
}

class _PerformanceDemoScreenState
    extends BaseDemoScreenState<PerformanceDemoScreen> {
  final List<GlobalKey<TickerWidgetState>> _tickerKeys = [];

  @override
  void initState() {
    super.initState();

    // Initialize ticker keys
    for (int i = 0; i < 20; i++) {
      _tickerKeys.add(GlobalKey<TickerWidgetState>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Row ${index + 1}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TickerWidget(
                      key: _tickerKeys[index],
                      text: getRandomNumber(8),
                      textSize: 24,
                      textColor: Colors.indigo,
                      characterLists: [TickerUtils.provideNumberList()],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void onUpdate() {
    setState(() {
      // Update all tickers with new random values
      for (var key in _tickerKeys) {
        key.currentState?.setText(getRandomNumber(8));
      }
    });
  }
}

// Slide Direction Demo Screen
class SlideDirectionDemoScreen extends BaseDemoScreen {
  const SlideDirectionDemoScreen({super.key});

  @override
  State<SlideDirectionDemoScreen> createState() =>
      _SlideDirectionDemoScreenState();
}

class _SlideDirectionDemoScreenState
    extends BaseDemoScreenState<SlideDirectionDemoScreen> {
  final GlobalKey<TickerWidgetState> _tickerKey = GlobalKey();
  ScrollingDirection _currentDirection = ScrollingDirection.any;
  String _currentText = "12345";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slide Direction Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Direction: ${_getDirectionName(_currentDirection)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            TickerWidget(
              key: _tickerKey,
              text: _currentText,
              textSize: 40,
              textColor: Colors.purple,
              characterLists: [TickerUtils.provideNumberList()],
              preferredScrollingDirection: _currentDirection,
              animationDuration: 1200,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentDirection = ScrollingDirection.up;
                      _tickerKey.currentState?.setText(_currentText);
                    });
                  },
                  child: const Text('Up'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentDirection = ScrollingDirection.down;
                      _tickerKey.currentState?.setText(_currentText);
                    });
                  },
                  child: const Text('Down'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentDirection = ScrollingDirection.any;
                      _tickerKey.currentState?.setText(_currentText);
                    });
                  },
                  child: const Text('Any'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDirectionName(ScrollingDirection direction) {
    switch (direction) {
      case ScrollingDirection.up:
        return 'Up';
      case ScrollingDirection.down:
        return 'Down';
      case ScrollingDirection.any:
        return 'Any (Shortest Path)';
    }
  }

  @override
  void onUpdate() {
    setState(() {
      _currentText = getRandomNumber(5);
      _tickerKey.currentState?.setText(_currentText);
    });
  }
}
