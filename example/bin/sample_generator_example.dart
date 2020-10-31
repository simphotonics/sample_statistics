import 'dart:io';

import 'package:statistics/statistics.dart';

void main(List<String> args) async {
  final sampleSize = 3000;
  final min = 1.5;
  final max = 6.0;
  final mean = 3.0;
  final stdDev = 1.0;
  final sample =
      generateTruncatedNormalSample(sampleSize, min, max, mean, stdDev);

  final stats = SampleStatistics(sample);

  // Export histogram
  await sample.exportHistogram(
    '../plots/truncated_normal$sampleSize.hist',
    pdf: (x) => truncatedNormalPdf(x, min, max, mean, stdDev),
  );

  // Export variables
  final file = File('../plots/truncated_normal$sampleSize.dat');

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
