import 'package:flutter/material.dart';
import 'package:ticker/ticker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ticker Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<TickerWidgetState> _numberTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _priceTickerKey = GlobalKey();
  final GlobalKey<TickerWidgetState> _textTickerKey = GlobalKey();

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;

      // Update number ticker
      _numberTickerKey.currentState?.setText(_counter.toString());

      // Update price ticker
      final price = (_counter * 1.25).toStringAsFixed(2);
      _priceTickerKey.currentState?.setText(price);

      // Update text ticker with alternating text
      if (_counter % 2 == 0) {
        _textTickerKey.currentState?.setText('FLUTTER');
      } else {
        _textTickerKey.currentState?.setText('TICKER');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Ticker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Number ticker
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Number Ticker',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TickerWidget(
                      key: _numberTickerKey,
                      text: '0',
                      textSize: 30,
                      textColor: Colors.blue,
                      characterLists: [TickerUtils.provideNumberList()],
                      preferredScrollingDirection: ScrollingDirection.up,
                    ),
                  ],
                ),
              ),
            ),

            // Price ticker
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                          text: '0.00',
                          textSize: 30,
                          textColor: Colors.green,
                          characterLists: [
                            '${TickerUtils.provideNumberList()}.'
                          ],
                          preferredScrollingDirection: ScrollingDirection.down,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Text ticker
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Text Ticker',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TickerWidget(
                      key: _textTickerKey,
                      text: 'FLUTTER',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Update Values',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
