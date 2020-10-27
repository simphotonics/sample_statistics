/// Simple random sample generators based on rejection sampling.
library sample_generators;

import 'dart:math';

import 'density_functions.dart';

/// Returns a random sample with **probability density**
/// `probabilityDensity`.
///
/// * `n`: sample size,
/// * `xMin`: lower limit of the sample values,
/// * `xMax`: upper limit of the sample values,
/// * `yMax`: maximum value of `probDistFunc`,
/// * `seed`: optional random generator seed.
List<num> generateSample(
  int n,
  num min,
  num max,
  num probDistMax,
  ProbabilityDensity probabilityDensity, {
  int? seed,
}) {
  final result = <num>[];
  final rnd = Random(seed);

  final range = max - min;

  while (result.length < n) {
    final x = range * rnd.nextDouble() + min;
    final y = probDistMax * rnd.nextDouble();

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
List<num> generateTruncatedNormalSample(
  int n,
  num min,
  num max,
  num mean,
  num stdDev, {
  int? seed,
}) =>
    generateSample(
      n,
      min,
      max,
      0,
      (x) => truncatedNormalPdf(
        x,
        min,
        max,
        mean,
        stdDev,
      ),
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
List<num> generateNormalSample(
  int n, {
  required num mean,
  required num stdDev,
  num? min,
  num? max,
  int? seed,
}) {
  min ??= mean - 10 * stdDev;
  max ??= mean + 10 * stdDev;

  return generateSample(
    n,
    min,
    max,
    normalPdf(mean, mean, stdDev),
    (x) => normalPdf(x, mean, stdDev),
  );
}

/// Returns a random sample of size `n` following a
/// **exponential distribution** with parameters:
/// * `mean`,
/// ---
/// The following parameters are optional:
/// * `min`: minimum value (defaults to `mean - 10 * stdDev`),
/// * `max`: maximum value (defaults to `mean + 10 * stdDev`),
/// * `seed`: random generator seed.
List<num> generateExponentialSample(
  int n, {
  required num mean,
  num min = 0.0,
  num? max,
  int? seed,
}) {
  max ??= mean + 10 * mean;
  return generateSample(
    n,
    min,
    max,
    1 / mean,
    (x) => 1 / mean * exp(-x / mean),
    seed: seed,
  );
}
