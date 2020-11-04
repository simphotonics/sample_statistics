import 'dart:math' as math;

import 'package:minimal_test/minimal_test.dart';
import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) {
  group('samplePdf', () {
    final min = -4.0;
    final max = 5.0;
    final h = (max - min) / 2;
    final n = 1000;
    num pdf(num x) => triangularPdf(x, min, max);
    final sample = samplePdf(n, min, max, pdf(min + h), pdf);
    final stats = SampleStats(sample);

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
      expect(stats.median, min + h, precision: 0.25);
    });
    test('Sample mean', () {
      expect(stats.mean, min + h, precision: 0.25);
    });
    test('stdDev', () {
      final mid = min + (max - min) / 2;
      expect(
          stats.stdDev,
          math.sqrt((min * min +
                  max * max +
                  mid * mid -
                  mid * max -
                  mid * min -
                  max * min) /
              18),
          precision: 0.25);
    });
  });

  group('sampleNormalPdf', () {
    final mean = 0.0;
    final stdDev = 2.0;
    final min = -20;
    final max = 20;
    final n = 1000;
    num pdf(num x) => normalPdf(x, mean, stdDev);
    final sample = samplePdf(n, min, max, pdf(mean), pdf);
    final stats = SampleStats(sample);
    test('Sample size', () {
      expect(sample.length, n);
    });
    test('Sample median', () {
      expect(stats.median, mean, precision: 0.25);
    });
    test('Sample mean', () {
      expect(stats.mean, mean, precision: 0.25);
    });
    test('stdDev', () {
      expect(stats.stdDev, stdDev, precision: 0.25);
    });
  });

  group('sampleTruncatedNormalPdf', () {
    final mean = 3.0;
    final stdDev = 1.0;
    final min = 1.5;
    final max = 6;
    final n = 2000;
    num pdf(num x) => truncatedNormalPdf(x, min, max, mean, stdDev);
    final sample = samplePdf(n, min, max, pdf(mean), pdf);
    final stats = SampleStats(sample);
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
      expect(stats.mean, meanTruncatedNormal(min, max, mean, stdDev),
          precision: 0.05);
    });
    test('stdDev', () {
      expect(stats.stdDev, stdDevTruncatedNormal(min, max, mean, stdDev),
          precision: 0.05);
    });
  });
}
