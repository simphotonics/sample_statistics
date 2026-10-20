import 'dart:math';

import 'package:sample_statistics/sample_statistics.dart';
import 'package:test/test.dart';

void main() {
  group('integrate', () {
    test('sin.integrate(0, 2*pi)', () {
      expect(sin.integrate(0, 2 * pi), closeTo(0.0, 1e-12));
    });
    test('sin.integrate(0, pi/2)', () {
      expect(sin.integrate(0, pi / 2, dx: 1e-6), closeTo(1.0, 1.0e-6));
    });
    test('integrate(x, 0, 1)', () {
      expect(
        ((num x) => x.toDouble()).integrate(0, 1, dx: 1e-2),
        closeTo(0.5, 1e-12),
      );
    });
    test('integrate(1, 0, 1)', () {
      expect(((num x) => 1.0).integrate(0, 1, dx: 0.1), closeTo(1.0, 1e-12));
    });
    test('lin.integrate( 0, 1) == -lin.integrate( 1, 0)', () {
      double lin(num x) => 4 * x - 4;
      expect(
        (lin.integrate(0, pi, dx: 1e-2) + lin.integrate(pi, 0, dx: 1e-8)),
        closeTo(0.0, 1e-12),
      );
    });
    test('sin.integrate( 0, 0) == 0.0', () {
      expect(sin.integrate(0, 0), 0.0);
    });
  });

  group('localIntegrationError:', () {
    test('linear', () {
      double lin(num x) => 4 * x + 3;
      expect(lin.localIntegrationError(0), isZero);
    });
  });

  group('integrationError:', () {
    test('linear', () {
      double lin(num x) => 4 * x + 3;
      expect(lin.integrationError(0, 10), closeTo(0.0, 1e-12));
    });
  });
}
