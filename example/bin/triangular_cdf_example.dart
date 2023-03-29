import 'dart:io';

import 'package:list_operators/list_operators.dart';
import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart triangular_cdf_example.dart
/// ```
void main(List<String> args) async {
  final min = 4;
  final max = 10;
  final range = max - min;
  final sampleSize = 10000;
  // final dx = range / sampleSize;
  // final y = List<num>.generate(
  //     sampleSize, (i) => triangularCdf(min + i * dx, min, max));

  await File('../data/triangular_cdf.dat').writeAsString(
    ((num x) => triangularCdf(x, min, max)).export(
      range: [min, max],
      label: '# x    triangularCdf(x, $min, $max)',
    ),
  );

  final sample = triangularSample(sampleSize, 4, 10);

  await File('../plots/triangular_$sampleSize.hist').writeAsString(
    sample.exportHistogram(
      pdf: (x) => triangularPdf(x, min, max),
    ),
  );

  final stats = Stats(sample);

  await File('../data/triangular_sample.dat').writeAsString(
    sample.export(),
  );

  // Export variables
  final file = File('../data/triangular_$sampleSize.dat');

  final b = StringBuffer();
  b.writeln('# Histogram: Truncated normal distribution.');
  b.writeln('# -----------------------------------------');
  b.writeln('# Parameters used to generate the random sample:');
  b.writeln('sampleSize = $sampleSize');
  b.writeln('min = $min');
  b.writeln('max = $max');
  b.writeln('mean = ${min + range / 2}');
  b.writeln('sampleMean = ${stats.mean}');
  b.writeln('sampleStdDev = ${stats.stdDev}');

  await file.writeAsString(b.toString());
}
