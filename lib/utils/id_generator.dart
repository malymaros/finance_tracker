/// Generates a unique string ID for domain entities.
///
/// Uses microsecond timestamp to reduce collision risk from rapid successive
/// calls compared to millisecondsSinceEpoch.
class IdGenerator {
  IdGenerator._();

  static String generate() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
