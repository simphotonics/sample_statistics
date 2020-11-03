import 'dart:io';

import 'package:statistics/statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable triangular_cdf_example.dart
/// ```
void main(List<String> args) async{
  final min = 4;
  final max = 10;
  final range = max - min;
  final sampleSize = 10000;
  final dx = range / sampleSize;
  final y = List<num>.generate(
      sampleSize, (i) => triangularCdf(min + i * dx, min, max));

  await y.export('../sample_data/triangular_cdf.dat', range: [min, max]);

  final sample = triangularSample(sampleSize, 4, 10);

  await sample.exportHistogram(
    '../plots/triangular_$sampleSize.hist',
    pdf: (x) => triangularPdf(x, min, max),
  );

  final stats = SampleStatistics(sample);

  await sample.export('../sample_data/triangular_sample.dat');

  // Export variables
  final file = File('../sample_data/triangular_$sampleSize.dat');

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
