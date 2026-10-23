import 'dart:io';

import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) async {
  final mean = 5.0;
  final stdDev = 2.0;
  final sampleSize = 1000;

  // Generating the random sample with 1000 entries.
  final sample = normalSample(sampleSize, mean, stdDev);
  final stats = Stats(sample);

  print(stats.mean);
  print(stats.stdDev);
  print(stats.min);

  // Exporting a histogram.
  await File('normal$sampleSize.hist').writeAsString(
    stats.exportHistogram(
      pdf: (x) => normalPdf(x, mean, stdDev),
      includeStats: true,
    ),
  );
}
