import '../typedef/numerical_function.dart';

extension Integration on NumericalFunction {
  /// Returns the definite integral of `this` over the interval
  /// ([lowerLimit], [upperLimit]).
  ///
  /// * Convergence is not guaranteed even for [dx] -> 0.
  /// * The maximum number of integration sub-intervals is 100000.
  ///   To achieve this set [dx] = 0.
  /// * The algorithm uses the trapezoidal approximation.
  ///
  /// ```Dart
  /// // Usage
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
