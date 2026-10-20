import 'dart:math';

import 'package:sample_statistics/sample_statistics.dart' show Differentiation;
import 'package:test/test.dart';

void main() {
  group('Differentiation:', () {
    final dx = 1e-4;
    test('constant', () {
      double c(num x) => 10;
      expect(c.ddx(2.0), closeTo(0, dx * dx));
      expect(c.ddx(3.1), closeTo(0, dx * dx));
    });
    test('sin.ddx(0)', () {
      expect(sin.ddx(0), closeTo(1.0, dx * dx));
    });
    test('sin.ddx(pi/2):', () {
      expect(sin.ddx(pi / 2), closeTo(0.0, dx * dx));
    });
    test('sin.d2dx2(0)', () {
      expect(sin.d2dx2(0), closeTo(0, dx * dx));
    });
    test('sin.d2dx2(pi/2)', () {
      expect(sin.d2dx2(pi / 2), closeTo(-1, dx * dx));
    });
  });
}
