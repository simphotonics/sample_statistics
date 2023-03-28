/// Typedef of a function with a single positional parameter of type `num` and
/// return type `num`.
typedef NumericalFunction = num Function(num);

extension Integral on NumericalFunction {
  /// Returns the definite integral of `this` over the interval
  /// (`lowerLimit`,`upperLimit`).
  ///
  /// * Depending on the function the integral might not be defined.
  /// * Convergence is not guaranteed for even for `dx -> 0`.
  /// * The maximum number of integration sub-intervals is `100000`.
  ///   To achieve this set `dx = 0`.
  /// * The algorithm uses the trapezoidal approximation.
  /// Usage:
  /// ```Dart
  /// final result = sin(x).integrate(0, pi/2)
  /// ```
  num integrate(
    num lowerLimit,
    num upperLimit, {
    num dx = 0.1,
  }) {
    final interval = upperLimit - lowerLimit;
    dx = dx.abs();
    late int n;
    final int nMax = 100000;
    // Integration steps
    if (dx == 0) {
      n = nMax;
    } else {
      var n0 = (interval.abs() / dx).ceil();
      n0 = (n0 > nMax) ? nMax : n0;
      n = (n0 < 10) ? 10 : n0;
    }
    // Integration sub-interval:
    dx = interval / n;
    // Trapezoidal integration (note the starting and end indicees).
    var integral = 0.5 * (this(lowerLimit) + this(upperLimit));
    for (var i = 1; i < n; ++i) {
      integral += this(lowerLimit + i * dx);
    }
    return integral * dx;
  }
}

/// Returns the polynominal defined by
/// the coefficients `a`:
/// `a[0] + a[1] * x + ... + a[n-1] * pow(x, n - 1)`.
///
/// Recursive function based on Horner's rule.
num polynomial(num x, Iterable<num> a) {
  if (a.isEmpty) return 0;
  return a.first + x * polynomial(x, a.skip(1));
}

NumericalFunction poly(Iterable<num> a) {
  if (a.isEmpty) return (num x) => 0;
  return (num x) => poly(a.skip(1))(x) * x + a.first;
}

extension Operators on NumericalFunction {
  NumericalFunction operator +(NumericalFunction other) =>
      (num x) => this(x) + other(x);

  NumericalFunction operator -(NumericalFunction other) =>
      (num x) => this(x) - other(x);

  NumericalFunction operator *(NumericalFunction other) =>
      (num x) => this(x) * other(x);

  NumericalFunction operator /(NumericalFunction other) =>
      (num x) => this(x) / other(x);

  NumericalFunction operator ~/(NumericalFunction other) =>
      (num x) => this(x) / other(x);

  NumericalFunction operator -() => (num x) => -this(x);
}
