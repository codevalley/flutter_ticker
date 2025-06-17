import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ticker/ticker.dart';

import 'animation_start_demo.dart';
import 'character_count_demo.dart';
import 'interactive_demo.dart';

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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StyledDemoScreen()),
                );
              },
              child: const Text('Styled Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InteractiveDemoScreen()),
                );
              },
              child: const Text('Interactive Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnimationStartDemoScreen()),
                );
              },
              child: const Text('Animation Start Demo'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CharacterCountDemoScreen()),
                );
              },
              child: const Text('Character Count Demo'),
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
  bool _isContinuousMode = true; // Flag to control continuous vs manual mode

  @override
  void initState() {
    super.initState();
    _isActive = true;
    if (_isContinuousMode) {
      _scheduleUpdate();
    }
  }

  @override
  void dispose() {
    _isActive = false;
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleUpdate() {
    _timer = Timer(Duration(milliseconds: random.nextInt(1750) + 250), () {
      if (_isActive && _isContinuousMode) {
        onUpdate();
        _scheduleUpdate();
      }
    });
  }

  // Toggle between continuous and manual modes
  void toggleUpdateMode() {
    setState(() {
      _isContinuousMode = !_isContinuousMode;
      if (_isContinuousMode) {
        _scheduleUpdate();
      } else {
        _timer?.cancel();
      }
    });
  }

  // Manually trigger an update (for manual mode)
  void manualUpdate() {
    if (!_isContinuousMode) {
      onUpdate();
    }
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
  final String alphabetList = 'abcdefghijklmnopqrstuvwxyz';

  final GlobalKey<TickerWidgetState> _ticker1Key = GlobalKey();
  final GlobalKey<TickerWidgetState> _ticker2Key = GlobalKey();
  final GlobalKey<TickerWidgetState> _ticker3Key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Add a toggle button for update mode
          IconButton(
            icon: Icon(_isContinuousMode ? Icons.loop : Icons.touch_app),
            onPressed: toggleUpdateMode,
            tooltip: _isContinuousMode
                ? 'Switch to Manual Mode'
                : 'Switch to Continuous Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mode indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Mode: ${_isContinuousMode ? "Continuous (Auto)" : "Manual (Tap to Update)"}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isContinuousMode ? Colors.blue : Colors.green,
                      ),
                ),
              ),

              // Manual update button (only visible in manual mode)
              if (!_isContinuousMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: manualUpdate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update Values'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // Ticker with downward scrolling
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Up Direction Scrolling (Numbers)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _ticker1Key,
                        text: '12345678',
                        textSize: 30,
                        textColor: Colors.blue,
                        characterLists: [TickerUtils.provideNumberList()],
                        preferredScrollingDirection: ScrollingDirection.up,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ticker with downward scrolling and currency
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Down Direction Scrolling (Currency)',
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
                            text: '0.00',
                            textSize: 30,
                            textColor: Colors.green,
                            characterLists: [
                              '${TickerUtils.provideNumberList()}.'
                            ],
                            preferredScrollingDirection:
                                ScrollingDirection.down,
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
                        text: 'flutter',
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
        actions: [
          // Add a toggle button for update mode
          IconButton(
            icon: Icon(_isContinuousMode ? Icons.loop : Icons.touch_app),
            onPressed: toggleUpdateMode,
            tooltip: _isContinuousMode
                ? 'Switch to Manual Mode'
                : 'Switch to Continuous Mode',
          ),
          // Add manual update button when in manual mode
          if (!_isContinuousMode)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: manualUpdate,
              tooltip: 'Manually Update Tickers',
            ),
        ],
      ),
      body: Column(
        children: [
          // Mode indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Mode: ${_isContinuousMode ? 'Continuous (Auto)' : 'Manual (Tap to Update)'}',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isContinuousMode ? Colors.blue : Colors.green,
                  ),
            ),
          ),
          // List of tickers
          Expanded(
            child: ListView.builder(
              itemCount: _tickerKeys.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TickerWidget(
                        key: _tickerKeys[index],
                        text: getRandomNumber(8),
                        textSize: 24,
                        textColor: Colors.indigo,
                        characterLists: [TickerUtils.provideNumberList()],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
  String _currentText = '12345';

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
      default:
        return ''; // This line is added to satisfy the Dart analyzer
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

// Styled Demo Screen to showcase different text styles
class StyledDemoScreen extends BaseDemoScreen {
  const StyledDemoScreen({super.key});

  @override
  State<StyledDemoScreen> createState() => _StyledDemoScreenState();
}

class _StyledDemoScreenState extends BaseDemoScreenState<StyledDemoScreen> {
  final GlobalKey<TickerWidgetState> _standardTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _boldWholeNumbersTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _coloredPartsTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _mixedStylesTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _currencyTickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set initial values
    _standardTickerKey.currentState?.setText('1234.56');
    _boldWholeNumbersTickerKey.currentState?.setText('1234.56');
    _coloredPartsTickerKey.currentState?.setText('1234.56');
    _mixedStylesTickerKey.currentState?.setText('1234.56');
    _currencyTickerKey.currentState?.setText('1234.56');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Styled Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Add a toggle button for update mode
          IconButton(
            icon: Icon(_isContinuousMode ? Icons.loop : Icons.touch_app),
            onPressed: toggleUpdateMode,
            tooltip: _isContinuousMode
                ? 'Switch to Manual Mode'
                : 'Switch to Continuous Mode',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mode indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Mode: ${_isContinuousMode ? "Continuous (Auto)" : "Manual (Tap to Update)"}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isContinuousMode ? Colors.blue : Colors.green,
                      ),
                ),
              ),

              // Manual update button (only visible in manual mode)
              if (!_isContinuousMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: manualUpdate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update Values'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // Standard Ticker (no custom styling)
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Standard (No Custom Styling)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _standardTickerKey,
                        text: '1234.56',
                        textSize: 30,
                        textColor: Colors.black,
                        characterLists: ['${TickerUtils.provideNumberList()}.'],
                        preferredScrollingDirection: ScrollingDirection.up,
                      ),
                    ],
                  ),
                ),
              ),

              // Bold Whole Numbers Ticker
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Bold Whole Numbers',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _boldWholeNumbersTickerKey,
                        text: '1234.56',
                        textSize: 30,
                        textColor: Colors.black,
                        wholeNumberStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        characterLists: ['${TickerUtils.provideNumberList()}.'],
                        preferredScrollingDirection: ScrollingDirection.up,
                      ),
                    ],
                  ),
                ),
              ),

              // Colored Parts Ticker
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Colored Parts',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _coloredPartsTickerKey,
                        text: '1234.56',
                        textSize: 30,
                        wholeNumberStyle: const TextStyle(
                          color: Colors.blue,
                        ),
                        decimalPointStyle: const TextStyle(
                          color: Colors.red,
                        ),
                        decimalDigitsStyle: const TextStyle(
                          color: Colors.green,
                        ),
                        characterLists: ['${TickerUtils.provideNumberList()}.'],
                        preferredScrollingDirection: ScrollingDirection.up,
                      ),
                    ],
                  ),
                ),
              ),

              // Mixed Styles Ticker
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Mixed Styles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _mixedStylesTickerKey,
                        text: '1234.56',
                        textSize: 30,
                        wholeNumberStyle: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                        decimalPointStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 35, // Slightly larger decimal point
                        ),
                        decimalDigitsStyle: const TextStyle(
                          color: Colors.teal,
                          fontStyle: FontStyle.italic,
                        ),
                        characterLists: ['${TickerUtils.provideNumberList()}.'],
                        preferredScrollingDirection: ScrollingDirection.up,
                      ),
                    ],
                  ),
                ),
              ),

              // Currency Ticker with Symbol
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Currency with Symbol',
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
                              color: Colors.green,
                            ),
                          ),
                          TickerWidget(
                            key: _currencyTickerKey,
                            text: '1234.56',
                            textSize: 30,
                            wholeNumberStyle: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            decimalPointStyle: const TextStyle(
                              color: Colors.green,
                            ),
                            decimalDigitsStyle: const TextStyle(
                              color: Colors.green,
                              fontSize: 24, // Smaller decimal part
                            ),
                            characterLists: [
                              '${TickerUtils.provideNumberList()}.'
                            ],
                            preferredScrollingDirection:
                                ScrollingDirection.down,
                          ),
                        ],
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

  @override
  void onUpdate() {
    setState(() {
      // Generate random price with 2 decimal places
      final intPart = BaseDemoScreenState.random.nextInt(10000);
      final decimalPart =
          BaseDemoScreenState.random.nextInt(100).toString().padLeft(2, '0');
      final newValue = '$intPart.$decimalPart';

      // Update all tickers with the same value
      _standardTickerKey.currentState?.setText(newValue);
      _boldWholeNumbersTickerKey.currentState?.setText(newValue);
      _coloredPartsTickerKey.currentState?.setText(newValue);
      _mixedStylesTickerKey.currentState?.setText(newValue);
      _currencyTickerKey.currentState?.setText(newValue);
    });
  }
}
