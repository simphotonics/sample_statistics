import 'package:sample_statistics/sample_statistics.dart';

void main() {
  final originalSample = [-10, 0, 1, 2, 3, 4, 5, 6, 20];
  final stats = Stats(originalSample);

  print('\nRunning sample_statistics_example.dart ...');

  print('Sample: ${stats.sample}');

  print('min: ${stats.min}');

  print('max: ${stats.max}');

  print('mean: ${stats.mean}');

  print('median: ${stats.median}');

  print('first quartile: ${stats.quartile1}');

  print('third quartile: ${stats.quartile3}');

  print('inter-quartile-range:${stats.iqr}');

  print('standard deviation: ${stats.stdDev}');

  final outliers = stats.removeOutliers();
  print('outliers:$outliers');

  print('Sample without outliers: ${stats.sample}');

  stats.addDataPoints([-2, 7]);

  print('Sample with additional data points: ${stats.sample}');

  print('Sorted sample: ${stats.sortedSample}');
}
