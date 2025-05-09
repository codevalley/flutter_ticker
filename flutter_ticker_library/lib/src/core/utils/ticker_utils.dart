/// Utility class for the ticker package.
/// Contains helper methods such as those that generate default character lists
/// to use for animation.
class TickerUtils {
  /// Empty character used as a placeholder
  static const String emptyChar = '\u0000';

  /// Provides a list of numerical characters (0-9)
  static String provideNumberList() {
    return '0123456789';
  }

  /// Provides a list of alphabetical characters (a-z, A-Z)
  static String provideAlphabeticalList() {
    return 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  }
}
