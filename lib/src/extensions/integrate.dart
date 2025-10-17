/// Typedef of a function with a single positional parameter of type
/// `T extends num` and return type `T`.
typedef NumericalFunction = double Function(num);

extension Integration on NumericalFunction {
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
  double integrate(num lowerLimit, num upperLimit, {num dx = 0.1}) {
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

extension Differentiation on NumericalFunction {
  /// Returns the first derivative of the function `this` at [x].
  ///
  /// Usage:
  /// ```Dart
  /// import 'dart:math';
  /// final diff = sin.ddx(0.5)
  /// ```
  /// The error of the approximation is of the order `pow(dx, 2)`.
  /// The default value of `dx` is 1e-4.
  double ddx(num x, [num dx = 1e-4]) =>
      // (this(x - 2 * dx) -
      //     this(x + 2 * dx) -
      //     8 * this(x - dx) +
      //     8 * this(x + dx)) /
      // (12 * dx);
      (this(x + dx) - this(x - dx)) / (2 * dx);

  /// Returns the second derivative of the function `this` at [x].
  ///
  /// Usage:
  /// ```Dart
  /// import 'dart:math';
  /// final diff = sin.d2dx2(0.5)
  /// ```
  /// The error of the approximation is of the order `pow(dx, 2)`.
  /// The default value of `dx` is 1e-4.
  double d2dx2(num x, [num dx = 1e-4]) =>
      // (-this(x - 2 * dx) -
      //     this(x + 2 * dx) +
      //     16 * (this(x + dx) + this(x - dx)) -
      //     30 * this(x)) /
      // (12 * dx * dx);
      (this(x + dx) + this(x - dx) - 2 * this(x)) / (dx * dx);
}
