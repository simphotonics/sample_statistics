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
List<double> samplePdf(
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

/// Returns a random sample of size `n` following a
/// truncated normal distribution with:
/// * `xMin`: minimum value,
/// * `xMax`: maximum value,
/// * `mean`,
/// * `stdDev`: standard deviation.
/// ---
/// * `seed`: random generator seed (optional).
List<double> sampleTruncatedNormalPdf(
  int n,
  num xMin,
  num xMax,
  num mean,
  num stdDev, {
  int? seed,
}) =>
    samplePdf(
      n,
      xMin,
      xMax,
      truncatedNormalPdf(mean, xMin, xMax, mean, stdDev),
      (x) => truncatedNormalPdf(x, xMin, xMax, mean, stdDev),
      seed: seed,
    );

/// Returns a random sample of size `n` following a
/// normal distribution with parameters:
/// * `mean`,
/// * `stdDev`: standard deviation.
/// ---
/// The following parameters are optional:
/// * `xMin`: minimum value (defaults to `mean - 10 * stdDev`),
/// * `xMax`: maximum value (defaults to `mean + 10 * stdDev`),
/// * `seed`: random generator seed.
List<double> sampleNormalPdf(int n, num mean, num stdDev,
    {num? xMin, num? xMax, int? seed}) {
  xMin ??= mean - 10 * stdDev;
  xMax ??= mean + 10 * stdDev;

  return samplePdf(
    n,
    xMin,
    xMax,
    normalPdf(mean, mean, stdDev),
    (x) => normalPdf(x, mean, stdDev),
    seed: seed,
  );
}

/// Returns a random sample of size `n` following an
/// exponential distribution.
/// * `mean` must be larger than zero,
/// * `seed` is optional (seeds the random number generator)
/// * The generator uses inversion sampling.
List<double> sampleExponentialPdf(
  int n,
  num mean, {
  int? seed,
}) {
  if (mean <= 0) {
    throw ErrorOfType<InvalidFunctionParameter>(
        invalidState: 'mean: $mean <= 0',
        expectedState: 'mean > 0',
        message: 'Could not generate random exponential sample');
  }
  final random = Random(seed);
  return List<double>.generate(
      n, (_) => -mean * log(1.0 - random.nextDouble()));
}

/// Returns a random sample following a uniform distribution with
/// non-zero support over the range `(xMin, xMax)`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
List<double> sampleUniformPdf(
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
  final range = xMax - xMin;
  return List<double>.generate(n, (_) => xMin + random.nextDouble() * range);
}

/// Returns a random sample following a symmetric triangular distribution with
/// non-zero support over the range `(xMin, xMax)`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `xMin >= xMax`.
List<double> sampleTriangularPdf(
  int n,
  num xMin,
  num xMax, {
  int? seed,
}) {
  if (xMin >= xMax) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $xMin >= max: $xMax',
      expectedState: 'xMmin < xMax',
    );
  }

  double invCDF(num p, num min, num max) {
    final range = max - min;
    if (p < 0.5) {
      return min + range * sqrt(p / 2);
    } else {
      return max - range * sqrt((1.0 - p) / 2);
    }
  }

  final random = Random(seed);
  return List<double>.generate(
      n, (_) => invCDF(random.nextDouble(), xMin, xMax));
}
