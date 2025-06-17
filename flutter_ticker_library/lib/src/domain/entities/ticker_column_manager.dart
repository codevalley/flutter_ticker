import 'package:flutter/material.dart';

import '../../../src/core/utils/ticker_utils.dart';
import 'ticker_animation_start_config.dart';
import 'ticker_character_list.dart';
import 'ticker_column.dart';
import 'ticker_draw_metrics.dart';

/// In ticker, each character in the rendered text is represented by a [TickerColumn]. The
/// column can be seen as a column of text in which we can animate from one character to the next
/// by scrolling the column vertically. The [TickerColumnManager] is then a
/// manager/convenience class for handling a list of [TickerColumn] which then combines into
/// the entire string we are rendering.
class TickerColumnManager {
  /// The list of ticker columns being managed
  final List<TickerColumn> tickerColumns = [];

  /// The metrics used for drawing characters
  final TickerDrawMetrics _metrics;

  /// The character lists used for animations
  List<TickerCharacterList>? _characterLists;

  /// The set of characters supported by the character lists
  Set<String>? _supportedCharacters;
  
  /// Index of the decimal point in the text (for styling)
  int _decimalPointIndex = -1;

  /// Configuration for animation starting behavior
  TickerAnimationStartConfig? _animationStartConfig;

  /// Whether this is the first animation (used for applyToAllAnimations logic)
  bool _isFirstAnimation = true;

  /// Creates a new ticker column manager with the given metrics
  TickerColumnManager(this._metrics);

  /// Sets the character lists to use for animations
  void setCharacterLists(List<String> characterLists) {
    _characterLists =
        characterLists.map((list) => TickerCharacterList(list)).toList();

    _supportedCharacters = <String>{};
    for (var list in _characterLists!) {
      _supportedCharacters!.addAll(list.getSupportedCharacters());
    }

    // Update character lists in current columns
    for (var tickerColumn in tickerColumns) {
      tickerColumn.setCharacterLists(_characterLists!);
    }
  }

  /// Gets the character lists used for animations
  List<TickerCharacterList>? getCharacterLists() {
    return _characterLists;
  }
  
  /// Gets the current decimal point index
  int getDecimalPointIndex() {
    return _decimalPointIndex;
  }
  
  /// Sets the decimal point index in the text (for styling)
  void setDecimalPointIndex(int index) {
    _decimalPointIndex = index;
    _metrics.setDecimalPointIndex(index);
    
    // Update position index for each column
    for (int i = 0; i < tickerColumns.length; i++) {
      tickerColumns[i].setPositionIndex(i);
    }
  }

  /// Sets the animation start configuration
  void setAnimationStartConfig(TickerAnimationStartConfig? config) {
    _animationStartConfig = config;
  }

  /// Tell the column manager the new target text that it should display.
  void setText(String text) {
    if (_characterLists == null) {
      throw StateError('Need to call #setCharacterLists first.');
    }

    // First remove any zero-width columns
    tickerColumns.removeWhere((column) => column.getCurrentWidth() <= 0);

    // Convert current text and new text to character arrays
    final List<String> currentTextChars = getCurrentText().split('');
    final List<String> newTextChars = text.split('');

    // Use improved two-phase animation approach for smoother transitions
    _setTextWithTwoPhaseAnimation(currentTextChars, newTextChars);
    
    // Update position index for each column after text changes
    for (int i = 0; i < tickerColumns.length; i++) {
      tickerColumns[i].setPositionIndex(i);
    }
    
    // Mark that we've completed the first animation
    _isFirstAnimation = false;
  }

  /// Implements a two-phase animation approach for smoother character count transitions
  void _setTextWithTwoPhaseAnimation(List<String> currentChars, List<String> newChars) {
    final int currentLength = currentChars.length;
    final int newLength = newChars.length;
    
    if (currentLength == newLength) {
      // Same length - use direct character-to-character animation
      _animateDirectCharacterChanges(currentChars, newChars);
    } else if (newLength > currentLength) {
      // Growing - add characters with smart positioning
      _animateGrowingText(currentChars, newChars);
    } else {
      // Shrinking - remove characters gracefully
      _animateShrinkingText(currentChars, newChars);
    }
  }

  /// Handles direct character-to-character animation when lengths are the same
  void _animateDirectCharacterChanges(List<String> currentChars, List<String> newChars) {
    // Ensure we have the right number of columns
    while (tickerColumns.length < newChars.length) {
      tickerColumns.add(TickerColumn(_characterLists!, _metrics));
    }
    while (tickerColumns.length > newChars.length) {
      tickerColumns.removeLast();
    }

    // Set target characters for each column
    for (int i = 0; i < newChars.length; i++) {
      _setTargetCharWithStartConfig(tickerColumns[i], newChars[i]);
    }
  }

  /// Handles growing text with smart character insertion
  void _animateGrowingText(List<String> currentChars, List<String> newChars) {
    final int currentLength = currentChars.length;
    final int newLength = newChars.length;
    final int additionalChars = newLength - currentLength;
    
    // Strategy: Add characters at the beginning to maintain visual balance
    // For numbers: 999 -> 0999 -> 1000
    // For words: DOG -> ADOGA -> TIGER (balanced addition)
    
    // First, create the intermediate state by adding characters
    final List<String> intermediateChars = <String>[];
    
    if (_isNumericText(newChars)) {
      // For numeric text, add at the beginning
      for (int i = 0; i < additionalChars; i++) {
        intermediateChars.add(_getStartingCharForPosition(0, newChars[0]));
      }
      intermediateChars.addAll(currentChars);
    } else {
      // For text, balance the addition (add some at start, some at end)
      final int startAdditions = additionalChars ~/ 2;
      final int endAdditions = additionalChars - startAdditions;
      
      // Add characters at the start
      for (int i = 0; i < startAdditions; i++) {
        intermediateChars.add(_getStartingCharForPosition(i, newChars[i]));
      }
      
      // Add existing characters
      intermediateChars.addAll(currentChars);
      
      // Add characters at the end
      for (int i = 0; i < endAdditions; i++) {
        final int targetIndex = newLength - endAdditions + i;
        intermediateChars.add(_getStartingCharForPosition(targetIndex, newChars[targetIndex]));
      }
    }

    // Ensure we have the right number of columns for the intermediate state
    while (tickerColumns.length < intermediateChars.length) {
      tickerColumns.add(TickerColumn(_characterLists!, _metrics));
    }

    // Phase 1: Set intermediate characters (this establishes the final layout)
    for (int i = 0; i < intermediateChars.length; i++) {
      if (i < currentLength) {
        // Existing columns keep their current character
        continue;
      } else {
        // New columns get the starting character
        tickerColumns[i].setCurrentChar(intermediateChars[i]);
      }
    }

    // Phase 2: Animate to final characters
    for (int i = 0; i < newChars.length; i++) {
      tickerColumns[i].setTargetChar(newChars[i]);
    }
  }

  /// Handles shrinking text with graceful character removal
  void _animateShrinkingText(List<String> currentChars, List<String> newChars) {
    final int currentLength = currentChars.length;
    final int newLength = newChars.length;
    
    // Strategy: Animate characters to empty first, then remove columns
    // This creates a smooth shrinking effect
    
    // Phase 1: Set target characters for remaining positions
    for (int i = 0; i < newLength; i++) {
      _setTargetCharWithStartConfig(tickerColumns[i], newChars[i]);
    }
    
    // Phase 2: Set excess characters to empty (they will animate out)
    for (int i = newLength; i < currentLength; i++) {
      tickerColumns[i].setTargetChar(TickerUtils.emptyChar);
    }
  }

  /// Determines if the text appears to be numeric
  bool _isNumericText(List<String> chars) {
    if (chars.isEmpty) return false;
    
    // Check if all characters are digits or common numeric symbols
    for (final char in chars) {
      if (!RegExp(r'[0-9.,]').hasMatch(char)) {
        return false;
      }
    }
    return true;
  }

  /// Gets the appropriate starting character for a position based on configuration
  String _getStartingCharForPosition(int position, String targetChar) {
    if (!_isFirstAnimation || _characterLists == null) {
      return targetChar;
    }

    // Use provided config or default to first character for backward compatibility
    final config = _animationStartConfig ?? const TickerAnimationStartConfig.first();
    
    // Find the appropriate character list for this target character
    for (final characterList in _characterLists!) {
      if (characterList.getSupportedCharacters().contains(targetChar)) {
        return config.getStartingCharacter(
          characterList.characterList.sublist(1, characterList.numOriginalCharacters + 1),
          targetChar
        );
      }
    }
    
    // Fallback to target character if no suitable list found
    return targetChar;
  }

  /// Helper method to set target character with animation start configuration
  void _setTargetCharWithStartConfig(TickerColumn column, String targetChar) {
    // Apply start configuration on the very first animation
    // Default behavior is to start from first character (backward compatibility)
    final bool shouldApplyConfig = _isFirstAnimation;
    
    if (shouldApplyConfig && _characterLists != null) {
      // Use provided config or default to first character for backward compatibility
      final config = _animationStartConfig ?? const TickerAnimationStartConfig.first();
      // Find the appropriate character list for this target character
              for (final characterList in _characterLists!) {
          if (characterList.getSupportedCharacters().contains(targetChar)) {
            // Get the starting character from the configuration
            final String startChar = config.getStartingCharacter(
              characterList.characterList.sublist(1, characterList.numOriginalCharacters + 1),
              targetChar
            );
          
          // Set the current character to the start character first
          column.setCurrentChar(startChar);
          break;
        }
      }
    }
    
    // Set the target character
    column.setTargetChar(targetChar);
  }

  /// Called when the animation ends
  void onAnimationEnd() {
    for (var column in tickerColumns) {
      column.onAnimationEnd();
    }
  }

  /// Sets the progress of the animation from 0.0 to 1.0
  void setAnimationProgress(double animationProgress) {
    for (var column in tickerColumns) {
      column.setAnimationProgress(animationProgress);
    }
  }

  /// Gets the minimum required width for all columns
  double getMinimumRequiredWidth() {
    double width = 0.0;
    for (var column in tickerColumns) {
      width += column.getMinimumRequiredWidth();
    }
    return width;
  }

  /// Gets the current width of all columns
  double getCurrentWidth() {
    double width = 0.0;
    for (var column in tickerColumns) {
      width += column.getCurrentWidth();
    }
    return width;
  }

  /// Gets the current text being displayed
  String getCurrentText() {
    final StringBuffer currentText = StringBuffer();
    for (var column in tickerColumns) {
      final char = column.getCurrentChar();
      if (char != TickerUtils.emptyChar) {
        currentText.write(char);
      }
    }
    return currentText.toString();
  }

  /// This method will draw onto the canvas the appropriate UI state of each column.
  /// As a side effect, this method will also translate the canvas
  /// accordingly for the draw procedures.
  void draw(Canvas canvas, TextPainter textPainter) {
    for (var column in tickerColumns) {
      column.draw(canvas, textPainter);
      canvas.translate(column.getCurrentWidth(), 0);
    }
  }
}

