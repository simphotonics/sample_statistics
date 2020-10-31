import 'dart:math';

import 'package:statistics/statistics.dart';

void main(List<String> args) {
  final x0 = 4;
  final x1 = 10;
  final range = x1 - x0;
  final n = 1000;
  final dx = range / n;
  final y = List<num>.generate(n, (i) => triangularCdf(x0 + i * dx, x0, x1));

  y.export('example/plots/triangular_cdf.dat', range: [x0, x1]);

  final sample = triangularSample(1000, 4, 10);
  sample.exportHistogram(
    'example/plots/triangular.hist', intervals: 10,
    pdf: (x) => triangularPdf(x, x0, x1),
  );
}
