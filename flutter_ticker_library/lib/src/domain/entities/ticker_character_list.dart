import '../../core/utils/ticker_utils.dart';

/// Enum for scrolling direction
enum ScrollingDirection {
  /// Scroll from bottom to top
  up,

  /// Scroll from top to bottom
  down,

  /// Automatically choose the shortest path
  any
}

/// This is the primary class that Ticker uses to determine how to animate from one character
/// to another. The provided string dictates what characters will appear between
/// the start and end characters.
///
/// For example, given the string "abcde", if the view wants to animate from 'd' to 'b',
/// it will know that it has to go from 'd' to 'c' to 'b', and these are the characters
/// that show up during the animation scroll.
class TickerCharacterList {
  /// The number of characters in the original list
  final int numOriginalCharacters;

  /// The saved character list will always be of the format: EMPTY, list, list
  final List<String> characterList;

  /// A minor optimization so that we can cache the indices of each character.
  final Map<String, int> characterIndicesMap;

  /// Creates a new ticker character list from the given string
  TickerCharacterList(String characters)
      : numOriginalCharacters = characters.length,
        characterIndicesMap = {},
        characterList = [] {
    if (characters.contains(TickerUtils.emptyChar)) {
      throw ArgumentError(
          'You cannot include TickerUtils.emptyChar in the character list.');
    }

    final List<String> charsList = characters.split('');
    final int length = charsList.length;

    for (int i = 0; i < length; i++) {
      characterIndicesMap[charsList[i]] = i;
    }

    // Initialize with empty char
    characterList.add(TickerUtils.emptyChar);

    // Add the character list twice to handle wrap-around animations
    characterList.addAll(charsList);
    characterList.addAll(charsList);
  }

  /// Gets the supported characters in this character list
  Set<String> getSupportedCharacters() {
    return characterIndicesMap.keys.toSet();
  }

  /// Gets the character indices for animating from start to end character
  /// with the specified scrolling direction
  ///
  /// @param start the character that we want to animate from
  /// @param end the character that we want to animate to
  /// @param direction the preferred scrolling direction
  /// @return a valid pair of start and end indices, or null if the inputs are not supported.
  CharacterIndices? getCharacterIndices(
      String start, String end, ScrollingDirection direction) {
    int startIndex = _getIndexOfChar(start);
    int endIndex = _getIndexOfChar(end);

    if (startIndex < 0 || endIndex < 0) {
      return null;
    }

    switch (direction) {
      case ScrollingDirection.down:
        if (end == TickerUtils.emptyChar) {
          endIndex = characterList.length;
        } else if (endIndex < startIndex) {
          endIndex += numOriginalCharacters;
        }
        break;

      case ScrollingDirection.up:
        if (startIndex < endIndex) {
          startIndex += numOriginalCharacters;
        }
        break;

      case ScrollingDirection.any:
        // see if the wrap-around animation is shorter distance than the original animation
        if (start != TickerUtils.emptyChar && end != TickerUtils.emptyChar) {
          if (endIndex < startIndex) {
            // If we are potentially going backwards
            final int nonWrapDistance = startIndex - endIndex;
            final int wrapDistance =
                numOriginalCharacters - startIndex + endIndex;
            if (wrapDistance < nonWrapDistance) {
              endIndex += numOriginalCharacters;
            }
          } else if (startIndex < endIndex) {
            // If we are potentially going forwards
            final int nonWrapDistance = endIndex - startIndex;
            final int wrapDistance =
                numOriginalCharacters - endIndex + startIndex;
            if (wrapDistance < nonWrapDistance) {
              startIndex += numOriginalCharacters;
            }
          }
        }
        break;
    }

    return CharacterIndices(startIndex, endIndex);
  }

  /// Gets the index of a character in the character list
  int _getIndexOfChar(String c) {
    if (c == TickerUtils.emptyChar) {
      return 0;
    } else if (characterIndicesMap.containsKey(c)) {
      return characterIndicesMap[c]! + 1;
    } else {
      return -1;
    }
  }
}

/// Class to hold the start and end indices for character animations
class CharacterIndices {
  /// The starting index in the character list
  final int startIndex;

  /// The ending index in the character list
  final int endIndex;

  /// Creates a new character indices pair
  CharacterIndices(this.startIndex, this.endIndex);
}
