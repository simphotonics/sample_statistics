import 'package:minimal_test/minimal_test.dart';
import 'package:statistics/statistics.dart';

import 'package:statistics/src/samples/normal_random_sample.dart';

void main(List<String> args) {
  final stats = SampleStatistics(normalRandomSample);

  group('Basic', () {
    test('min', () {
      expect(stats.min, -1.949079932);
    });
    test('max', () {
      expect(stats.max, 26.55182824);
    });
    test('mean', () {
      expect(stats.mean, 10.168769294545003);
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
      expect(stats.histogram(normalize: false).length, 2);
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
      expect(sum * (stats.max - stats.min) / numberOfIntervals, 1.0);
    });
    test('Total count (non-normalized histograms)', () {
      final hist = stats.histogram(normalize: false);
      var sum = hist[1].fold<num>(0.0, (sum, current) => sum + current);
      expect(sum, normalRandomSample.length);
    });
  });
}
