import 'package:sample_statistics/sample_statistics.dart';
import 'package:test/test.dart';

void main() {
  final stats = Stats(normalRandomSample);

  group('Basic:', () {
    test('min', () {
      expect(stats.min, -1.949079932);
    });
    test('max', () {
      expect(stats.max, 26.55182824);
    });
    test('mean', () {
      expect(stats.mean, closeTo(10.168769294545003, 1e-12));
    });
    test('median', () {
      expect(stats.median, 10.232570379999999);
    });
    test('stdDev', () {
      expect(stats.stdDev, 5.370025848202738);
    });
    test('quartile1', () {
      expect(stats.quartile1, 6.1556007975);
    });
    test('quartile3', () {
      expect(stats.quartile3, 14.234971445);
    });
  });

  group('Histogram', () {
    test('Columns', () {
      expect(stats.histogram().length, 3);
      expect(stats.histogram(normalize: false).length, 3);
    });
    test('Number of intervals', () {
      expect(stats.histogram(intervals: 8).first.length, 9);
    });
    test('Range', () {
      final hist = stats.histogram(intervals: 10);
      expect(hist.first.first, stats.min);
      expect(hist.first.last, stats.max);
    });
    test('Normalization', () {
      final numberOfIntervals = 10;
      final hist = stats.histogram(intervals: numberOfIntervals);
      var sum = hist[1].fold<num>(0.0, (sum, current) => sum + current);
      expect(sum * (stats.max - stats.min) / numberOfIntervals,
          closeTo(1.0, 1e-12));
    });
    test('Total count (non-normalized histograms)', () {
      final hist = stats.histogram(normalize: false);
      var sum = hist[1].fold<num>(0.0, (sum, current) => sum + current);
      expect(sum, normalRandomSample.length);
    });
  });

  group('Export Histogram', () {
    final hist = normalRandomSample.exportHistogram(precision: 8);
    test('Data', () {
      expect(
          hist,
          '# Intervals: 8\n'
          '# Min: -1.9490799\n'
          '# Max: 26.551828\n'
          '# Mean: 10.168769\n'
          '# StdDev: 5.3700258\n'
          '# Median: 10.232570\n'
          '# First Quartile: 6.1556008\n'
          '# Third Quartile: 14.234971\n'
          '# Interval size: 3.5626135\n'
          '# Integrated histogram: 1.0000000000000002\n'
          '#\n'
          '# -------------------------------------------------------------\n'
          '#     Range     Count    Prob. Density Func. \n'
          '-1.9490799     0.0056138562     0.0058236414\n'
          '1.6135336     0.022455425     0.020882819\n'
          '5.1761471     0.056138562     0.048220974\n'
          '8.7387606     0.058945490     0.071702644\n'
          '12.301374     0.064559346     0.068657297\n'
          '15.863988     0.056138562     0.042334124\n'
          '19.426601     0.011227712     0.016809190\n'
          '22.989215     0.0028069281     0.0042978905\n'
          '26.551828     0.0028069281     0.00070764630\n'
          '');
    });
  });
}
