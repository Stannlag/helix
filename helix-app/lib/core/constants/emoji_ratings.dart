/// Emoji Ratings for Session Feedback
class EmojiRatings {
  EmojiRatings._();

  static const String sad = '😞';
  static const String neutral = '😐';
  static const String happy = '😊';
  static const String amazing = '🤩';

  static const List<String> all = [sad, neutral, happy, amazing];

  static String get defaultRating => happy;

  /// Get emoji description
  static String getDescription(String emoji) {
    switch (emoji) {
      case sad:
        return 'Not great';
      case neutral:
        return 'Okay';
      case happy:
        return 'Good';
      case amazing:
        return 'Amazing!';
      default:
        return 'Unknown';
    }
  }

  /// Get emoji value (for analytics)
  static int getValue(String emoji) {
    switch (emoji) {
      case sad:
        return 1;
      case neutral:
        return 2;
      case happy:
        return 3;
      case amazing:
        return 4;
      default:
        return 0;
    }
  }
}
