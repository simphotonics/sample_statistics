import 'dart:io';

import 'package:statistics/statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable sample_generator_example.dart
/// ```
void main(List<String> args) async {
  final sampleSize = 1000;
  final min = 1.5;
  final max = 6.0;
  final mean = 3.0;
  final stdDev = 1.0;
  final sample =
      truncatedNormalSample(sampleSize, min, max, mean, stdDev);

  final stats = SampleStatistics(sample);

  // Export histogram
  await sample.exportHistogram(
    '../sample_data/truncated_normal$sampleSize.hist',
    pdf: (x) => truncatedNormalPdf(x, min, max, mean, stdDev),
  );

  // Export variables used by the gnuplot script:
  final file = File('../sample_data/truncated_normal$sampleSize.dat');

  final b = StringBuffer();
  b.writeln('# Histogram: Truncated normal distribution.');
  b.writeln('# -----------------------------------------');
  b.writeln('# Parameters used to generate the random sample:');
  b.writeln('sampleSize = $sampleSize');
  b.writeln('min = $min');
  b.writeln('max = $max');
  b.writeln('mean = $mean');
  b.writeln('sampleMean = ${stats.mean}');
  b.writeln('stdDev = $stdDev');

  await file.writeAsString(b.toString());
}
