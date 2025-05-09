import 'package:flutter/material.dart';

import '../../core/utils/ticker_utils.dart';
import 'ticker_character_list.dart';
import 'ticker_draw_metrics.dart';

//// Represents a column of characters to be drawn on the screen.
/// This class primarily handles animating within the column from one character
/// to the next and drawing all of the intermediate states.
class TickerColumn {
  /// The list of character lists that can be used for animations
  List<TickerCharacterList> _characterLists;

  /// The metrics used for drawing characters
  final TickerDrawMetrics _metrics;

  /// The current character being displayed
  String _currentChar = TickerUtils.emptyChar;

  /// The target character to animate to
  String _targetChar = TickerUtils.emptyChar;

  /// The current character list being used for animation
  List<String>? _currentCharacterList;

  /// The starting index in the character list
  int _startIndex = 0;

  /// The ending index in the character list
  int _endIndex = 0;

  // Drawing state variables that get updated whenever animation progress gets updated
  int _bottomCharIndex = 0;
  double _bottomDelta = 0.0;
  double _charHeight = 0.0;

  // Drawing state variables for handling size transition
  double _sourceWidth = 0.0;
  double _currentWidth = 0.0;
  double _targetWidth = 0.0;
  double _minimumRequiredWidth = 0.0;

  // The bottom delta variables signify the vertical offset for the bottom character
  double _currentBottomDelta = 0.0;
  double _previousBottomDelta = 0.0;
  int _directionAdjustment = 1;

  /// Creates a new ticker column with the given character lists and metrics
  TickerColumn(this._characterLists, this._metrics);

  /// Updates the character lists used in the column
  void setCharacterLists(List<TickerCharacterList> characterLists) {
    _characterLists = characterLists;
  }

  /// Tells the column that the next character it should show is [targetChar].
  /// This change can either be animated or instant depending on the animation
  /// progress set by [setAnimationProgress].
  void setTargetChar(String targetChar) {
    // Set the current and target characters for the animation
    _targetChar = targetChar;
    _sourceWidth = _currentWidth;
    _targetWidth = _metrics.getCharWidth(targetChar);
    _minimumRequiredWidth =
        _sourceWidth > _targetWidth ? _sourceWidth : _targetWidth;

    // Calculate the current indices
    _setCharacterIndices();

    final bool scrollDown = _endIndex >= _startIndex;
    _directionAdjustment = scrollDown ? 1 : -1;

    // Save the currentBottomDelta as previousBottomDelta in case this call to setTargetChar
    // interrupted a previously running animation. The deltas will then be used to compute
    // offset so that the interruption feels smooth on the UI.
    _previousBottomDelta = _currentBottomDelta;
    _currentBottomDelta = 0.0;
  }

  /// Gets the current character being displayed
  String getCurrentChar() {
    return _currentChar;
  }

  /// Gets the target character to animate to
  String getTargetChar() {
    return _targetChar;
  }

  /// Gets the current width of the column
  double getCurrentWidth() {
    _checkForDrawMetricsChanges();
    return _currentWidth;
  }

  /// Gets the minimum required width for the column
  double getMinimumRequiredWidth() {
    _checkForDrawMetricsChanges();
    return _minimumRequiredWidth;
  }

  /// A helper method for populating [_startIndex] and [_endIndex] given the
  /// current and target characters for the animation.
  void _setCharacterIndices() {
    _currentCharacterList = null;

    for (int i = 0; i < _characterLists.length; i++) {
      final CharacterIndices? indices = _characterLists[i].getCharacterIndices(
        _currentChar,
        _targetChar,
        _metrics.getPreferredScrollingDirection(),
      );

      if (indices != null) {
        _currentCharacterList = _characterLists[i].characterList;
        _startIndex = indices.startIndex;
        _endIndex = indices.endIndex;
        return;
      }
    }

    // If we didn't find a list that contains both characters, just perform a default animation
    // going straight from source to target
    if (_currentCharacterList == null) {
      if (_currentChar == _targetChar) {
        _currentCharacterList = [_currentChar];
        _startIndex = _endIndex = 0;
      } else {
        _currentCharacterList = [_currentChar, _targetChar];
        _startIndex = 0;
        _endIndex = 1;
      }
    }
  }

  /// Called when the animation ends
  void onAnimationEnd() {
    _checkForDrawMetricsChanges();
    _minimumRequiredWidth = _currentWidth;
  }

  /// Checks if the draw metrics have changed and updates widths accordingly
  void _checkForDrawMetricsChanges() {
    final double currentTargetWidth = _metrics.getCharWidth(_targetChar);
    // Only resize due to DrawMetrics changes when we are done with whatever animation we
    // are running.
    if (_currentWidth == _targetWidth && _targetWidth != currentTargetWidth) {
      _minimumRequiredWidth = _currentWidth = _targetWidth = currentTargetWidth;
    }
  }

  /// Sets the progress of the animation from 0.0 to 1.0
  void setAnimationProgress(double animationProgress) {
    if (animationProgress == 1.0) {
      // Animation finished (or never started), set to stable state.
      _currentChar = _targetChar;
      _currentBottomDelta = 0.0;
      _previousBottomDelta = 0.0;
    }

    final double charHeight = _metrics.getCharHeight();

    // First let's find the total height of this column between the start and end chars.
    final double totalHeight = charHeight * (_endIndex - _startIndex).abs();

    // The current base is then the part of the total height that we have progressed to
    // from the animation. For example, there might be 5 characters, each character is
    // 2px tall, so the totalHeight is 10. If we are at 50% progress, then our baseline
    // in this column is at 5 out of 10 (which is the 3rd character with a -50% offset
    // to the baseline).
    final double currentBase = animationProgress * totalHeight;

    // Given the current base, we now can find which character should drawn on the bottom.
    // Note that this position is a float. For example, if the bottomCharPosition is
    // 4.5, it means that the bottom character is the 4th character, and it has a -50%
    // offset relative to the baseline.
    final double bottomCharPosition = currentBase / charHeight;

    // By subtracting away the integer part of bottomCharPosition, we now have the
    // percentage representation of the bottom char's offset.
    final double bottomCharOffsetPercentage =
        bottomCharPosition - bottomCharPosition.floor();

    // We might have interrupted a previous animation if previousBottomDelta is not 0f.
    // If that's the case, we need to take this delta into account so that the previous
    // character offset won't be wiped away when we start a new animation.
    // We multiply by the inverse percentage so that the offset contribution from the delta
    // progresses along with the rest of the animation (from full delta to 0).
    final double additionalDelta =
        _previousBottomDelta * (1.0 - animationProgress);

    // Now, using the bottom char's offset percentage and the delta we have from the
    // previous animation, we can now compute what's the actual offset of the bottom
    // character in the column relative to the baseline.
    _bottomDelta =
        bottomCharOffsetPercentage * charHeight * _directionAdjustment +
            additionalDelta;

    // Figure out what the actual character index is in the characterList, and then
    // draw the character with the computed offset.
    _bottomCharIndex =
        _startIndex + (bottomCharPosition.floor() * _directionAdjustment);

    _charHeight = charHeight;
    _currentWidth =
        _sourceWidth + (_targetWidth - _sourceWidth) * animationProgress;
  }

  /// Draw the current state of the column as it's animating from one character in the list
  /// to another. This method will take into account various factors such as animation
  /// progress and the previously interrupted animation state to render the characters
  /// in the correct position on the canvas.
  void draw(Canvas canvas, TextPainter textPainter) {
    if (_drawText(
      canvas,
      textPainter,
      _currentCharacterList!,
      _bottomCharIndex,
      _bottomDelta,
    )) {
      // Save the current drawing state in case our animation gets interrupted
      if (_bottomCharIndex >= 0 &&
          _bottomCharIndex < _currentCharacterList!.length) {
        _currentChar = _currentCharacterList![_bottomCharIndex];
      }
      _currentBottomDelta = _bottomDelta;
    }

    // Draw the corresponding top and bottom characters if applicable
    _drawText(
      canvas,
      textPainter,
      _currentCharacterList!,
      _bottomCharIndex + 1,
      _bottomDelta - _charHeight,
    );

    // Drawing the bottom character here might seem counter-intuitive because we've been
    // computing for the bottom character this entire time. But the bottom character
    // computed above might actually be above the baseline if we interrupted a previous
    // animation that gave us a positive additionalDelta.
    _drawText(
      canvas,
      textPainter,
      _currentCharacterList!,
      _bottomCharIndex - 1,
      _bottomDelta + _charHeight,
    );
  }

  /// Draws text on the canvas at the specified index and vertical offset
  /// @return whether the text was successfully drawn on the canvas
  bool _drawText(
    Canvas canvas,
    TextPainter textPainter,
    List<String> characterList,
    int index,
    double verticalOffset,
  ) {
    if (index >= 0 && index < characterList.length) {
      // Save the canvas state
      canvas.save();

      // Update the text painter with the character to draw
      textPainter.text = TextSpan(
        text: characterList[index],
        style: textPainter.text!.style,
      );

      // Layout the text to get its metrics
      textPainter.layout();

      // Calculate the vertical adjustment based on font metrics
      // This scales properly with font size changes
      final fontHeight = textPainter.height;
      final fontBaseline = textPainter.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      );

      // The adjustment is proportional to the font size and baseline position
      // This ensures consistent positioning regardless of font size or font family
      // We use the baseline as a reference point for proper vertical alignment
      final verticalAdjustment = -fontHeight * .95 + (fontBaseline * 0.2);

      // Apply the calculated offset
      canvas.translate(0, verticalOffset + verticalAdjustment);

      // Paint the text at the origin
      textPainter.paint(canvas, Offset.zero);

      // Restore the canvas state
      canvas.restore();

      return true;
    }
    return false;
  }
}
