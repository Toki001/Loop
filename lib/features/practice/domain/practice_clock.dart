abstract interface class PracticeClock {
  Duration get elapsed;
  void start();
  void stop();
  void reset();
}

class StopwatchPracticeClock implements PracticeClock {
  final Stopwatch _watch = Stopwatch();
  @override
  Duration get elapsed => _watch.elapsed;
  @override
  void start() => _watch.start();
  @override
  void stop() => _watch.stop();
  @override
  void reset() => _watch.reset();
}
