import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ticker/ticker.dart';

class CharacterCountDemoScreen extends StatefulWidget {
  const CharacterCountDemoScreen({super.key});

  @override
  State<CharacterCountDemoScreen> createState() => _CharacterCountDemoScreenState();
}

class _CharacterCountDemoScreenState extends State<CharacterCountDemoScreen> {
  final Random _random = Random();
  
  // Test cases for different scenarios
  final List<List<String>> _numericTestCases = [
    ['99', '100'],      // 2 → 3 digits
    ['999', '1000'],    // 3 → 4 digits  
    ['9999', '10000'],  // 4 → 5 digits
    ['1000', '999'],    // 4 → 3 digits (shrinking)
    ['100', '99'],      // 3 → 2 digits (shrinking)
    ['50', '1500'],     // 2 → 4 digits (big jump)
  ];
  
  final List<List<String>> _textTestCases = [
    ['DOG', 'TIGER'],     // 3 → 5 characters
    ['CAT', 'ELEPHANT'],  // 3 → 8 characters
    ['HELLO', 'HI'],      // 5 → 2 characters (shrinking)
    ['A', 'AMAZING'],     // 1 → 7 characters
    ['FLUTTER', 'DART'],  // 7 → 4 characters (shrinking)
  ];

  int _currentNumericIndex = 0;
  int _currentTextIndex = 0;
  bool _showingFirst = true;

  // References to ticker widgets
  final GlobalKey<TickerWidgetState> _numericTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _textTickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // Initialize with first values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTickers();
    });
  }

  void _updateTickers() {
    final numericValue = _showingFirst 
        ? _numericTestCases[_currentNumericIndex][0]
        : _numericTestCases[_currentNumericIndex][1];
        
    final textValue = _showingFirst
        ? _textTestCases[_currentTextIndex][0] 
        : _textTestCases[_currentTextIndex][1];

    _numericTickerKey.currentState?.setText(numericValue);
    _textTickerKey.currentState?.setText(textValue);
  }

  void _toggleValues() {
    setState(() {
      _showingFirst = !_showingFirst;
      _updateTickers();
    });
  }

  void _nextNumericTest() {
    setState(() {
      _currentNumericIndex = (_currentNumericIndex + 1) % _numericTestCases.length;
      _showingFirst = true;
      _updateTickers();
    });
  }

  void _nextTextTest() {
    setState(() {
      _currentTextIndex = (_currentTextIndex + 1) % _textTestCases.length;
      _showingFirst = true;
      _updateTickers();
    });
  }

  void _randomNumericTest() {
    setState(() {
      // Generate random numbers with different digit counts
      final digits1 = _random.nextInt(3) + 1; // 1-3 digits
      final digits2 = _random.nextInt(3) + 3; // 3-5 digits
      
      final num1 = _random.nextInt(pow(10, digits1).toInt());
      final num2 = _random.nextInt(pow(10, digits2).toInt());
      
      _numericTestCases[_currentNumericIndex] = [num1.toString(), num2.toString()];
      _showingFirst = true;
      _updateTickers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentNumericTest = _numericTestCases[_currentNumericIndex];
    final currentTextTest = _textTestCases[_currentTextIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Count Change Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Information card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Improved Character Count Transitions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This demo showcases the improved animation behavior when the number of characters changes:\n\n'
                        '• Numbers: 999 → 0999 → 1000 (smooth layout establishment)\n'
                        '• Text: DOG → ADOGA → TIGER (balanced character addition)\n'
                        '• No sudden layout shifts or jarring transitions\n'
                        '• Respects animation start configuration',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Numeric transitions demo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Numeric Transitions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current test: ${currentNumericTest[0]} ↔ ${currentNumericTest[1]}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Numeric ticker
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TickerWidget(
                          key: _numericTickerKey,
                          text: currentNumericTest[0],
                          textSize: 48,
                          textColor: Colors.blue.shade700,
                          characterLists: [TickerUtils.provideNumberList()],
                          animationDuration: 1500,
                          gravity: Alignment.center,
                          animationStartConfig: const TickerAnimationStartConfig.first(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Numeric controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _toggleValues,
                            child: Text(_showingFirst ? 'Animate →' : '← Animate Back'),
                          ),
                          ElevatedButton(
                            onPressed: _nextNumericTest,
                            child: const Text('Next Test'),
                          ),
                          ElevatedButton(
                            onPressed: _randomNumericTest,
                            child: const Text('Random'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Text transitions demo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Text Transitions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current test: ${currentTextTest[0]} ↔ ${currentTextTest[1]}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Text ticker
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TickerWidget(
                          key: _textTickerKey,
                          text: currentTextTest[0],
                          textSize: 36,
                          textColor: Colors.green.shade700,
                          characterLists: [TickerUtils.provideAlphabeticalList()],
                          animationDuration: 1500,
                          gravity: Alignment.center,
                          animationStartConfig: const TickerAnimationStartConfig.first(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Text controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _toggleValues,
                            child: Text(_showingFirst ? 'Animate →' : '← Animate Back'),
                          ),
                          ElevatedButton(
                            onPressed: _nextTextTest,
                            child: const Text('Next Test'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Current test info
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How It Works',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. When character count increases: New characters are added with starting positions based on your configuration\n'
                        '2. Layout is established immediately to prevent shifts\n'
                        '3. All characters then animate smoothly to their final values\n'
                        '4. When character count decreases: Excess characters animate to empty and are removed\n'
                        '5. Numbers get leading characters, text gets balanced additions',
                        style: TextStyle(fontSize: 14),
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
} 