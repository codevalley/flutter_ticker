// ignore_for_file: prefer_single_quotes

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../../src/core/utils/ticker_utils.dart';
import 'ticker_character_list.dart';

/// This class represents core drawing metrics that the Ticker widget requires
/// to calculate positions and offsets for rendering text onto the canvas.
class TickerDrawMetrics {
  /// The text style used for measuring and drawing text
  final TextStyle textStyle;
  
  /// The text style for whole numbers (before decimal point)
  final TextStyle wholeNumberStyle;
  
  /// The text style for the decimal point
  final TextStyle decimalPointStyle;
  
  /// The text style for decimal digits (after decimal point)
  final TextStyle decimalDigitsStyle;

  /// The text direction used for measuring text
  final TextDirection textDirection;

  /// Cache of character widths for performance optimization
  final Map<String, double> _charWidths = {};
  
  /// Cache of character widths for whole numbers
  final Map<String, double> _wholeNumberCharWidths = {};
  
  /// Cache of decimal point width
  double _decimalPointWidth = 0;
  
  /// Cache of character widths for decimal digits
  final Map<String, double> _decimalDigitsCharWidths = {};

  /// Height of characters based on the text style
  double _charHeight = 0;

  /// Baseline position for text rendering
  double _charBaseline = 0;

  /// The preferred scrolling direction for animations
  ScrollingDirection _preferredScrollingDirection = ScrollingDirection.any;
  
  /// Index of the decimal point in the text (for styling)
  int _decimalPointIndex = -1;

  /// Creates a new TickerDrawMetrics with the given text style
  TickerDrawMetrics({
    required this.textStyle,
    TextStyle? wholeNumberStyle,
    TextStyle? decimalPointStyle,
    TextStyle? decimalDigitsStyle,
    this.textDirection = TextDirection.ltr,
  }) : 
    wholeNumberStyle = wholeNumberStyle ?? textStyle,
    decimalPointStyle = decimalPointStyle ?? textStyle,
    decimalDigitsStyle = decimalDigitsStyle ?? textStyle {
    _invalidate();
  }

  /// Clears cached measurements and recalculates metrics
  void _invalidate() {
    _charWidths.clear();
    _wholeNumberCharWidths.clear();
    _decimalPointWidth = 0;
    _decimalDigitsCharWidths.clear();

    // Create a paragraph to measure text metrics
    final textPainter = TextPainter(
      text: TextSpan(text: "0", style: textStyle),
      textDirection: textDirection,
    );

    textPainter.layout();

    // In Flutter, we can get the line metrics
    _charHeight = textPainter.height;

    // The baseline in Flutter is measured from the top of the text
    // This is an approximation as Flutter doesn't expose font metrics directly
    _charBaseline =
        textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  }
  
  /// Sets the decimal point index in the text
  void setDecimalPointIndex(int index) {
    _decimalPointIndex = index;
  }
  
  /// Determines the appropriate TextStyle for a character at a given position
  TextStyle getTextStyleForPosition(int position, String character) {
    if (position < 0) {
      return textStyle;
    }
    
    if (_decimalPointIndex == -1) {
      // No decimal point in the text, use whole number style for all characters
      return wholeNumberStyle;
    }
    
    if (position < _decimalPointIndex) {
      // Character is before the decimal point
      return wholeNumberStyle;
    } else if (position == _decimalPointIndex) {
      // Character is the decimal point
      return decimalPointStyle;
    } else {
      // Character is after the decimal point
      return decimalDigitsStyle;
    }
  }

  /// Gets the width of a character with precise measurement
  double getCharWidth(String character, [int position = -1]) {
    if (character == TickerUtils.emptyChar) {
      return 0;
    }
    
    // Determine which cache and style to use based on position
    late Map<String, double> widthCache;
    late TextStyle style;
    
    if (position < 0 || _decimalPointIndex == -1) {
      // Default case: use the primary cache and style
      widthCache = _charWidths;
      style = textStyle;
    } else if (position < _decimalPointIndex) {
      // Before decimal point: use whole number cache and style
      widthCache = _wholeNumberCharWidths;
      style = wholeNumberStyle;
    } else if (position == _decimalPointIndex) {
      // Decimal point: use decimal point style
      if (_decimalPointWidth > 0) {
        return _decimalPointWidth;
      }
      style = decimalPointStyle;
    } else {
      // After decimal point: use decimal digits cache and style
      widthCache = _decimalDigitsCharWidths;
      style = decimalDigitsStyle;
    }

    // Lazy initialization of character width
    if (position == _decimalPointIndex) {
      // For the decimal point
      final textPainter = TextPainter(
        textScaler: const TextScaler.linear(1.0),
        text: TextSpan(text: character, style: style),
        textDirection: textDirection,
      );

      textPainter.layout(minWidth: 0, maxWidth: double.infinity);
      _decimalPointWidth = textPainter.width;
      return _decimalPointWidth;
    } else if (widthCache.containsKey(character)) {
      // Return from cache if available
      return widthCache[character]!;
    } else {
      // For accurate width measurement, we need to consider the text scale factor
      final textPainter = TextPainter(
        textScaler: const TextScaler.linear(1.0),
        text: TextSpan(text: character, style: style),
        textDirection: textDirection,
      );

      // Layout with no constraints for natural size
      textPainter.layout(minWidth: 0, maxWidth: double.infinity);
      final width = textPainter.width;

      widthCache[character] = width;
      return width;
    }
  }

  /// Gets the exact size (width and height) of a character
  Size getCharSize(String character, [int position = -1]) {
    if (character == TickerUtils.emptyChar) {
      return Size(0, _charHeight);
    }
    
    // Determine which style to use based on position
    TextStyle style;
    
    if (position < 0 || _decimalPointIndex == -1) {
      // Default case: use the primary style
      style = textStyle;
    } else if (position < _decimalPointIndex) {
      // Before decimal point: use whole number style
      style = wholeNumberStyle;
    } else if (position == _decimalPointIndex) {
      // Decimal point: use decimal point style
      style = decimalPointStyle;
    } else {
      // After decimal point: use decimal digits style
      style = decimalDigitsStyle;
    }

    final textPainter = TextPainter(
      textScaler: const TextScaler.linear(1.0),
      text: TextSpan(text: character, style: style),
      textDirection: textDirection,
    );

    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  /// Calculates the ideal spacing between two characters
  double getIdealSpacingBetween(
      String char1, String char2, double baseSpacing, [int position = -1]) {
    // If either character is empty, use base spacing
    if (char1 == TickerUtils.emptyChar || char2 == TickerUtils.emptyChar) {
      return baseSpacing;
    }

    // Get widths of both characters
    final width1 = getCharWidth(char1, position);
    final width2 = getCharWidth(char2, position + 1);

    // Base the spacing on character widths
    double spacingMultiplier = 1.0;

    // For very narrow characters, we might need less spacing
    if (width1 < 8.0 || width2 < 8.0) {
      spacingMultiplier = 0.9;
    }

    // For very wide characters, we might need more spacing
    if (width1 > 20.0 || width2 > 20.0) {
      spacingMultiplier = 1.1;
    }

    // Special handling for number pairs that need adjustment
    if (char1 == '1' && (char2 == '0' || char2 == '8')) {
      return baseSpacing * 1.2; // More space after 1 when followed by 0 or 8
    } else if ((char1 == '0' || char1 == '8') && char2 == '1') {
      return baseSpacing * 1.2; // More space before 1 when preceded by 0 or 8
    }

    // For narrow characters like 'i', 'l', 'I', '1', reduce spacing
    if ((char1 == 'i' || char1 == 'l' || char1 == 'I' || char1 == '1') &&
        (char2 != 'i' && char2 != 'l' && char2 != 'I' && char2 != '1')) {
      return baseSpacing * 0.9;
    }

    // For wide characters like 'm', 'w', 'M', 'W', increase spacing
    if ((char1 == 'm' || char1 == 'w' || char1 == 'M' || char1 == 'W') ||
        (char2 == 'm' || char2 == 'w' || char2 == 'M' || char2 == 'W')) {
      return baseSpacing * 1.1;
    }

    // Apply the spacing multiplier to the base spacing
    return baseSpacing * spacingMultiplier;
  }

  /// Gets the height of characters based on the current text style
  double getCharHeight() {
    return _charHeight;
  }

  /// Gets the baseline position for text rendering
  double getCharBaseline() {
    return _charBaseline;
  }

  /// Gets the preferred scrolling direction for animations
  ScrollingDirection getPreferredScrollingDirection() {
    return _preferredScrollingDirection;
  }

  /// Sets the preferred scrolling direction for animations
  void setPreferredScrollingDirection(ScrollingDirection direction) {
    _preferredScrollingDirection = direction;
  }
}
