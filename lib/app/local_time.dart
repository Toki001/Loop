import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Presentation dates use the device clock. Tests may supply a fixed date;
/// this provider never drives the monotonic practice engine or stored duration.
final localNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
