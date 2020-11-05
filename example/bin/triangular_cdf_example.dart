import 'dart:io';

import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable triangular_cdf_example.dart
/// ```
void main(List<String> args) async {
  final min = 4;
  final max = 10;
  final range = max - min;
  final sampleSize = 10000;
  final dx = range / sampleSize;
  final y = List<num>.generate(
      sampleSize, (i) => triangularCdf(min + i * dx, min, max));

  await File('../sample_data/triangular_cdf.dat').writeAsString(
    y.export(range: [min, max]),
  );

  final sample = sampleTriangularPdf(sampleSize, 4, 10);

  await File('../plots/triangular_$sampleSize.hist').writeAsString(
    sample.exportHistogram(
      pdf: (x) => triangularPdf(x, min, max),
    ),
  );

  final stats = SampleStats(sample);

  await File('../sample_data/triangular_sample.dat').writeAsString(
    sample.export(),
  );

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
