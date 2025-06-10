## 0.3.0

* Added support for different text styles for different parts of numeric values:
  * `wholeNumberStyle` - Apply custom styling to digits before the decimal point
  * `decimalPointStyle` - Apply custom styling to the decimal point character
  * `decimalDigitsStyle` - Apply custom styling to digits after the decimal point
* This enables more visually distinct number displays, particularly useful for:
  * Financial data where you want to emphasize whole numbers over decimals
  * Scoreboard or dashboard displays with mixed styling needs
  * Currency formatting with different visual treatments for decimal parts

## 0.2.2

* Added `onAnimationComplete` callback to be notified when animations finish
  * Useful for chaining animations or updating UI after transitions complete
  * Follows clean architecture principles by providing a clear interface between presentation and business logic

## 0.2.1

* Enhanced the `animate()` method functionality:
  * Improved to animate from `initialValue` to current text when called without parameters
  * Added ability to animate from `initialValue` to a new value when called with a parameter
  * This provides a powerful way to replay initial animations or reset to initial state

## 0.2.0

* Added new features to enhance ticker functionality:
  * Added `initialValue` property to set a starting value before animation
  * Added `animateOnLoad` property to control whether animation happens on first render
  * Added `animate()` method for programmatic animation control

## 0.1.3

* Updated LICENSE and NOTICE files to meet pub.dev requirements

## 0.1.2

* Fixed critical animation issues:
  * Resolved character dropping issue in the Levenshtein algorithm implementation
  * Improved animation continuity for smooth transitions between text states
  * Enhanced ticker column behavior to handle edge cases properly
* Optimized widget performance:
  * Reduced unnecessary state updates during animations
  * Improved animation timing and synchronization
  * Fixed initialization issues in the interactive demo
* Improved code structure following clean architecture principles:
  * Fixed import paths for better code organization
  * Corrected documentation references for better API clarity
  * Enhanced separation between domain and presentation layers

## 0.1.1

* Fixed lint issues across the library:
  * Updated constant names to follow lowerCamelCase convention (e.g., `EMPTY_CHAR` to `emptyChar`)
  * Fixed comment references in documentation to ensure proper visibility
  * Improved code formatting and documentation clarity
* Enhanced code quality and maintainability
* Ensured compatibility with Flutter's latest style guidelines

## 0.1.0

* Initial release of the Flutter Ticker library
* Core features:
  * Smooth scrolling animations for text transitions
  * Customizable animation duration, curve, and direction
  * Support for different character sets (numbers, alphabets, custom characters)
  * Flexible alignment and positioning options
  * Precise character spacing and layout control
* Includes comprehensive documentation and examples
