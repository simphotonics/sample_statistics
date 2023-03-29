import 'dart:math' as math;

import 'package:sample_statistics/sample_statistics.dart';
import 'package:test/test.dart';

void main() {
  group('samplePdf:', () {
    final min = -4.0;
    final max = 5.0;
    final h = (max - min) / 2;
    final n = 1000;
    double pdf(num x) => triangularPdf(x, min, max);
    final sample = randomSample(n, min, max, pdf(min + h), pdf);
    final stats = Stats(sample);

    test('Sample size', () {
      expect(sample.length, n);
    });
    test('Sample min', () {
      expect(stats.min > min, true);
    });
    test('Sample max', () {
      expect(stats.max < max, true);
    });
    test('Sample median', () {
      expect(stats.median, closeTo(min + h, 0.25));
    });
    test('Sample mean', () {
      expect(stats.mean, closeTo(min + h, 0.25));
    });
    test('stdDev', () {
      final mid = min + (max - min) / 2;
      expect(
          stats.stdDev,
          closeTo(
              math.sqrt((min * min +
                      max * max +
                      mid * mid -
                      mid * max -
                      mid * min -
                      max * min) /
                  18),
              0.25));
    });
  });

  group('sampleNormalPdf:', () {
    final mean = 0.0;
    final stdDev = 2.0;
    final min = -20;
    final max = 20;
    final n = 1000;
    double pdf(num x) => normalPdf(x, mean, stdDev);
    final sample = randomSample(n, min, max, pdf(mean), pdf);
    final stats = Stats(sample);
    test('Sample size', () {
      expect(sample.length, n);
    });
    test('Sample median', () {
      expect(stats.median, closeTo(mean, 0.25));
    });
    test('Sample mean', () {
      expect(stats.mean, closeTo(mean, 0.25));
    });
    test('stdDev', () {
      expect(stats.stdDev, closeTo(stdDev, 0.25));
    });
  });

  group('sampleTruncatedNormalPdf:', () {
    final mean = 3.0;
    final stdDev = 1.0;
    final min = 1.5;
    final max = 6;
    final n = 2000;
    double pdf(num x) => truncatedNormalPdf(x, min, max, mean, stdDev);
    final sample = randomSample(n, min, max, pdf(mean), pdf);
    final stats = Stats(sample);
    test('Sample size', () {
      expect(sample.length, n);
    });
    test('Sample min', () {
      expect(stats.min > min, true);
    });
    test('Sample max', () {
      expect(stats.max < max, true);
    });
    test('Sample mean', () {
      expect(stats.mean,
          closeTo(meanTruncatedNormal(min, max, mean, stdDev), 0.05));
    });
    test('stdDev', () {
      expect(stats.stdDev,
          closeTo(stdDevTruncatedNormal(min, max, mean, stdDev), 0.05));
    });
  });
}
