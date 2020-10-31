import 'package:statistics/statistics.dart';

void main(List<String> args) {
  final x0 = -10;
  final x1 = 10;
  final range = x1 - x0;
  final n = 1000;
  final dx = range / n;
  final y = List<num>.generate(n, (i) => erf(x0 + i * dx));

  y.export('example/plots/erf.dat', range: [x0, x1]);
}
