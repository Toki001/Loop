/// Incomplete capabilities are never enabled through a retail demo-data switch.
/// Flip a flag only with its real implementation, acceptance tests and evidence.
abstract final class LoopFeatures {
  static const skills = true;
  static const sessions = false;
  static const evidence = false;
  static const insights = false;
  static const reminders = false;
  static const ownership = false;
}
