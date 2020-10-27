import 'dart:math' as math;

import 'package:exception_templates/exception_templates.dart';
import 'package:minimal_test/minimal_test.dart';
import 'package:statistics/src/exceptions/invalid_function_parameter.dart';
import 'package:statistics/statistics.dart';

Type reflectType<T>() => T;

void main() {
  group('Uniform dist.', () {
    final min = -2.0;
    final max = 3.0;
    num pdf(num x) => uniformPdf(x, min, max);
    test('Shape', () {
      expect(pdf(-2.5), 0);
      expect(pdf(3.5), 0);
      expect(pdf(0.5), 1 / (max - min));
    });
    test('Normalization', () {
      expect(integrate(pdf, min, max), 1.0);
    });
  });
  group('Cumulative uniform dist.', () {
    final min = -2.0;
    final max = 3.0;
    num pdf(num x) => uniformPdf(x, min, max);
    test('Limits', () {
      expect(uniformCdf(-2.1, min, max), 0);
      expect(uniformCdf(3.0, min, max), 1.0);
    });
    test('Value', () {
      expect(uniformCdf(1.0, min, max), integrate(pdf, min, 1.0));
    });
  });

  group('Exp. dist.', () {
    final mean = 2.5;
    num pdf(num x) => expPdf(x, mean);
    test('Shape', () {
      expect(pdf(0), 1 / mean);
      expect(pdf(100 * mean), 0);
    });
    test('Value', () {
      expect(pdf(math.log(2) * mean), 0.5 / mean);
    });
    test('Normalization', () {
      expect(integrate(pdf, 0, 10 * mean, dxMax: 0.1), 1.0, precision: 1.0e-4);
    });
  });

  group('Exp. cumulative dist.', () {
    final mean = 2.5;
    test('Limits', () {
      expect(expCdf(0.0, mean), 0);
      expect(expCdf(30 * mean, mean), 1.0);
    });
    test('Value', () {
      expect(expCdf(math.log(2) * mean, mean), 0.5);
    });
  });

  group('normalPdf', () {
    test('is normalized', () {
      expect(integrate((x) => normalPdf(x, 0, 1.0), -10, 10), 1.0);
    });
  });

  group('normalCdf', () {
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
      expect(stdNormalCdf(0.8), 0.7881446014166033144245, precision: 1e-6);
    });
  });

  group('truncatedNormalPdf()', () {
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
      expect(stdNormalPdf(0.0), truncatedNormalPdf(0.0, -100, 100, 0.0, 1.0));
      expect(stdNormalPdf(0.5), truncatedNormalPdf(0.5, -100, 100, 0.0, 1.0));
    });
    test('is normalized', () {
      expect(integrate(stdNormalPdf, -10, 10), 1.0);
      expect(
        integrate((x) => truncatedNormalPdf(x, -2, 2, 0, 1.0), -2, 2,
            dxMax: 1e-3),
        1.0,
        precision: 1e-6,
      );
    });
  });

  group('Triangular pdf', () {
    final min = 4.0;
    final max = 10.0;
    final h = (max - min) / 2;
    test('Shape', () {
      expect(triangularPdf(min, min, max), 0);
      expect(triangularPdf(max, min, max), 0);
      expect(
          triangularPdf(
            min + h,
            min,
            max,
          ),
          triangularPdf(
            max - h,
            min,
            max,
          ));

      expect(triangularPdf(min + h, min, max), 1 / h);
      expect(triangularPdf(max - h + 1e-12, min, max), 1 / h);
    });
    test('Is normalized', () {
      expect(integrate((x) => triangularPdf(x, min, max), min, max), 1.0);
    });
  });
}
