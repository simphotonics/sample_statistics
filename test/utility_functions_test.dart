import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:minimal_test/minimal_test.dart';

import 'package:sample_statistics/sample_statistics.dart';
import 'package:sample_statistics/src/exceptions/invalid_function_parameter.dart';


Type reflectType<T>() => T;

void main() {
  group('Factorial', () {
    test('Zero', () {
      expect(0.factorial, 1);
    });
    test('1.factorial', () {
      expect(1.factorial, 1);
    });
    test('4.factorial', () {
      expect(4.factorial, 24);
    });
    test('10.factorial', () {
      expect(10.factorial, 3628800);
    });
    test('InvalidFunctionParameter', () {
      try {
        (-10).factorial;
      } on ErrorOfType<InvalidFunctionParameter> catch (e) {
        expect(e.invalidState, '-10 < 0.');
      }
    });
  });

  group('Polynomial', () {
    test('empty coeff.', () {
      expect(polynomial(1.0, []), 0);
    });
    test('n = 0', () {
      expect(polynomial(1, [2.1]), 2.1);
    });
    test('n = 1', () {
      expect(polynomial(1, [2.1, 1]), 3.1);
    });
    test('n = 2', () {
      expect(polynomial(2, [2.1, 3, 4]), 2.1 + 3 * 2 + 4 * 2 * 2);
    });

    test('n = 6', () {
      // Polynomial coefficients.
      final a = [2.1, 1, 2, 3, 4, 5, 6];
      var sum = 0.0;
      for (var n = 0; n < a.length; ++n) {
        sum += a[n] * pow(pi, n);
      }
      expect(polynomial(pi, a), sum);
    });
  });

  group('erf(x)', () {
    test('erf(0.85)', () {
      expect(erf(0.85), 0.7706680576083525323800);
    });
    test('erf(0.8)', () {
      expect(erf(0.80), 0.7421009647076604861671, precision: 1e-15);
    });
    test('erf(1.8)', () {
      expect(erf(1.8), 0.98909050163573071418373281);
    });
    test('anti-symmetric property', () {
      expect(erf(-0.85), -erf(0.85));
    });
    test('erf(-2)', () {
      expect(erf(-2), -0.99532226501895273416206926, precision: 1e-20);
    });
    test('erf(-10)', () {
      expect(erf(-10), -1.0);
    });
    test('erf(10)', () {
      expect(erf(10), 1.0);
    });
  });

  group('Roots', () {
    test('Square Root', () {
      expect(4.root(2).roundToDouble(), 2.0);
    });
    test('Cubic Root', () {
      expect(8.root(3).roundToDouble(), 2.0);
      expect(7.root(3), 1.912931182772389101199);
    });
    test('32.0.root(5)', () {
      expect(32.root(5).roundToDouble(), 2.0);
    });
  });

  group('integrate', () {
    test('integrate(sin,0,2*pi)', () {
      expect(integrate(sin, 0, 2 * pi), 0.0);
    });
    test('integrate(sin, 0, pi/2)', () {
      expect(integrate(sin, 0, pi / 2), 1.0, precision: 1.0e-3);
    });
    test('integrate(x, 0, 1)', () {
      expect(integrate((num x) => x, 0, 1, dxMax: 1e-2), 0.5);
    });
    test('integrate(1, 0, 1)', () {
      expect(integrate((num x) => 1.0, 0, 1, dxMax: 0.1), 1.0);
    });
    test('integrate(sin, 0, 1) == -integrate(sin, 1, 0)', () {
      expect((integrate(sin, 0, 1) + integrate(sin, 1, 0)), 0.0);
    });
    test('integrate(sin, 0, 0) == 0.0', () {
      expect(integrate(sin, 0, 0), 0.0);
    });
  });

  group('StatsUtils', () {
    final list = [
      -21,
      -10,
      -3,
      -2,
      0,
      1,
      2,
      2,
      3,
      4,
      4,
      4,
      5,
      6,
      6,
      7,
      8,
      10,
      11,
      22
    ];
    test('Remove outliers', () {
      expect(list.removeOutliers(), [-21, -10, 22]);
      expect(list, [-3, -2, 0, 1, 2, 2, 3, 4, 4, 4, 5, 6, 6, 7, 8, 10, 11]);
    });
  });
}
