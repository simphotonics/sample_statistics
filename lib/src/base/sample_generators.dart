/// Simple random sample generators based on inversion sampling
/// and rejection sampling.
library sample_generators;

import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:statistics/src/exceptions/invalid_function_parameter.dart';

import 'density_functions.dart';

/// Returns a random sample with **probability density**
/// `probabilityDensity`.
///
/// * `n`: sample size,
/// * `xMin`: lower limit of the sample values,
/// * `xMax`: upper limit of the sample values,
/// * `yMax`: maximum value of `probDistFunc`,
/// * `seed`: optional random generator seed.
List<num> samplePdf(
  int n,
  num min,
  num max,
  num probDistMax,
  ProbabilityDensity probabilityDensity, {
  int? seed,
}) {
  final result = <num>[];
  final random = Random(seed);

  final range = max - min;

  while (result.length < n) {
    final x = range * random.nextDouble() + min;
    final y = probDistMax * random.nextDouble();

    if (y < probabilityDensity(x)) {
      result.add(x);
    }
  }
  return result;
}

/// Returns a random sample of size `n` following a
/// **truncated normal distribution** with:
/// * `min`: minimum value,
/// * `max`: maximum value,
/// * `mean`,
/// * `stdDev`: standard deviation.
/// ---
/// * `seed`: random generator seed (optional).
List<num> truncatedNormalSample(
  int n,
  num min,
  num max,
  num mean,
  num stdDev, {
  int? seed,
}) =>
    samplePdf(
      n,
      min,
      max,
      truncatedNormalPdf(mean, min, max, mean, stdDev),
      (x) => truncatedNormalPdf(x, min, max, mean, stdDev),
    );

/// Returns a random sample of size `n` following a
/// **normal distribution** with parameters:
/// * `mean`,
/// * `stdDev`: standard deviation.
/// ---
/// The following parameters are optional:
/// * `min`: minimum value (defaults to `mean - 10 * stdDev`),
/// * `max`: maximum value (defaults to `mean + 10 * stdDev`),
/// * `seed`: random generator seed.
List<num> normalSample(int n, num mean, num stdDev,
    {num? min, num? max, int? seed}) {
  min ??= mean - 10 * stdDev;
  max ??= mean + 10 * stdDev;

  return samplePdf(n, min, max, normalPdf(mean, mean, stdDev),
      (x) => normalPdf(x, mean, stdDev));
}

/// Returns a random sample of size `n` following an
/// **exponential distribution**.
/// * `mean` must be larger than zero,
/// * `seed` is optional (seeds the random number generator)
/// * Generator uses inversion sampling.
List<num> exponentialSample(
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
  return List<num>.generate(n, (_) => -mean * log(1.0 - random.nextDouble()));
}

/// Returns a random sample following a uniform distribution with
/// non-zero support over the range `(min, max)`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max`.
List<num> uniformSample(int n, num min, num max, {int? seed}) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }

  final random = Random(seed);
  final range = max - min;
  return List<num>.generate(n, (_) => min + random.nextDouble() * range);
}

/// Returns a random sample following a symmetric triangular distribution with
/// non-zero support over the range `(min, max)`.
///
/// Throws an error of type `ErrorOfType<InvalidFunctionParameter>`
/// if `min >= max`.
List<num> triangularSample(int n, num min, num max, {int? seed}) {
  if (min >= max) {
    throw ErrorOfType<InvalidFunctionParameter>(
      invalidState: 'min: $min >= max: $max',
      expectedState: 'min < max',
    );
  }

  num invCDF(num p, num min, num max) {
    final range = max - min;
    if (p < 0.5) {
      return min + range * sqrt(p / 2);
    } else {
      return max - range * sqrt((1.0 - p) / 2);
    }
  }

  final random = Random(seed);
  return List<num>.generate(n, (_) => invCDF(random.nextDouble(), min, max));
}
