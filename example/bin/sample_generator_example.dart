import 'dart:io';

import 'package:list_operators/list_operators.dart';
import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the main package folder and use the
/// command:
/// ```Console
/// $ dart example/bin/sample_generator_example.dart
/// ```
void main(List<String> args) async {
  final sampleSize = 12000;
  final xMin = 2.0;
  final xMax = 6.0;
  final meanOfParent = 3.0;
  final stdDevOfParent = 1.0;
  final sample = truncatedNormalSample(
    sampleSize,
    xMin,
    xMax,
    meanOfParent,
    stdDevOfParent,
  );

  final stats = Stats(sample);

  // Export histogram
  await File('example/data/truncated_normal$sampleSize.hist').writeAsString(
    sample.exportHistogram(
      pdf: (x) =>
          truncatedNormalPdf(x, xMin, xMax, meanOfParent, stdDevOfParent),
    ),
  );

  await File('example/data/truncated_normal$sampleSize.dat').writeAsString(
    sample.export(
      label:
          '# Truncated Normal min: $xMin, max: $xMax, '
          'mean: $meanOfParent, stdDev: $stdDevOfParent, sampleSize: $sampleSize',
    ),
  );

  // Export variables used by the gnuplot script:
  final file = File('example/data/truncated_normal$sampleSize.var');

  final b = StringBuffer();
  b.writeln('# Histogram: Truncated normal distribution.');
  b.writeln('# -----------------------------------------');
  b.writeln('sampleSize = $sampleSize');
  b.writeln('min = $xMin');
  b.writeln('max = $xMax');
  b.writeln('meanOfParent = $meanOfParent');
  b.writeln('sampleMean = ${stats.mean}');
  b.writeln(
    'mean = '
    '${meanTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent)}',
  );
  b.writeln('stdDevOfParent = $stdDevOfParent');
  b.writeln('sampleStdDev =${stats.stdDev}');
  b.writeln(
    'stdDev = '
    '${stdDevTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent)}',
  );

  await file.writeAsString(b.toString());
}
