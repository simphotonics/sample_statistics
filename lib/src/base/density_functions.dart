library density_function;

import 'dart:math' as math;

import 'package:exception_templates/exception_templates.dart';

import '../exceptions/invalid_function_parameter.dart';
import 'utility_functions.dart';

/// A probability density function.
typedef ProbabilityDensity = num Function(num x);

/// **Standard normal** probability
/// density function (with zero mean
/// and standard deviation equal to one) .
num stdNormalPdf(num x) => invSqrt2Pi * math.exp(-0.5 * x * x);

/// **Standard normal cumulative** probability distribution.
num stdNormalCdf(num x) {
  return 0.5 + 0.5 * erf(x * invSqrt2);
}

/// **Normal** probability density function.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `stdDev < 0`.
num normalPdf(num x, num mean, num stdDev) {
  if (stdDev <= 0.0) {
    throw throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'stdDev: $stdDev <= 0.',
      expectedState: 'stdDev > 0',
    );
  }
  final invStdDev = 1.0 / stdDev;
  x = (x - mean) * invStdDev;
  return invSqrt2Pi * invStdDev * math.exp(-0.5 * x * x);
}

/// **Normal cumulative** probability density function.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `stdDev < 0`.
num normalCdf(num x, num mean, num stdDev) {
  if (stdDev <= 0.0) {
    throw throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'stdDev: $stdDev <= 0.',
      expectedState: 'stdDev > 0',
    );
  }
  return 0.5 + 0.5 * erf((x - mean) / (math.sqrt2 * stdDev));
}

/// **Truncated normal** probability density function
/// with parameters:
/// * `min`: left limit.
/// * `max`: right limit satisfying `min < max`.
/// * `mean`: sample mean satisfying `min < mean < max`.
/// * `stdDev`: corrected sample standard deviation. Must be a positive number.
/// * `truncatedNormalPdf(x) > 0` for `x` in the range (min, max) and zero elsewhere.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max` or if `mean` is outside the interval `(min, max)`.
num truncatedNormalPdf(
  num x,
  num min,
  num max,
  num mean,
  num stdDev,
) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }
  if (mean < min || mean > max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Invalid parameter mean: $mean.',
      invalidState: 'min: $min < mean: $mean < max: $max',
    );
  }
  stdDev = stdDev.abs();
  if (x < min || x > max) {
    return 0.0;
  } else {
    final invStdDev = 1.0 / stdDev;
    return stdNormalPdf((x - mean) * invStdDev) /
        (stdNormalCdf((max - mean) / stdDev) -
            stdNormalCdf((min - mean) / stdDev)) *
        invStdDev;
  }
}

/// **Truncated normal cumulative**
/// probability density function
/// with parameters:
/// * `min`: left limit.
/// * `max`: right limit satisfying `min < max`.
/// * `mean`: sample mean satisfying `min < mean < max`.
/// * `stdDev`: corrected sample standard deviation. Must be a positive number.
/// * `truncatedNormalPdf(x) > 0` for `x` in the range (min, max) and zero elsewhere.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max` or if `mean` is outside the interval `(min, max)`.
num truncatedNormalCdf(
  num x,
  num min,
  num max,
  num mean,
  num stdDev,
) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }
  if (mean < min || mean > max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Invalid parameter mean: $mean.',
      invalidState: 'min: $min < mean: $mean < max: $max',
    );
  }

  final invStdDev = 1.0 / stdDev;

  if (x <= min) return 0.0;
  if (x >= max) return 1.0;

  return
      (stdNormalCdf((x - mean) * invStdDev) -
              stdNormalCdf((min - mean) * invStdDev)) /
          (stdNormalCdf((max - mean) * invStdDev)) -
      stdNormalCdf((min - mean) * invStdDev);
}

/// Returns the mean of a truncated normal distribution
/// with minimum value [min], maximum
/// value [max], mean [mean], and standard deviation [stdDev].
///
num meanTruncatedNormal(num min, num max, num mean, num stdDev) {
  final alpha = (min - mean) / stdDev;
  final beta = (max - mean) / stdDev;
  return mean +
      (stdNormalPdf(alpha) - stdNormalPdf(beta)) /
          (stdNormalCdf(beta) - stdNormalCdf(alpha));
}

/// Returns the standard deviation of a truncated normal distribution
/// with minimum value [min], maximum
/// value [max], mean [mean], and standard deviation [stdDev].
num stdDevTruncatedNormal(num min, num max, num mean, num stdDev) {
  final alpha = (min - mean) / stdDev;
  final beta = (max - mean) / stdDev;
  final z = stdNormalCdf(beta) - stdNormalCdf(alpha);

  return stdDev *
      math.sqrt(1.0 +
          (alpha * stdNormalPdf(alpha) - beta * stdNormalPdf(beta)) / z +
          math.pow(stdNormalPdf(alpha) - stdNormalPdf(beta), 2) / (z * z));
}

/// **Uniform** probability density function
/// with non-zero support over the interval `(min, max)`.
///
/// Throws an exception of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max`.
num uniformPdf(num x, num min, num max) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }
  return (x < min || x > max) ? 0.0 : 1.0 / (max - min);
}

/// **Uniform cumulative** probability density function
/// with non-zero support over the interval `(min, max)`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max`.
num uniformCdf(num x, num min, num max) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }
  if (x < min) return 0.0;
  if (x > max) return 1.0;
  return (x - min) * uniformPdf(x, min, max);
}

/// **Exponential** density function
/// with non-zero support over the interval `(0, inf)`.
///
/// Throws an exception of type `ErrorOfType<InvalidFunctionParameter>`
/// if `mean <= 0`.
num expPdf(num x, num mean) {
  if (mean <= 0) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'mean: $mean <= 0.',
      expectedState: 'mean > 0',
    );
  }

  return (x.isNegative) ? 0.0 : 1.0 / mean * math.exp(-x / mean);
}

/// **Exponential cumulative** probability density function
/// with non-zero support over the interval `(0, inf)`.
///
/// Throws an exception of type `ErrorOfType<InvalidFunctionParameter>`
/// if `mean <= 0`.
num expCdf(num x, num mean) {
  if (mean <= 0) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'mean: $mean <= 0.',
      expectedState: 'mean > 0',
    );
  }
  return (x.isNegative) ? 0.0 : 1.0 - math.exp(-x / mean);
}

/// **Triangular** probability density function
/// with non-zero support over the interval `(min, max)`.
///
/// The maximum occurs at `(max - min) / 2`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max`.
num triangularPdf(num x, num min, num max) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }
  if (x <= min) return 0.0;
  if (x >= max) return 0.0;
  final h = (max - min) / 2;
  if (x > min && x < min + h) {
    return (x - min) / (h * h);
  } else {
    return (max - x) / (h * h);
  }
}

/// **Triangular cumulative** probability density function
/// with non-zero support over the interval `(min, max)`.
///
/// The maximum of the probability density occurs at `(max - min) / 2`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max`.
num triangularCdf(num x, num min, num max) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }
  if (x <= min) return 0.0;
  if (x >= max) return 1.0;
  final range = max - min;
  final factor = 2.0 / (range * range);
  if (x > min && x < min + 0.5 * range) {
    return factor * (x - min) * (x - min);
  } else {
    return 1.0 - factor * (x - max) * (x - max);
  }
}
