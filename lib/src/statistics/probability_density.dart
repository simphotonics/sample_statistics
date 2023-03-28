/// Library providing common probability density functions.

import 'dart:math' as math;
import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

import '../exceptions/invalid_function_parameter.dart';
import 'error_function.dart';

/// Small number used to ensure that a
/// denominator is non-null.
const num epsilon = 1e-50;

/// A probability density function.
typedef ProbabilityDensity = double Function(num x);

/// Standard normal probability
/// density function (with a mean of zero
/// and a standard deviation equal to one) .
double stdNormalPdf(num x) => invSqrt2Pi * math.exp(-0.5 * x * x);

/// Standard normal cumulative probability distribution.
double stdNormalCdf(num x) {
  return 1.0 - 0.5 * erfc(x * invSqrt2);
  //return 0.5 + 0.5 * erf(x * invSqrt2);
}

/// Normal probability density function.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `stdDev < 0`.
double normalPdf(num x, num mean, num stdDev) {
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

/// Normal cumulative probability density function.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `stdDev < 0`.
double normalCdf(num x, num mean, num stdDev) {
  if (stdDev <= 0.0) {
    throw throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'stdDev: $stdDev <= 0.',
      expectedState: 'stdDev > 0',
    );
  }
  return 1 - 0.5 * erfc((x - mean) / (math.sqrt2 * stdDev));
}

/// Truncated normal probability density function
/// * `xMin`: left limit.
/// * `xMax`: right limit satisfying `xMin < xMax`.
/// * `meanOfParent`: Mean of the *parent* normal distribution.
/// * `stdDevOfParent`: Standard deviation of the *parent* normal distribution.
/// * `truncatedNormalPdf(x) > 0` for `x` in `(xMin, xMax)` and zero elsewhere.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
double truncatedNormalPdf(
  num x,
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent,
) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in truncatedNormalPdf($x, $xMin, $xMax, '
          '$meanOfParent, $stdDevOfParent)',
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'xMin < xMax',
    );
  }
  stdDevOfParent = stdDevOfParent.abs();
  if (x < xMin || x > xMax) {
    return 0.0;
  } else {
    final invStdDev = 1.0 / stdDevOfParent;
    final alpha = (xMin - meanOfParent) * invStdDev;
    final beta = (xMax - meanOfParent) * invStdDev;

    return stdNormalPdf((x - meanOfParent) * invStdDev) /
        (stdNormalCdf(beta) - stdNormalCdf(alpha));
  }
}

/// Truncated normal cumulative
/// probability density function
/// * `min`: left limit.
/// * `max`: right limit satisfying `min < max`.
/// * `meanOfParent`: Mean of the *parent* normal distribution.
/// * `stdDevOfParent`: Standard deviation of the *parent* normal distribution.
/// * `truncatedNormalPdf(x) > 0` for `x` in `(xMin, xMax)` and zero elsewhere.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
double truncatedNormalCdf(
  num x,
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent,
) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in truncatedNormalCdf($x, $xMin, $xMax, '
          '$meanOfParent, $stdDevOfParent)',
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'xMmin < xMmax',
    );
  }
  final invStdDev = 1.0 / stdDevOfParent;
  final alpha = (xMin - meanOfParent) * invStdDev;
  final beta = (xMax - meanOfParent) * invStdDev;
  if (x <= xMin) return 0.0;
  if (x >= xMax) return 1.0;

  return (stdNormalCdf((x - meanOfParent) * invStdDev) - stdNormalCdf(alpha)) /
      (stdNormalCdf(beta) - stdNormalCdf(alpha) + epsilon);
}

/// Returns the mean of a truncated normal distribution
/// with minimum value [xMin], maximum
/// value [xMax], and a parent normal distribution with
/// mean [meanOfParent], and standard deviation [stdDevOfParent].
double meanTruncatedNormal(
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent,
) {
  final alpha = (xMin - meanOfParent) / stdDevOfParent;
  final beta = (xMax - meanOfParent) / stdDevOfParent;

  return meanOfParent +
      stdDevOfParent *
          (stdNormalPdf(alpha) - stdNormalPdf(beta)) /
          (stdNormalCdf(beta) - stdNormalCdf(alpha));
}

/// Local alias (used in energy function see below).
double _meanTruncatedNormal(
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent,
) =>
    meanTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent);

/// Returns the standard deviation of a truncated normal distribution
/// with minimum value [xMin], maximum
/// value [xMax], and a parent normal distribution with
/// mean [meanOfParent], and standard deviation [stdDevOfParent].
double stdDevTruncatedNormal(
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent,
) {
  final alpha = (xMin - meanOfParent) / stdDevOfParent;
  final beta = (xMax - meanOfParent) / stdDevOfParent;
  final pdfAlpha = stdNormalPdf(alpha);
  final pdfBeta = stdNormalPdf(beta);
  final z = (stdNormalCdf(beta) - stdNormalCdf(alpha) + epsilon);

  return stdDevOfParent *
      math.sqrt(1.0 +
          (alpha * pdfAlpha - beta * pdfBeta) / z -
          math.pow((pdfAlpha - pdfBeta) / z, 2));

  // final expAlpha = math.exp(0.5 * alpha * alpha);
  // final expBeta = math.exp(0.5 * beta * beta);
  // final z = erfx(beta * invSqrt2) * expAlpha -
  //     erfx(alpha * invSqrt2) * expBeta +
  //     epsilon;

  // return stdDevOfParent *
  //     math.sqrt(1.0 +
  //         2 * invSqrt2Pi * (alpha * expBeta - beta * expAlpha) / z -
  //         2 / math.pi * math.pow((expBeta - expAlpha) / z, 2));
}

/// Local alias used in energy function (see below).
double _stdDevTruncatedNormal(
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent,
) =>
    stdDevTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent);

/// Returns a `Future<Map<String, num>>`
/// containing
/// the mean and standard deviation
/// of the **parent distribution** of
/// a truncated normal distribution
/// with:
///
/// * `xMin`: Left limit of the truncated normal distribution,
/// * `xMax`: Right limit of the truncated normal distribution. `xMin < xMax`,
/// * `meanOfTruncatedNormal`: mean of the truncated normal,
/// * `stdDevOfTruncatedNormal`: standard deviation of the truncated normal.
///
/// Important: The function uses a simulated annealing algorithm,
/// and convergence is not strictly guaranteed.
///
/// Note: The distribution must have a maximum between
/// `xMin` and `xMax`, that is the parent distribution must have
/// `xMin < mean < xMax`.
///
/// Usage:
/// ```Dart
/// import 'package:sample_statistics/sample_statistics.dart';
/// void main(List<String> args) async {
///   final xMin = 2.0;
///   final xMax = 7.0;
///   final meanTruncatedNormal = 4.0;
///   final stdDevTruncatedNormal = 2.0;
///   final Map<String, double> result = await truncatedNormalToNormal(
///       xMin,
///       xMax,
///       meanTr,
///       stdDevTr,
///   );
///
///   print('mean: ${result[0]}, stdDev: ${result[1]});
/// }
/// ```
Future<Map<String, num>> truncatedNormalToNormal(
  num xMin,
  num xMax,
  num meanTruncatedNormal,
  num stdDevTruncatedNormal, {
  num stdDevMin = 0.1,
  num stdDevMax = 5,
}) async {
  final mean = FixedInterval(
    xMin + stdDevMin,
    xMax - stdDevMin,
    name: 'mean',
  );
  final stdDev = FixedInterval(
    stdDevTruncatedNormal / 2,
    stdDevTruncatedNormal * 2,
    name: 'stdDev',
  );
  final space = SearchSpace.fixed(
    [mean, stdDev],
  );

  num logBase(num x, {num base = 10}) {
    return log(x) / log(base);
  }

  // This function will be minimized.
  num energy(List<num> x) {
    final result = (pow(
            meanTruncatedNormal - _meanTruncatedNormal(xMin, xMax, x[0], x[1]),
            2) +
        pow(
            stdDevTruncatedNormal -
                _stdDevTruncatedNormal(xMin, xMax, x[0], x[1]),
            2) +
        1e-20);
    // if (result.isNaN || result.isInfinite) {
    //   print('$x => energy: $result ');
    // }

    return logBase(result);
  }

  final field = EnergyField(energy, space);

  final sim = LoggingSimulator(
    field,
    gammaStart: 0.7,
    gammaEnd: 0.1,
    outerIterations: 100,
    innerIterationsStart: 3,
    innerIterationsEnd: 6,
    sampleSize: 250,
  )
    ..deltaPositionStart = [stdDevTruncatedNormal, meanTruncatedNormal]
    // ..deltaPositionEnd  = [1e-8, 1e-8]
    ..temperatureSequence = exponentialSequence
    ..startPosition = [meanTruncatedNormal, stdDevTruncatedNormal];

  final result = await sim.anneal(
    isRecursive: true,
    ratio: 0.7,
  );

  // await File('example/data/log.dat').writeAsString(sim.export());
  return {'mean': result[0], 'stdDev': result[1]};
}

/// Uniform probability density function
/// with non-zero support over the interval `(xMin, xMax)`.
///
/// Throws an exception of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
double uniformPdf(num x, num xMin, num xMax) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in uniformPdf($x, $xMin, $xMax)',
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'min < max',
    );
  }
  return (x < xMin || x > xMax) ? 0.0 : 1.0 / (xMax - xMin);
}

/// Uniform cumulative probability density function
/// with non-zero support over the interval `(xMin, xMax)`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
double uniformCdf(num x, num xMin, num xMax) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'min < max',
    );
  }
  if (x < xMin) return 0.0;
  if (x > xMax) return 1.0;
  return (x - xMin) * uniformPdf(x, xMin, xMax);
}

/// Exponential density function
/// with non-zero support over the interval `(0, inf)`.
///
/// Throws an exception of type `ErrorOfType<InvalidFunctionParameter>`
/// if `mean <= 0`.
double expPdf(num x, num mean) {
  if (mean <= 0) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in expPdf($x, $mean).',
      invalidState: 'mean: $mean <= 0.',
      expectedState: 'mean > 0',
    );
  }

  return (x.isNegative) ? 0.0 : 1.0 / mean * math.exp(-x / mean);
}

/// Exponential cumulative probability density function
/// with non-zero support over the interval `(0, inf)`.
///
/// Throws an exception of type `ErrorOfType<InvalidFunctionParameter>`
/// if `mean <= 0`.
double expCdf(num x, num mean) {
  if (mean <= 0) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in expCdf($x, $mean).',
      invalidState: 'mean: $mean <= 0.',
      expectedState: 'mean > 0',
    );
  }
  return (x.isNegative) ? 0.0 : 1.0 - math.exp(-x / mean);
}

/// Triangular probability density function
/// with non-zero support over the interval `(xMin, xMax)`.
///
/// The maximum occurs at `(xMax - xMin) / 2`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
double triangularPdf(num x, num xMin, num xMax) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in triangularPdf($x, $xMin, $xMax)',
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'min < max',
    );
  }
  if (x <= xMin) return 0.0;
  if (x >= xMax) return 0.0;
  final h = (xMax - xMin) / 2;
  if (x > xMin && x < xMin + h) {
    return (x - xMin) / (h * h);
  } else {
    return (xMax - x) / (h * h);
  }
}

/// Triangular cumulative probability density function
/// with non-zero support over the interval `(xMin, xMax)`.
///
/// The maximum of the probability density occurs at `(xMax - xMin) / 2`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
double triangularCdf(num x, num xMin, num xMax) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in triangularCdf($x, $xMin, $xMax)',
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'min < max',
    );
  }
  if (x <= xMin) return 0.0;
  if (x >= xMax) return 1.0;
  final range = xMax - xMin;
  final factor = 2.0 / (range * range);
  if (x > xMin && x < xMin + 0.5 * range) {
    return factor * (x - xMin) * (x - xMin);
  } else {
    return 1.0 - factor * (x - xMax) * (x - xMax);
  }
}
