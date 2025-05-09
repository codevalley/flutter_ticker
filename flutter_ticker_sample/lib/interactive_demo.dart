import 'package:flutter/material.dart';
import 'package:ticker/ticker.dart';

class InteractiveDemoScreen extends StatefulWidget {
  const InteractiveDemoScreen({super.key});

  @override
  State<InteractiveDemoScreen> createState() => _InteractiveDemoScreenState();
}

class _InteractiveDemoScreenState extends State<InteractiveDemoScreen> {
  int _counter = 0;
  String _price = '0.00';
  String _time = '00:00:00';
  ScrollingDirection _scrollDirection = ScrollingDirection.any;
  double _letterSpacing = 1.0;
  int _animationDuration = 990;

  // References to ticker widgets for direct text updates
  final GlobalKey<TickerWidgetState> _counterTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _priceTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _timeTickerKey = GlobalKey();

  void _incrementCounter() {
    setState(() {
      _counter++;

      // Update the counter ticker
      _counterTickerKey.currentState?.setText(_counter.toString());

      // Update the price ticker with a random price
      final newPrice = (100 + (_counter % 900)) / 100;
      _price = newPrice.toStringAsFixed(2);
      _priceTickerKey.currentState?.setText(_price);

      // Update the time ticker
      final now = DateTime.now();
      _time =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      _timeTickerKey.currentState?.setText(_time);
    });
  }

  void _changeScrollDirection() {
    setState(() {
      // Cycle through the scrolling directions
      switch (_scrollDirection) {
        case ScrollingDirection.any:
          _scrollDirection = ScrollingDirection.up;
          break;
        case ScrollingDirection.up:
          _scrollDirection = ScrollingDirection.down;
          break;
        case ScrollingDirection.down:
          _scrollDirection = ScrollingDirection.any;
          break;
      }
    });
  }

  void _increaseLetterSpacing() {
    setState(() {
      _letterSpacing += 0.5;
    });
  }

  void _decreaseLetterSpacing() {
    setState(() {
      if (_letterSpacing > 0.5) {
        _letterSpacing -= 0.5;
      }
    });
  }

  void _increaseAnimationDuration() {
    setState(() {
      _animationDuration += 100;
      _updateAnimationDuration();
    });
  }

  void _decreaseAnimationDuration() {
    setState(() {
      if (_animationDuration > 100) {
        _animationDuration -= 100;
        _updateAnimationDuration();
      }
    });
  }

  void _updateAnimationDuration() {
    _counterTickerKey.currentState?.setAnimationDuration(_animationDuration);
    _priceTickerKey.currentState?.setAnimationDuration(_animationDuration);
    _timeTickerKey.currentState?.setAnimationDuration(_animationDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Interactive Demo'),
        actions: [
          // Button to change scrolling direction
          IconButton(
            icon: const Icon(Icons.swap_vert),
            onPressed: _changeScrollDirection,
            tooltip: 'Change scroll direction',
          ),
          // Button to increase letter spacing
          IconButton(
            icon: const Icon(Icons.format_line_spacing),
            onPressed: _increaseLetterSpacing,
            tooltip: 'Increase letter spacing',
          ),
          // Button to decrease letter spacing
          IconButton(
            icon: const Icon(Icons.format_align_justify),
            onPressed: _decreaseLetterSpacing,
            tooltip: 'Decrease letter spacing',
          ),
          // Button to increase animation duration
          IconButton(
            icon: const Icon(Icons.slow_motion_video),
            onPressed: _increaseAnimationDuration,
            tooltip: 'Increase animation duration',
          ),
          // Button to decrease animation duration
          IconButton(
            icon: const Icon(Icons.speed),
            onPressed: _decreaseAnimationDuration,
            tooltip: 'Decrease animation duration',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display the current settings
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Scrolling Direction: ${_scrollDirection.name.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Letter Spacing: ${_letterSpacing.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Animation Duration: ${_animationDuration}ms',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Counter ticker with numbers only
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Counter (Numbers Only)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _counterTickerKey,
                        text: _counter.toString(),
                        textSize: 40,
                        textColor: Colors.deepPurple,
                        characterLists: [TickerUtils.provideNumberList()],
                        preferredScrollingDirection: _scrollDirection,
                        animationDuration: _animationDuration,
                        gravity: Alignment.center,
                        letterSpacing: _letterSpacing,
                      ),
                    ],
                  ),
                ),
              ),

              // Price ticker with numbers and decimal point
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Price Ticker',
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
                            key: _priceTickerKey,
                            text: _price,
                            textSize: 30,
                            textColor: Colors.green,
                            characterLists: [
                              '${TickerUtils.provideNumberList()}.',
                            ],
                            preferredScrollingDirection: _scrollDirection,
                            animationDuration: _animationDuration,
                            gravity: Alignment.center,
                            letterSpacing: _letterSpacing,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Time ticker with numbers and colon
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Time Ticker',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        key: _timeTickerKey,
                        text: _time,
                        textSize: 30,
                        textColor: Colors.blue,
                        characterLists: ['${TickerUtils.provideNumberList()}:'],
                        preferredScrollingDirection: _scrollDirection,
                        animationDuration: _animationDuration,
                        gravity: Alignment.center,
                        letterSpacing: _letterSpacing,
                      ),
                    ],
                  ),
                ),
              ),

              // Alphabet ticker demo
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Alphabet Ticker',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TickerWidget(
                        text: 'FLUTTER',
                        textSize: 30,
                        textColor: Colors.orange,
                        characterLists: [TickerUtils.provideAlphabeticalList()],
                        preferredScrollingDirection: _scrollDirection,
                        animationDuration: _animationDuration,
                        gravity: Alignment.center,
                        letterSpacing: _letterSpacing,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Update Values',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
