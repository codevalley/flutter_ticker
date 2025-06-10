import 'package:flutter/material.dart';

import '../../../src/core/utils/levenshtein_utils.dart';
import '../../../src/core/utils/ticker_utils.dart';
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

    // Use Levenshtein distance algorithm to figure out how to manipulate the columns
    final List<int> actions = LevenshteinUtils.computeColumnActions(
        currentTextChars, newTextChars, _supportedCharacters!);

    int columnIndex = 0;
    int textIndex = 0;

    for (int i = 0; i < actions.length; i++) {
      switch (actions[i]) {
        case LevenshteinUtils.actionInsert:
          tickerColumns.insert(
              columnIndex, TickerColumn(_characterLists!, _metrics));
          // Intentional fallthrough
          continue actionSame;

        actionSame:
        case LevenshteinUtils.actionSame:
          tickerColumns[columnIndex].setTargetChar(newTextChars[textIndex]);
          columnIndex++;
          textIndex++;
          break;

        case LevenshteinUtils.actionDelete:
          tickerColumns[columnIndex].setTargetChar(TickerUtils.emptyChar);
          columnIndex++;
          break;

        default:
          throw ArgumentError('Unknown action: ${actions[i]}');
      }
    }
    
    // Update position index for each column after text changes
    for (int i = 0; i < tickerColumns.length; i++) {
      tickerColumns[i].setPositionIndex(i);
    }
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
