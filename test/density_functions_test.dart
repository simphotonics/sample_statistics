import 'dart:math' as math;

import 'package:exception_templates/exception_templates.dart';
import 'package:test/test.dart';

import 'package:sample_statistics/sample_statistics.dart';

Type reflectType<T>() => T;

void main() {
  group('uniformPdf.', () {
    final min = -2.0;
    final max = 3.0;
    num pdf(num x) => uniformPdf(x, min, max);
    test('Shape', () {
      expect(pdf(-2.5), 0);
      expect(pdf(3.5), 0);
      expect(pdf(0.5), 1 / (max - min));
    });
    test('Normalization', () {
      expect(pdf.integrate(min, max), closeTo(1.0, 1e-10));
    });
  });
  group('uniformCdf', () {
    final min = -2.0;
    final max = 3.0;
    num pdf(num x) => uniformPdf(x, min, max);
    test('Limits', () {
      expect(uniformCdf(-2.1, min, max), closeTo(0, 1e-10));
      expect(uniformCdf(3.0, min, max), closeTo(1.0, 1e-10));
    });
    test('Value', () {
      expect(
          uniformCdf(1.0, min, max), closeTo(pdf.integrate(min, 1.0), 1e-10));
    });
  });

  group('expPdf.', () {
    final mean = 2.5;
    num pdf(num x) => expPdf(x, mean);
    test('Shape', () {
      expect(pdf(0), 1 / mean);
      expect(pdf(100 * mean), closeTo(0, 1e-20));
    });
    test('value', () {
      expect(pdf(math.log(2) * mean), 0.5 / mean);
    });
    test('is normalized', () {
      expect(pdf.integrate(0, 10 * mean, dx: 0.1), closeTo(1.0, 1.0e-4));
    });
  });

  group('expCdf:', () {
    final mean = 2.5;
    test('Limits', () {
      expect(expCdf(0.0, mean), closeTo(0, 1e-12));
      expect(expCdf(30 * mean, mean), closeTo(1.0, 1e-12));
    });
    test('Value', () {
      expect(expCdf(math.log(2) * mean, mean), 0.5);
    });
  });

  group('normalPdf:', () {
    test('is normalized', () {
      expect(((x) => normalPdf(x, 0, 1.0)).integrate(-10, 10),
          closeTo(1.0, 1e-12));
    });
  });

  group('stdNormalCdf:', () {
    test('0 for small argument', () {
      expect(stdNormalCdf(-100.0), 0.0);
    });
    test('1 for large argument', () {
      expect(stdNormalCdf(100.0), 1.0);
    });
    test('y(0) = 0.5', () {
      expect(stdNormalCdf(0.0), 0.5);
    });
    test('y(0.8) = ', () {
      expect(stdNormalCdf(0.8), closeTo(0.7881446014166033144245, 1e-6));
    });
  });

  group('truncatedNormalPdf:', () {
    final min = -5;
    final max = 5;
    final mean = 1;
    final stdDev = 2.0;

    test('Zero for x < min', () {
      expect(truncatedNormalPdf(-6.0, min, max, mean, stdDev), 0.0);
    });
    test('Zero for x > max', () {
      expect(truncatedNormalPdf(6.0, min, max, mean, stdDev), 0.0);
    });
    test('Error if min > max', () {
      try {
        truncatedNormalPdf(10, max + 1, max, mean, stdDev);
      } catch (e) {
        expect(e.runtimeType,
            reflectType<ErrorOfType<InvalidFunctionParameter>>());
      }
    });
    test('Error if mean not in (min, ..., max)', () {
      try {
        truncatedNormalPdf(10, min, max, max + 1, stdDev);
      } catch (e) {
        expect(e.runtimeType,
            reflectType<ErrorOfType<InvalidFunctionParameter>>());
      }
    });
    test('Approaches normal dist. for min << mean << max', () {
      expect(stdNormalPdf(0.0), truncatedNormalPdf(0.0, -20, 20, 0.0, 1.0));
      expect(stdNormalPdf(0.5), truncatedNormalPdf(0.5, -20, 20, 0.0, 1.0));
    });
    test('is normalized', () {
      expect(stdNormalPdf.integrate(-20, 20), closeTo(1.0, 1e-6));
      expect(
          ((x) => truncatedNormalPdf(x, -2, 2, 0, 1.0))
              .integrate(-2, 2, dx: 1e-3),
          closeTo(1.0, 1e-6));
    });
  });

  group('truncatedNormalCdf', () {
    final min = -4;
    final max = 4;
    final mean = 0;
    final stdDev = 0.5;
    test('0 for small argument', () {
      expect(truncatedNormalCdf(min, min, max, mean, stdDev), 0.0);
    });
    test('1 for large argument', () {
      expect(truncatedNormalCdf(max, min, max, mean, stdDev), 1.0);
    });
    test('y(0) = 0.5', () {
      expect(truncatedNormalCdf(mean, min, max, mean, stdDev), 0.5);
    });
  });

  group('meanTruncatedNormal', () {
    var min = 2.0;
    var max = 6.0;
    var stdDev = 1.5;
    var mean = 3.0;
    test('min < mean < max', () {
      final meanT = meanTruncatedNormal(min, max, mean, stdDev);
      final stdDevT = stdDevTruncatedNormal(min, max, mean, stdDev);
      expect(meanT > min, true);
      expect(meanT < max, true);
      expect(stdDevT < stdDev, true);
    });
    test('mean < min', () {
      mean = -3.0;
      final meanT = meanTruncatedNormal(min, max, mean, stdDev);
      final stdDevT = stdDevTruncatedNormal(min, max, mean, stdDev);
      expect(meanT > min, true);
      expect(meanT < max, true);
      expect(stdDevT < stdDev, true);
    });
    test('mean > max', () {
      mean = 9.0;
      final meanT = meanTruncatedNormal(min, max, mean, stdDev);
      final stdDevT = stdDevTruncatedNormal(min, max, mean, stdDev);
      expect(meanT > min, true);
      expect(meanT < max, true);
      expect(stdDevT < stdDev, true);
    });
    test(' mean << min', () {
      mean = -9.0;
      final meanT = meanTruncatedNormal(min, max, mean, stdDev);
      final stdDevT = stdDevTruncatedNormal(min, max, mean, stdDev);
      expect(meanT > min, true);
      expect(meanT < max, true);
      expect(stdDevT < stdDev, true);
    });

    test(' max << mean', () {
      mean = 17.0;
      final meanT = meanTruncatedNormal(min, max, mean, stdDev);
      final stdDevT = stdDevTruncatedNormal(min, max, mean, stdDev);
      expect(meanT > min, true);
      expect(meanT < max, true);
      expect(stdDevT < stdDev, true);
    });
  });

  group('Triangular pdf:', () {
    final min = 4.0;
    final max = 10.0;
    final h = (max - min) / 2;
    test('value at limits', () {
      expect(triangularPdf(min, min, max), 0);
      expect(triangularPdf(max, min, max), 0);
    });
    test('mid value symmetry', () {
      expect(
        triangularPdf(min + h, min, max),
        triangularPdf(max - h, min, max),
      );
    });
    test('mid value', () {
      expect(triangularPdf(min + h, min, max), closeTo(1 / h, 1e-10));
      expect(triangularPdf(max - h + 1e-12, min, max), closeTo(1 / h, 1e-10));
    });
    test('Is normalized', () {
      expect(((x) => triangularPdf(x, min, max)).integrate(min - 1, max + 1),
          closeTo(1.0, 1e-12));
    });
  });

  group('Triangular cdf', () {
    final min = 4.0;
    final max = 10.0;
    final h = (max - min) / 2;
    test('left limit', () {
      expect(triangularCdf(4.0, min, max), 0);
    });
    test('right limit', () {
      expect(triangularCdf(10.0, min, max), 1.0);
    });
    test('value', () {
      expect(triangularCdf(min + h, min, max), 0.5);
    });
    test('equal to integrated pdf', () {
      expect(((x) => triangularPdf(x, min, max)).integrate(min, min + 1.0),
          closeTo(triangularCdf(min + 1.0, min, max), 1e-12));
      expect(((x) => triangularPdf(x, min, max)).integrate(min, min + 2.1),
          closeTo(triangularCdf(min + 2.1, min, max), 1e-12));
    });
  });
  group('truncatedNormalToNormal:', () {
    test('min < mean < max', () async {
      final min = -2.0;
      final max = 6.0;
      final meanOfParent = 3;
      final stdDevOfParent = 2.75;

      final meanTr = meanTruncatedNormal(
        min,
        max,
        meanOfParent,
        stdDevOfParent,
      );
      final stdDevTr = stdDevTruncatedNormal(
        min,
        max,
        meanOfParent,
        stdDevOfParent,
      );

      final params = await truncatedNormalToNormal(
        min,
        max,
        meanTr,
        stdDevTr,
      );

      expect(params['mean']!, closeTo(meanOfParent, 1e-3));
      expect(params['stdDev']!, closeTo(stdDevOfParent, 1e-3));
    });
  });
}
