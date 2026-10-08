import 'package:list_operators/list_operators.dart' show NumericalMethods;
import 'package:sample_statistics/sample_statistics.dart';
import 'package:test/test.dart';

void main() {
  final sample = [
    -10,
    -8,
    -5,
    -4,
    -3,
    -3,
    -1,
    -1,
    -1,
    0,
    0,
    0,
    0,
    1,
    1,
    2,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    7,
    10,
  ];
  final sampleEvenEven = [-4, -3, -2, -1, 1, 2, 3, 4];
  final sampleOddEven = [-4, -3, -2, -1, 0, 1, 2, 3, 4];
  final sampleEvenOdd = [-3, -2, -1, 1, 2, 3];
  final sampleOddOdd = [-3, -2, -1, 0, 1, 2, 3];

  group('Basic:', () {
    final statsEvenEven = Stats(sampleEvenEven);
    final statsOddEven = Stats(sampleOddEven);
    final statsEvenOdd = Stats(sampleEvenOdd);
    final statsOddOdd = Stats(sampleOddOdd);

    test('min', () {
      expect(statsEvenEven.min, -4);
      expect(statsOddOdd.min, -3);
    });
    test('max', () {
      expect(statsEvenOdd.max, 3);
      expect(statsOddOdd.max, 3);
    });
    test('mean', () {
      expect(statsEvenEven.mean, 0);
      expect(statsOddOdd.mean, 0);
    });
    test('median', () {
      expect(statsEvenEven.median, 0);
      expect(statsOddOdd.median, 0);
      expect(statsEvenOdd.median, 0);
      expect(statsOddEven.median, 0);
    });
    test('stdDev', () {
      final stats = Stats(sample);
      expect(stats.stdDev, closeTo(4.384822307308093, 1e-8));
    });
  });

  group('Quartile: ', () {
    final statsEvenEven = Stats(sampleEvenEven);
    final statsOddEven = Stats(sampleOddEven);
    final statsEvenOdd = Stats(sampleEvenOdd);
    final statsOddOdd = Stats(sampleOddOdd);
    test('1 even-even', () {
      expect(statsEvenEven.quartile1, -2.5);
    });
    test('1: even-odd', () {
      expect(statsEvenOdd.quartile1, -2);
    });
    test('1: odd-even', () {
      expect(statsOddEven.quartile1, -2.5);
    });
    test('1: odd-odd', () {
      expect(statsOddOdd.quartile1, -2);
    });
    test('3: even-even', () {
      expect(statsEvenEven.quartile3, 2.5);
    });
    test('3: even-odd', () {
      expect(statsEvenOdd.quartile3, 2);
    });
    test('3: odd-even', () {
      expect(statsOddEven.quartile3, 2.5);
    });
    test('3: odd-odd', () {
      expect(statsOddOdd.quartile3, 2);
    });
    test('iqr', () {
      final stats = Stats(sample);
      expect(stats.iqr, closeTo(5.0, 1e-8));
    });
  });

  group('Sample:', () {
    final stats = Stats([-2, 0, 1, 3, 4, 5, 7, 9, 11, -7, -32]);

    test('sorted', () {
      expect(stats.sortedSample, [-32, -7, -2, 0, 1, 3, 4, 5, 7, 9, 11]);
    });

    test('outliers', () {
      final stats0 = Stats(stats.sample);
      expect(stats0.removeOutliers(), [-32]);
      expect(stats0.sample, [-2, 0, 1, 3, 4, 5, 7, 9, 11, -7]);
      expect(stats0.sortedSample, [-7, -2, 0, 1, 3, 4, 5, 7, 9, 11]);
    });

    test('addDataPoints', () {
      final stats0 = Stats(stats.sample);
      stats0.addDataPoints([6, 10]);
      expect(stats0.sample, [...stats.sample, 6, 10]);
    });
  });

  group('Histogram', () {
    final stats = Stats(sample);
    test('Columns', () {
      double pdf(num x) => normalPdf(x, stats.mean, stats.stdDev);
      expect(stats.histogram().length, 2);
      expect(stats.histogram(normalize: false).length, 2);
      expect(stats.histogram(probabilityDensity: pdf).length, 3);
      expect(
        stats.histogram(probabilityDensity: pdf, normalize: false).length,
        3,
      );
    });
    test('Number of intervals', () {
      expect(stats.histogram(intervals: 8).first.length, 8);
    });
    test('Range', () {
      final hist = stats.histogram(intervals: 10);
      expect(hist.first.first, stats.min);
      expect(hist.first.last, stats.max);
    });
    test('Normalization', () {
      final numberOfIntervals = 10;
      final hist = stats.histogram(intervals: numberOfIntervals);
      expect(
        hist[1].sum() * (hist[0][1] - hist[0][0]),
        closeTo(1.0, 1e-12),
      );
    });
    test('Total count (non-normalized histograms)', () {
      final hist = stats.histogram(normalize: false);
      expect(hist[1].sum(), sample.length);
    });
  });

  group('Export Histogram', () {
    final stats = Stats(sample);
    final hist = stats.exportHistogram(precision: 8, verbose: true);
    test('Data', () {
      expect(
        hist,
        '# Intervals: 5\n'
        '# Min: -10.000000\n'
        '# Max: 10.000000\n'
        '# Interval size: 5.0000000\n'
        '# Mean:   0.32000000\n'
        '# StdDev: 4.3848223\n'
        '# Median: 0.0000000\n'
        '# First Quartile: -2.0000000\n'
        '# Third Quartile: 3.0000000\n'
        '# Histogram integral: 1.0\n'
        '#\n'
        '# -------------------------------------------------------------\n'
        '#     Interval Mid-Point                  Probability Density\n'
        '        -10.000000             0.016000000     \n'
        '        -5.0000000             0.032000000     \n'
        '        0.0000000              0.096000000     \n'
        '        5.0000000              0.048000000     \n'
        '        10.000000              0.0080000000     \n'
        '',
      );
    });
  });
}
