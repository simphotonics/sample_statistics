import 'dart:math';

import 'package:sample_statistics/sample_statistics.dart' show Integration;

void main(List<String> args) {
  final dx = 0.01;
  final watch = Stopwatch();
  watch.start();
  final result = sin.integrate(0, pi / 2, dx: dx);
  watch.stop();
  print('sin.integrate(0, pi/2, dx: $dx)');
  print(
    'Result: ${result.toStringAsPrecision(6)} | '
    'Precision: ${(1.0 - result).toStringAsPrecision(6)}.',
  );
  print(
    'Integration step size: $dx. '
    'Integration steps: ${(pi / 2 / dx).ceil()}.',
  );
  print('Integration time: ${watch.elapsedMicroseconds / 1000} ms.');
}
