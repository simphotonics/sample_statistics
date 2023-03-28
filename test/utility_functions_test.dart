import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:sample_statistics/sample_statistics.dart';
import 'package:test/test.dart';

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
      expect(polynomial(pi, a), closeTo(sum, 1e-10));
    });
  });

  group('erf(x)', () {
    test('erf(0.85)', () {
      expect(erf(0.85), 0.7706680576083525323800);
    });
    test('erf(0.8)', () {
      expect(erf(0.80), closeTo(0.7421009647076604861671, 1e-15));
    });
    test('erf(1.8)', () {
      expect(erf(1.8), 0.98909050163573071418373281);
    });
    test('anti-symmetric property', () {
      expect(erf(-0.85), -erf(0.85));
    });
    test('erf(-2)', () {
      expect(erf(-2), closeTo(-0.99532226501895273416206926, 1e-20));
    });
    test('erf(-10)', () {
      expect(erf(-10), -1.0);
    });
    test('erf(10)', () {
      expect(erf(10), 1.0);
    });
  });

  group('erfc(x)', () {
    test('erfc(0.85)', () {
      expect(erfc(0.85), 1.0 - 0.7706680576083525323800);
    });
    test('erfc(0.8)', () {
      expect(erfc(0.80), closeTo(0.257899035292339513832889413497, 1e-16));
    });

    test('erfc(3.0)', () {
      expect(erfc(3.0), closeTo(2.20904969985854413727761295823E-5, 1e-15));
    });

    test('erfc(5)', () {
      expect(erfc(5), closeTo(1.53745979442803485018834348538E-12, 1e-15));
    });

    test('erfc(8)', () {
      expect(erfc(8), closeTo(1.122429717298292707997E-29, 1e-25));
    });

    test('erfc(20)', () {
      expect(erfc(20), closeTo(5.395865611607900928935E-176, 1e-25));
    });
  });
  group('erfx(x)', () {
    test('erfx(0.8)', () {
      expect(erfx(0.8), closeTo(erfxTable[0.8]!, 1e-16));
    });
    test('erfx(3.0)', () {
      expect(erfx(3.0), closeTo(erfxTable[3.0]!, 1e-10));
    });

    test('erfx(5)', () {
      expect(erfx(5.0), closeTo(erfxTable[5.0]!, 1e-4));
    });

    test('erfx(8)', () {
      expect(erfx(8.0), closeTo(erfxTable[8.0]!, 1e-3));
    });
    test('erfx(20)', () {
      expect(erfx(20.0), closeTo(erfxTable[20.0]!, 1e-25));
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
    test('sin.integrate(0, 2*pi)', () {
      expect(sin.integrate(0, 2 * pi), closeTo(0.0, 1e-12));
    });
    test('sin.integrate(0, pi/2)', () {
      expect(sin.integrate(0, pi / 2, dx: 1e-6), closeTo(1.0, 1.0e-6));
    });
    test('integrate(x, 0, 1)', () {
      expect(((num x) => x).integrate(0, 1, dx: 1e-2), closeTo(0.5, 1e-12));
    });
    test('integrate(1, 0, 1)', () {
      expect(((num x) => 1.0).integrate(0, 1, dx: 0.1), closeTo(1.0, 1e-12));
    });
    test('sin.integrate( 0, 1) == -sin.integrate( 1, 0)', () {
      expect((sin.integrate(0, 1) + sin.integrate(1, 0)), 0.0);
    });
    test('sin.integrate( 0, 0) == 0.0', () {
      expect(sin.integrate(0, 0), 0.0);
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
      list.removeOutliers();
      expect(list, [-3, -2, 0, 1, 2, 2, 3, 4, 4, 4, 5, 6, 6, 7, 8, 10, 11]);
    });
  });
}
