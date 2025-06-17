import 'dart:math';

/// Enum for different animation starting behaviors
enum TickerAnimationStartMode {
  /// Start animation from the current character (default behavior)
  current,

  /// Start animation from a specific character
  specific,

  /// Start animation from a random character
  random,

  /// Start animation from the first character in the character list (e.g., '0' for numbers)
  first,

  /// Start animation from the last character in the character list (e.g., '9' for numbers)
  last,
}

/// Configuration class for controlling how ticker animations start
/// This configuration only applies to the initial/first animation to preserve fluidity
class TickerAnimationStartConfig {
  /// The mode for determining the starting position
  final TickerAnimationStartMode mode;

  /// The specific character to start from (used when mode is specific)
  final String? specificStartChar;

  /// Random number generator for random mode (optional, uses default if not provided)
  final Random? random;

  /// Creates a configuration for current character starting (default behavior)
  const TickerAnimationStartConfig.current()
      : mode = TickerAnimationStartMode.current,
        specificStartChar = null,
        random = null;

  /// Creates a configuration for starting from a specific character
  const TickerAnimationStartConfig.specific(String startChar)
      : mode = TickerAnimationStartMode.specific,
        specificStartChar = startChar,
        random = null;

  /// Creates a configuration for starting from a random character
  const TickerAnimationStartConfig.random({this.random})
      : mode = TickerAnimationStartMode.random,
        specificStartChar = null;

  /// Creates a configuration for starting from the first character in the list
  const TickerAnimationStartConfig.first()
      : mode = TickerAnimationStartMode.first,
        specificStartChar = null,
        random = null;

  /// Creates a configuration for starting from the last character in the list
  const TickerAnimationStartConfig.last()
      : mode = TickerAnimationStartMode.last,
        specificStartChar = null,
        random = null;

  /// Gets the starting character for a given character list and target character
  String getStartingCharacter(List<String> characterList, String targetChar) {
    switch (mode) {
      case TickerAnimationStartMode.current:
        return targetChar; // This maintains current behavior

      case TickerAnimationStartMode.specific:
        if (specificStartChar != null &&
            characterList.contains(specificStartChar!)) {
          return specificStartChar!;
        }
        return characterList.isNotEmpty ? characterList.first : targetChar;

      case TickerAnimationStartMode.random:
        if (characterList.isEmpty) return targetChar;
        final rng = random ?? Random();
        return characterList[rng.nextInt(characterList.length)];

      case TickerAnimationStartMode.first:
        return characterList.isNotEmpty ? characterList.first : targetChar;

      case TickerAnimationStartMode.last:
        return characterList.isNotEmpty ? characterList.last : targetChar;
    }
  }
}
