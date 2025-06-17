# Flutter Ticker

A Flutter widget for smooth, animated text transitions with scrolling effects. This library provides a customizable ticker widget that animates text changes with a scrolling effect, similar to what you might see in financial tickers, departure boards, or digital clocks.

## Features

- Smooth scrolling animations when text changes
- Initial value support with optional animation on first render
- Programmatic animation control with the animate() method
- Customizable animation duration, curve, and direction
- Support for different character sets (numbers, alphabets, custom characters)
- Flexible alignment and positioning options
- Precise character spacing and layout control
- Optimized text rendering with custom painting
- Different text styles for whole numbers, decimal point, and decimal digits

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ticker: ^0.3.0
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:ticker/ticker.dart';

class TickerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TickerWidget(
      initialValue: "00000",  // Initial value to display
      text: "12345",         // Target text to animate to
      animateOnLoad: true,    // Animate from initialValue to text on first render
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
  initialValue: "0.00",  // Initial value to display
  text: "0.00",         // Starting text (same as initialValue in this case)
  textSize: 24.0,
  textColor: Colors.green,
  characterLists: [TickerUtils.provideNumberList() + "."],
  onAnimationComplete: () {
    // This will be called when the animation completes
    print('Animation completed!');
    // You can update state, trigger another animation, etc.
  },
)

// Later, update the text with animation
tickerKey.currentState?.setText("42.50");

// Animate from initialValue to the current value (replay initial animation)
tickerKey.currentState?.animate();

// Animate from initialValue to a new value
tickerKey.currentState?.animate("99.99");
```

### Styling Different Parts of Numeric Values

```dart
// For displaying currency with emphasized whole numbers and smaller decimal digits
TickerWidget(
  text: "1234.56",
  textSize: 30.0,
  // Style for whole numbers (before decimal point)
  wholeNumberStyle: const TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.bold,
  ),
  // Style for decimal point
  decimalPointStyle: const TextStyle(
    color: Colors.green,
  ),
  // Style for decimal digits (after decimal point)
  decimalDigitsStyle: const TextStyle(
    color: Colors.green,
    fontSize: 24.0, // Smaller decimal digits
    fontStyle: FontStyle.italic,
  ),
  characterLists: [TickerUtils.provideNumberList() + "."],
  preferredScrollingDirection: ScrollingDirection.down,
)
```

### Customizing Animation Duration

```dart
// Change the animation duration dynamically
tickerKey.currentState?.setAnimationDuration(1200);
```

### Configuring Initial Animation Starting Position

By default, ticker animations start from the first character (e.g., '0' for numbers) on initial load. You can customize this behavior using the `animationStartConfig` parameter:

```dart
// Default behavior - initial animation starts from first character (e.g., '0')
TickerWidget(
  text: "123",
  // No animationStartConfig needed - defaults to starting from '0'
  characterLists: [TickerUtils.provideNumberList()],
)

// Explicitly disable initial animation (show value immediately)
TickerWidget(
  text: "456",
  animationStartConfig: const TickerAnimationStartConfig.current(),
  characterLists: [TickerUtils.provideNumberList()],
)

// Initial animation starts from a specific character
TickerWidget(
  text: "789",
  animationStartConfig: const TickerAnimationStartConfig.specific('5'),
  characterLists: [TickerUtils.provideNumberList()],
)

// Initial animation starts from a random character
TickerWidget(
  text: "321",
  animationStartConfig: TickerAnimationStartConfig.random(),
  characterLists: [TickerUtils.provideNumberList()],
)

// Initial animation starts from the last character (e.g., '9' for numbers)
TickerWidget(
  text: "654",
  animationStartConfig: const TickerAnimationStartConfig.last(),
  characterLists: [TickerUtils.provideNumberList()],
)
```

#### Animation Start Configuration Options

- **Default (no config)**: Initial animation starts from the first character in the character list (e.g., '0' for numbers)
- **`TickerAnimationStartConfig.current()`**: No initial animation - shows target value immediately
- **`TickerAnimationStartConfig.first()`**: Same as default - initial animation starts from the first character
- **`TickerAnimationStartConfig.last()`**: Initial animation starts from the last character in the character list
- **`TickerAnimationStartConfig.random()`**: Initial animation starts from a random character
- **`TickerAnimationStartConfig.specific(char)`**: Initial animation starts from a specific character

**Important**: This configuration only applies to the initial/first animation. All subsequent animations maintain natural fluidity by starting from the current character position.

### Smooth Character Count Transitions

The ticker automatically handles character count changes with improved animations:

```dart
// When animating from "999" to "1000":
// Old behavior: 999 → 000 → 1000 (jarring layout shift)
// New behavior: 999 → 0999 → 1000 (smooth transition)

TickerWidget(
  text: "1000", // Will smoothly transition from previous value
  characterLists: [TickerUtils.provideNumberList()],
)
```

#### How Character Count Changes Work

- **Growing (999 → 1000)**: New characters are added with appropriate starting positions, then all characters animate to final values
- **Shrinking (1000 → 999)**: Excess characters animate to empty and are removed gracefully  
- **Numbers**: Additional characters are added at the beginning (leading zeros)
- **Text**: Characters are balanced between start and end for natural flow
- **No layout shifts**: Final layout is established immediately to prevent jarring transitions

## API Reference

### TickerWidget

The main widget that displays animated text transitions.

#### Constructor Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `String?` | Target text to display and animate to |
| `initialValue` | `String?` | Initial text to display before animation |
| `animateOnLoad` | `bool` | Whether to animate from initialValue to text on first render |
| `onAnimationComplete` | `VoidCallback?` | Callback that is called when the animation completes |
| `animationStartConfig` | `TickerAnimationStartConfig?` | Configuration for controlling animation starting position |
| `textColor` | `Color` | Color of the text |
| `textSize` | `double` | Size of the text |
| `textStyle` | `TextStyle?` | Custom text style (color and size will be overridden) |
| `wholeNumberStyle` | `TextStyle?` | Style for digits before the decimal point |
| `decimalPointStyle` | `TextStyle?` | Style for the decimal point character |
| `decimalDigitsStyle` | `TextStyle?` | Style for digits after the decimal point |
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
| `animate([String? newText])` | Triggers animation from initialValue to the current text, or to a new text if provided |
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
