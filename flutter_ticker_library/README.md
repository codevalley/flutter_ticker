# Flutter Ticker

A Flutter widget for smooth, animated text transitions with scrolling effects. This library provides a customizable ticker widget that animates text changes with a scrolling effect, similar to what you might see in financial tickers, departure boards, or digital clocks.

## Features

- Smooth scrolling animations when text changes
- Customizable animation duration, curve, and direction
- Support for different character sets (numbers, alphabets, custom characters)
- Flexible alignment and positioning options
- Precise character spacing and layout control
- Optimized text rendering with custom painting

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ticker: ^0.1.0
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ticker/flutter_ticker.dart';

class TickerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TickerWidget(
      text: "12345",
      textSize: 24.0,
      textColor: Colors.blue,
      characterLists: [TickerUtils.provideNumberList()],
    );
  }
}
```

### Customizing the Ticker

```dart
TickerWidget(
  text: "FLUTTER",
  textSize: 30.0,
  textColor: Colors.orange,
  characterLists: [TickerUtils.provideAlphabeticalList()],
  preferredScrollingDirection: ScrollingDirection.up,
  animationDuration: 800,
  animationCurve: Curves.easeOutQuad,
  gravity: Alignment.center,
  letterSpacing: 2.0,
)
```

### Updating Text with Animation

```dart
// Store a reference to the ticker state
final GlobalKey<TickerWidgetState> tickerKey = GlobalKey();

// In your widget build method
TickerWidget(
  key: tickerKey,
  text: "0.00",
  textSize: 24.0,
  textColor: Colors.green,
  characterLists: [TickerUtils.provideNumberList() + "."],
)

// Later, update the text with animation
tickerKey.currentState?.setText("42.50");
```

### Customizing Animation Duration

```dart
// Change the animation duration dynamically
tickerKey.currentState?.setAnimationDuration(1200);
```

## API Reference

### TickerWidget

The main widget that displays animated text transitions.

#### Constructor Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `String?` | Initial text to display |
| `textColor` | `Color` | Color of the text |
| `textSize` | `double` | Size of the text |
| `textStyle` | `TextStyle?` | Custom text style (color and size will be overridden) |
| `animationDuration` | `int` | Duration of the animation in milliseconds |
| `animationCurve` | `Curve` | Animation curve to use |
| `preferredScrollingDirection` | `ScrollingDirection` | Preferred direction for scrolling animations |
| `gravity` | `Alignment` | Alignment of the text within the widget |
| `animateMeasurementChange` | `bool` | Whether to animate changes in widget size |
| `animationDelay` | `int` | Delay before animation starts in milliseconds |
| `characterLists` | `List<String>?` | Lists of characters to use for animations |
| `letterSpacing` | `double` | Spacing between characters |
| `padding` | `EdgeInsets` | Padding around the text |

### TickerWidgetState

The state object for the TickerWidget, which provides methods to control the widget.

#### Methods

| Method | Description |
|--------|-------------|
| `setText(String text)` | Updates the displayed text with animation |
| `setAnimationDuration(int durationMillis)` | Changes the animation duration |

### TickerUtils

Utility class providing helper methods for the ticker.

#### Methods

| Method | Description |
|--------|-------------|
| `provideNumberList()` | Returns a string containing numerical characters (0-9) |
| `provideAlphabeticalList()` | Returns a string containing alphabetical characters (a-z, A-Z) |

### ScrollingDirection

Enum defining the direction of scrolling animations.

| Value | Description |
|-------|-------------|
| `up` | Scroll from bottom to top |
| `down` | Scroll from top to bottom |
| `any` | Automatically choose the shortest path |

## License

This project is licensed under the Apache License, Version 2.0 - see the LICENSE file for details.

## Attribution

This library is based on the original [Ticker](https://github.com/robinhood/ticker) implementation by Robinhood Markets, Inc. and has been refactored into a Flutter library with clean architecture by Narayan Babu.

The implementation follows clean architecture principles with separation of concerns:

- **State Management Layer**: Implemented through domain entities like `ticker_column_manager.dart`
- **Business Logic Layer**: Core logic in entities like `ticker_character_list.dart` and `ticker_column.dart`
- **Presentation Layer**: UI components in `ticker_widget.dart`
