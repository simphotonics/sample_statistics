import '../typedef/numerical_function.dart';

extension Differentiation on NumericalFunction {
  /// Returns the first derivative of the function `this` at [x].
  ///
  /// ```Dart
  /// // Usage
  /// import 'dart:math';
  /// final diff = sin.ddx(0.5)
  /// ```
  /// The error of the approximation is of the order `pow(dx, 2)`.
  double ddx(num x, [num dx = 1e-4]) =>
      // (this(x - 2 * dx) -
      //     this(x + 2 * dx) -
      //     8 * this(x - dx) +
      //     8 * this(x + dx)) /
      // (12 * dx);
      (this(x + dx) - this(x - dx)) / (2 * dx);

  /// Returns the second derivative of the function `this` at [x].
  ///
  /// ```Dart
  /// // Usage
  /// import 'dart:math';
  /// final diff = sin.d2dx2(0.5)
  /// ```
  /// The error of the approximation is of the order `pow(dx, 2)`.
  double d2dx2(num x, [num dx = 1e-4]) =>
      // (-this(x - 2 * dx) -
      //     this(x + 2 * dx) +
      //     16 * (this(x + dx) + this(x - dx)) -
      //     30 * this(x)) /
      // (12 * dx * dx);
      (this(x + dx) + this(x - dx) - 2 * this(x)) / (dx * dx);
}
