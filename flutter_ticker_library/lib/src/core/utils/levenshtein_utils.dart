/// Helper class to compute the Levenshtein distance between two strings.
/// Used for determining the optimal animation path between two strings.
/// https://en.wikipedia.org/wiki/Levenshtein_distance
class LevenshteinUtils {
  /// Action indicating the character should remain the same
  static const int actionSame = 0;

  /// Action indicating a character should be inserted
  static const int actionInsert = 1;

  /// Action indicating a character should be deleted
  static const int actionDelete = 2;

  /// Computes the column actions needed to transform the source string into the target string.
  ///
  /// This is a wrapper function around the segment calculation logic that
  /// additionally takes in supportedCharacters. It uses supportedCharacters to compute whether
  /// the current character should be animated or if it should remain in-place.
  ///
  /// @param source the source char array to animate from
  /// @param target the target char array to animate to
  /// @param supportedCharacters all characters that support custom animation.
  /// @return an int array where each index corresponds to one of [actionSame], [actionInsert],
  ///         [actionDelete] to represent if we update, insert, or delete a character
  ///         at the particular index.
  static List<int> computeColumnActions(List<String> source,
      List<String> target, Set<String> supportedCharacters) {
    int sourceIndex = 0;
    int targetIndex = 0;

    final List<int> columnActions = [];
    while (true) {
      // Check for terminating conditions
      final bool reachedEndOfSource = sourceIndex == source.length;
      final bool reachedEndOfTarget = targetIndex == target.length;

      if (reachedEndOfSource && reachedEndOfTarget) {
        break;
      } else if (reachedEndOfSource) {
        _fillWithActions(
            columnActions, target.length - targetIndex, actionInsert);
        break;
      } else if (reachedEndOfTarget) {
        _fillWithActions(
            columnActions, source.length - sourceIndex, actionDelete);
        break;
      }

      final bool containsSourceChar =
          supportedCharacters.contains(source[sourceIndex]);
      final bool containsTargetChar =
          supportedCharacters.contains(target[targetIndex]);

      if (containsSourceChar && containsTargetChar) {
        // We reached a segment that we can perform animations on
        final int sourceEndIndex = _findNextUnsupportedChar(
            source, sourceIndex + 1, supportedCharacters);
        final int targetEndIndex = _findNextUnsupportedChar(
            target, targetIndex + 1, supportedCharacters);

        _appendColumnActionsForSegment(columnActions, source, target,
            sourceIndex, sourceEndIndex, targetIndex, targetEndIndex);

        sourceIndex = sourceEndIndex;
        targetIndex = targetEndIndex;
      } else if (containsSourceChar) {
        // We are animating in a target character that isn't supported
        columnActions.add(actionInsert);
        targetIndex++;
      } else if (containsTargetChar) {
        // We are animating out a source character that isn't supported
        columnActions.add(actionDelete);
        sourceIndex++;
      } else {
        // Both characters are not supported, perform default animation to replace
        columnActions.add(actionSame);
        sourceIndex++;
        targetIndex++;
      }
    }

    return columnActions;
  }

  /// Finds the next character in the array that is not supported
  static int _findNextUnsupportedChar(
      List<String> chars, int startIndex, Set<String> supportedCharacters) {
    for (int i = startIndex; i < chars.length; i++) {
      if (!supportedCharacters.contains(chars[i])) {
        return i;
      }
    }
    return chars.length;
  }

  /// Fills the actions list with the specified action a given number of times
  static void _fillWithActions(List<int> actions, int num, int action) {
    for (int i = 0; i < num; i++) {
      actions.add(action);
    }
  }

  /// Run a slightly modified version of Levenshtein distance algorithm to compute the minimum
  /// edit distance between the current and the target text within the start and end bounds.
  /// Unlike the traditional algorithm, we force return all [actionSame] for inputs that
  /// are the same length (so optimize update over insertion/deletion).
  static void _appendColumnActionsForSegment(
      List<int> columnActions,
      List<String> source,
      List<String> target,
      int sourceStart,
      int sourceEnd,
      int targetStart,
      int targetEnd) {
    final int sourceLength = sourceEnd - sourceStart;
    final int targetLength = targetEnd - targetStart;
    final int resultLength =
        sourceLength > targetLength ? sourceLength : targetLength;

    if (sourceLength == targetLength) {
      // No modifications needed if the length of the strings are the same
      _fillWithActions(columnActions, resultLength, actionSame);
      return;
    }

    final int numRows = sourceLength + 1;
    final int numCols = targetLength + 1;

    // Compute the Levenshtein matrix
    final List<List<int>> matrix =
        List.generate(numRows, (i) => List.generate(numCols, (j) => 0));

    for (int i = 0; i < numRows; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j < numCols; j++) {
      matrix[0][j] = j;
    }

    int cost;
    for (int row = 1; row < numRows; row++) {
      for (int col = 1; col < numCols; col++) {
        cost = source[row - 1 + sourceStart] == target[col - 1 + targetStart]
            ? 0
            : 1;

        matrix[row][col] = _min(matrix[row - 1][col] + 1,
            matrix[row][col - 1] + 1, matrix[row - 1][col - 1] + cost);
      }
    }

    // Reverse trace the matrix to compute the necessary actions
    final List<int> resultList = [];
    int row = numRows - 1;
    int col = numCols - 1;

    while (row > 0 || col > 0) {
      if (row == 0) {
        // At the top row, can only move left, meaning insert column
        resultList.add(actionInsert);
        col--;
      } else if (col == 0) {
        // At the left column, can only move up, meaning delete column
        resultList.add(actionDelete);
        row--;
      } else {
        final int insert = matrix[row][col - 1];
        final int delete = matrix[row - 1][col];
        final int replace = matrix[row - 1][col - 1];

        if (insert < delete && insert < replace) {
          resultList.add(actionInsert);
          col--;
        } else if (delete < replace) {
          resultList.add(actionDelete);
          row--;
        } else {
          resultList.add(actionSame);
          row--;
          col--;
        }
      }
    }

    // Reverse the actions to get the correct ordering
    for (int i = resultList.length - 1; i >= 0; i--) {
      columnActions.add(resultList[i]);
    }
  }

  /// Returns the minimum of three integers
  static int _min(int first, int second, int third) {
    return [first, second, third]
        .reduce((curr, next) => curr < next ? curr : next);
  }
}
