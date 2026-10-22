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
      expect(
        stats.histogram(minIntervals: 10).first.length,
        greaterThanOrEqualTo(10),
      );
    });
    test('Range', () {
      final hist = stats.histogram(intervals: 10);
      expect(hist.first.first, stats.min);
      expect(hist.first.last, stats.max);
    });
    test('Normalization', () {
      final numberOfIntervals = 10;
      final hist = stats.histogram(intervals: numberOfIntervals);
      expect(hist[1].sum() * (hist[0][1] - hist[0][0]), closeTo(1.0, 1e-12));
    });
    test('Total count (non-normalized histograms)', () {
      final hist = stats.histogram(normalize: false);
      expect(hist[1].sum(), sample.length);
    });
    test('single value', () {
      final stats = Stats(List.filled(100, 5));
      final hist = stats.histogram();
      expect(hist[0], [5]);
      expect(hist[1], [100]);
    });
  });

  group('Export Histogram', () {
    final stats = Stats(sample);
    final hist = stats.exportHistogram(precision: 8, verbose: true);
    test('Data', () {
      expect(
        hist,
        '# Intervals: 6\n'
        '# Min: -10.000000\n'
        '# Max: 10.000000\n'
        '# Interval size: 4.0000000\n'
        '# Mean:   0.32000000\n'
        '# StdDev: 4.3848223\n'
        '# Median: 0.0000000\n'
        '# First Quartile: -2.0000000\n'
        '# Third Quartile: 3.0000000\n'
        '# Histogram integral: 1.0\n'
        '# -------------------------------------------------------------\n'
        '#     Interval Mid-Point                  Probability Density\n'
        '        -10.000000     0.010000000     \n'
        '        -6.0000000     0.020000000     \n'
        '        -2.0000000     0.060000000     \n'
        '        2.0000000      0.11000000     \n'
        '        6.0000000      0.040000000     \n'
        '        10.000000      0.010000000     \n'
        '',
      );
    });
  });

  group('Block Histogram:', () {
    test('single block', () {
      final sample = List.filled(100, 5);

      expect(
        Stats(sample).blockHistogram(indent: '##'),
        '##      \x1B[36m██\x1B[0m\n'
        '##______\x1B[36m██\x1B[0m______\n'
        '##min, median, max: 5',
      );
    });

    test('omit info line', () {
      final stats = Stats(sample);
      expect(
        stats.blockHistogram(
          infoOption: HistogramInfoOption.showNone,
          intervals: 20,
        ),
        endsWith(Histogram.blocks[3]),
      );
    });
    test('include info line', () {
      final stats = Stats(sample);
      expect(
        stats.blockHistogram(infoOption: HistogramInfoOption.showAll),
        endsWith('10'),
      );
    });
    test('left skewed histogram', () {
      final stats = Stats([0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 0.2, 0.5, 4.0]);
      expect(
        stats.blockHistogram(infoOption: HistogramInfoOption.showAll),
        endsWith('4.000'),
      );
    });
    test('right skewed histogram', () {
      final stats = Stats([0, 3, 3.5, 3.8, 3.9, 3.95, 3.99, 4.0, 4.0, 4.0]);
      expect(
        stats.blockHistogram(infoOption: HistogramInfoOption.showAll),
        endsWith('4.000'),
      );
    });
  });

  group('minInfoIntervals:', () {
    final stats = Stats(sample);

    test('showNone', () {
      expect(stats.minInfoIntervals(HistogramInfoOption.showNone), isZero);
    });
    test('showMinMax', () {
      final precision = 5;
      expect(
        stats.minInfoIntervals(
          HistogramInfoOption.showMinMax,
          precision: precision,
        ),
        4,
      );
    });

    test('showMinMax left-skewed dist.', () {
      final stats = Stats([0, 0, 0, 0, 0, 0, 1, 5, 10]);
      final precision = 4;
      expect(
        stats.minInfoIntervals(
          HistogramInfoOption.showMinMax,
          precision: precision,
        ),
        3,
      );
    });
    test('showAll', () {
      final precision = 5;
      expect(
        stats.minInfoIntervals(
          HistogramInfoOption.showAll,
          precision: precision,
        ),
        13,
      );
    });
    test('showAll left-skewed dist.', () {
      final stats = Stats([0, 0, 0, 0, 0, 0, 1, 5, 10]);
      final precision = 4;
      expect(
        stats.minInfoIntervals(
          HistogramInfoOption.showAll,
          precision: precision,
        ),
        -1,
      );
    });
  });
}
