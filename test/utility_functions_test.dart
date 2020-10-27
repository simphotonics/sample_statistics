import 'dart:math';

import 'package:minimal_test/minimal_test.dart';
import 'package:statistics/statistics.dart';

Type reflectType<T>() => T;

void main() {
  group('erf(x)', () {
    test('dxMax: 0.1', () {
      expect((erf(0.85) - 0.7706680576083525323800).abs() < 1e-6, true);
    });
    test('dxMax: 0.01', () {
      expect((erf(0.85, dxMax: 0.01) - 0.7706680576083525323800).abs() < 1e-8,
          true);
    });
    test('dxMax: 0.001', () {
      expect((erf(0.85, dxMax: 0.001) - 0.7706680576083525323800).abs() < 1e-10,
          true);
    });
    test('anti-symmetric property', () {
      expect(erf(-0.85), -erf(0.85));
    });
    test('limit large positive numbers', () {
      expect(erf(-1000000), -1.0);
    });
    test('limit large negative numbers', () {
      expect(erf(1000000), 1.0);
    });
    test('erf(0.85)', () {
      expect(erf(0.80), 0.7421009647076604861671);
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
