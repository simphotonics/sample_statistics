import 'package:sample_statistics/sample_statistics.dart' show Precision;
import 'package:test/test.dart';

void main() {
  group('leadingZeros:', () {
    test('0', () {
      expect(0.leadingZeros, 0);
    });
    test('10.000478', () {
      expect(10.000478.leadingZeros, 3);
    });
    test('-10.000478', () {
      expect((-10.000478).leadingZeros, 3);
    });
    test('-10', () {
      expect((-10).leadingZeros, 0);
    });
    test('1e-10', () {
      expect(1e-10.leadingZeros, 10);
    });
    test('1e-20', () {
      expect(1e-20.leadingZeros, 20);
    });
    test('1e-30', () {
      expect(1e-30.leadingZeros, 30);
    });
  });
  group('toStringAsFixedDigits:', () {
    test('0.0', () {
      expect(0.0.toStringAsFixedDigits(2), '0.00');
    });
    test('0', () {
      expect(0.toStringAsFixedDigits(2), '0.00');
    });
    test('10.000478', () {
      expect(10.000478.toStringAsFixedDigits(2), '10.00048');
    });
    test('-10.000478', () {
      expect((-10.000478).toStringAsFixedDigits(2), '-10.00048');
    });
    test('1e-10', () {
      expect(1e-10.toStringAsFixedDigits(2), '0.000000000100');
    });
    test('1000000', () {
      expect(1000000.toStringAsFixedDigits(2), '1000000.00');
    });
  });
}
