import 'dart:math' show max;

import '../enum/integration_method.dart';

import '../typedef/numerical_function.dart';
import 'differentiation.dart';

extension Integration on NumericalFunction {
  /// Returns the definite integral of `this` over the interval
  /// ([lowerLimit], [upperLimit]).
  ///
  /// * Convergence is not guaranteed even for [dx] -> 0.
  /// * The maximum number of integration sub-intervals is 100000.
  ///   To achieve this set [dx] = 0.
  /// * To choose between the trapezoidal approximation and the mid-point
  ///   approximation use the parameter [method].
  ///
  /// ```Dart
  /// // Usage
  /// final result = sin(x).integrate(0, pi/2)
  /// ```
  double integrate(
    num lowerLimit,
    num upperLimit, {
    num dx = 1e-4,
    IntegrationMethod method = IntegrationMethod.midPoint,
  }) {
    if (dx == 0) {
      throw ArgumentError(
        'Error in extension method "integrate". '
            'Found: dx == 0.',
        'dx',
      );
    }
    if (upperLimit == lowerLimit) {
      return 0.0;
    }
    final n = max((upperLimit - lowerLimit) ~/ dx, 10).abs();
    // Integration sub-interval:
    dx = (upperLimit - lowerLimit) / n;

    switch (method) {
      case IntegrationMethod.midPoint:
        final lowerLimitPrime = lowerLimit + dx / 2;
        var integral = this(lowerLimitPrime) + this(upperLimit - dx / 2);
        // Notice that the sum runs from i = 1 to i = n-2.
        for (var i = 1; i < n - 1; ++i) {
          integral += this(lowerLimitPrime + dx * i);
        }
        return integral * dx;
      case IntegrationMethod.trapezoidal:
        // Trapezoidal integration (note the starting and end indicees).
        var integral = 0.5 * (this(lowerLimit) + this(upperLimit));
        for (var i = 1; i < n; ++i) {
          integral += this(lowerLimit + i * dx);
        }
        return integral * dx;
    }
  }

  /// Error at the integration of sub-interval with width [dx] centered around
  /// [argument].
  double localIntegrationError(
    num argument, {
    num dx = 1e-4,
    IntegrationMethod method = IntegrationMethod.midPoint,
  }) {
    if (dx == 0) {
      throw ArgumentError(
        'Error in extension method: "integrationError". '
            'Found: dx == 0.',
        'dx',
      );
    }
    switch (method) {
      case IntegrationMethod.midPoint:
        return dx * dx * dx * d2dx2(argument, dx).abs() / 24;
      case IntegrationMethod.trapezoidal:
        return dx * dx * dx * d2dx2(argument, dx) / 12;
    }
  }

  /// Upper estimate of the error occurring when integrating `this` from
  /// [lowerLimit] to [upperLimit] using an approx. step-size of [dx].
  double integrationError(
    num lowerLimit,
    num upperLimit, {
    num dx = 1e-4,
    IntegrationMethod method = IntegrationMethod.midPoint,
  }) {
    if (dx == 0) {
      throw ArgumentError(
        'Error in extension method: "integrationError". '
            'Found: dx == 0.',
        'dx',
      );
    }
    final n = (upperLimit - lowerLimit).abs() ~/ dx.abs();
    double d2Max = d2dx2(lowerLimit, dx).abs();
    for (var i = 1; i < n - 1; i++) {
      final d2 = d2dx2(lowerLimit + i * dx).abs();
      d2Max = d2Max < d2 ? d2 : d2Max;
    }
    switch (method) {
      case IntegrationMethod.midPoint:
        return dx * dx * d2Max * (upperLimit - lowerLimit) / 24;
      case IntegrationMethod.trapezoidal:
        return dx * dx * d2Max * (upperLimit - lowerLimit) / 12;
    }
  }
}
