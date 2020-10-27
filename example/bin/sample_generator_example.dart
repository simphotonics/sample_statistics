import 'package:statistics/statistics.dart';

void main(List<String> args) {
  final min = 1.0;
  final max = 9.0;
  final mean = 5.0;
  final stdDev = 2.0;
  final sample = generateTruncatedNormalSample(1000, min, max, mean, stdDev);

  final stats = SampleStatistics(sample);
  print(stats.mean);
  print(stats.stdDev);
  print(stats.min);

  sample.exportHistogram(
    '../plots/truncated_normal.hist',
    pdf: (x) =>
        truncatedNormalPdf(x, stats.min, stats.max, stats.mean, stats.stdDev),
  );
}
