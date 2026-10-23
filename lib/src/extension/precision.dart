import 'dart:math' show log;

const ln10 = 2.3025850929940456;

/// Enables printing numbers with a given number of non-zero fractional digits.
extension Precision on num {
  /// Returns the number of contiguous zeros following the decimal point.
  ///
  /// Usage:
  /// ```
  /// int zeros = 0.00045.leadingZeros; // zeros == 3
  /// ```
  int get leadingZeros {
    if (this is int) return 0;
    final fractionalPart = (this - truncate()).abs();
    return fractionalPart == 0.0 ? 0 : log(1.0 / fractionalPart) ~/ ln10;
  }

  /// Returns a decimal-string point representation of this number
  /// with [leadingZeros] + [nonZeroFractionDigits] digits after the decimal
  /// point.
  ///
  /// Usage:
  /// ```
  /// final d = 0.00000789987987;
  /// print(d.toStringAsFixedDigits(4)) // Prints: 0.000007899
  /// ```
  String toStringAsFixedDigits([int nonZeroFractionDigits = 2]) =>
      toStringAsFixed(leadingZeros + nonZeroFractionDigits);
}
