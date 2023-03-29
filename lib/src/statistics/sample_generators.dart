/// Random sample generators based on inversion
/// and rejection sampling algorithms.
import 'dart:math';

import 'package:exception_templates/exception_templates.dart';

import '../exceptions/invalid_function_parameter.dart';
import 'probability_density.dart';

/// Returns a random sample with probability density
/// `probabilityDensity`.
///
/// * `n`: sample size,
/// * `xMin`: lower limit of the sample values,
/// * `xMax`: upper limit of the sample values,
/// * `yMax`: maximum value of `pdf`,
/// * `seed`: optional random generator seed.
///
/// The generator uses a rejection sampling algorithm.
List<double> randomSample(
  int n,
  num xMin,
  num xMax,
  num yMax,
  ProbabilityDensity pdf, {
  int? seed,
}) {
  final result = <double>[];
  final random = Random(seed);
  final range = xMax - xMin;
  while (result.length < n) {
    final x = range * random.nextDouble() + xMin;
    final y = yMax * random.nextDouble();
    if (y < pdf(x)) {
      result.add(x);
    }
  }
  return result;
}

/// Returns a random sample containing `n` elements following a
/// truncated normal distribution with:
/// * `xMin`: minimum value,
/// * `xMax`: maximum value,
/// * `meanOfParent`: mean of parent normal distribution,
/// * `stdDevOfParent`: standard deviation of parent normal distribution.
/// ---
/// * `seed`: random generator seed (optional).
List<double> truncatedNormalSample(
  int n,
  num xMin,
  num xMax,
  num meanOfParent,
  num stdDevOfParent, {
  int? seed,
}) =>
    randomSample(
      n,
      xMin,
      xMax,
      truncatedNormalPdf(
        meanOfParent,
        xMin,
        xMax,
        meanOfParent,
        stdDevOfParent,
      ),
      (x) => truncatedNormalPdf(x, xMin, xMax, meanOfParent, stdDevOfParent),
      seed: seed,
    );

/// Returns a random sample with `n` elements following a
/// normal distribution with parameters:
/// * `mean`: mean value,
/// * `stdDev`: standard deviation.
/// ---
/// The following parameters are optional:
/// * `xMin`: minimum value (defaults to `mean - 10 * stdDev`),
/// * `xMax`: maximum value (defaults to `mean + 10 * stdDev`),
/// * `seed`: random generator seed.
List<double> normalSample(
  int n,
  num mean,
  num stdDev, {
  num? xMin,
  num? xMax,
  int? seed,
}) {
  xMin ??= mean - 10 * stdDev;
  xMax ??= mean + 10 * stdDev;
  return randomSample(
    n,
    xMin,
    xMax,
    normalPdf(mean, mean, stdDev),
    (x) => normalPdf(x, mean, stdDev),
    seed: seed,
  );
}

/// Returns a random sample of length `n` following an
/// exponential distribution.
/// * `mean` must be larger than zero,
/// * `seed` is optional (seeds the random number generator)
/// * The generator uses inversion sampling.
List<double> exponentialSample(
  int n,
  num mean, {
  int? seed,
}) {
  if (mean <= 0) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in function '
          'exponentialSample($n, $mean, seed: $seed).',
      expectedState: 'mean > 0',
      invalidState: 'mean = $mean',
    );
  }
  final random = Random(seed);
  return List<double>.generate(
      n, (_) => -mean * log(1.0 - random.nextDouble()));
}

/// Returns a random sample following a uniform distribution with
/// non-zero support over the range `xMin ... xMax`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
List<double> uniformSample(
  int n,
  num xMin,
  num xMax, {
  int? seed,
}) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'xMin: $xMin >= xMax: $xMax',
      expectedState: 'xMin < xMax',
    );
  }
  final random = Random(seed);
  return List<double>.generate(
    n,
    (_) => xMin + random.nextDouble() * (xMax - xMin),
  );
}

/// Returns a random sample following a symmetric triangular distribution with
/// non-zero support over the range `xMin ... xMax`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
List<double> triangularSample(
  int n,
  num xMin,
  num xMax, {
  int? seed,
}) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      message: 'Error in function '
          'triangularSample($n, $xMin, $xMax, seed: $seed)',
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'xMmin < xMax',
    );
  }

  double invCdf(num p, num min, num max) {
    final range = max - min;
    if (p < 0.5) {
      return min + range * sqrt(p / 2);
    } else {
      return max - range * sqrt((1.0 - p) / 2);
    }
  }

  final random = Random(seed);
  return List<double>.generate(
      n, (_) => invCdf(random.nextDouble(), xMin, xMax));
}
