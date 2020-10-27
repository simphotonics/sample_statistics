/// Provides the functions:
/// * `erf(x)`: error function,
/// * `integrate(x, func, lowerLimit, upperLimit)`.
/// ---
/// Includes the extensions:
/// * `Factorial on int`,
/// * `MinMaxSum on List<num>`,
/// * `Roots on <num>`,
/// * `StatisticsUtils on List<num>`: Adding methods for removing outliers,
///    exporting data, exporting histogram data.
library utility_functions;

import 'dart:io';
import 'dart:math' as math;

import 'package:exception_templates/exception_templates.dart';

import '../exceptions/empty_iterable.dart';
import 'density_functions.dart';
import 'sample_statistics.dart';

/// Square root of pi.
const sqrtPi = 1.77245385090551602729816748334;

/// Constant: 1.0/(sqrt(pi)).
const invSqrtPi = 1.0 / sqrtPi;

/// Square root of 2.0*pi.
const sqrt2Pi = math.sqrt2 * sqrtPi;

/// Constant: 1.0/(sqrt(2*pi)).
const invSqrt2Pi = 1.0 / sqrt2Pi;

/// Constant: 1.0/sqrt(2).
const invSqrt2 = 1.0 / math.sqrt2;

/// Error function table.
final erfTable = Map<double, double>.unmodifiable({
  0.0: 0.0,
  0.1: 0.1124629160182848922033,
  0.2: 0.2227025892104784541401,
  0.3: 0.3286267594591274276389,
  0.4: 0.4283923550466684551036,
  0.5: 0.5204998778130465376828,
  0.6: 0.6038560908479259225626,
  0.7: 0.6778011938374184729756,
  0.8: 0.7421009647076604861671,
  0.9: 0.7969082124228321285187,
  1.0: 0.8427007929497148693412,
  1.1: 0.8802050695740816997719,
  1.2: 0.9103139782296353802384,
  1.3: 0.9340079449406524366039,
  1.4: 0.9522851197626488105165,
  1.5: 0.96610514647531072706697,
  1.6: 0.9763483833446440077743,
  1.7: 0.9837904585907745636262,
  1.8: 0.9890905016357307141837,
  1.9: 0.9927904292352574699484,
  2.0: 0.9953222650189527341621,
  2.1: 0.9970205333436670144961,
  2.2: 0.9981371537020181085566,
  2.3: 0.9988568234026433485347,
  2.4: 0.9993114861033549214303,
  2.5: 0.9995930479825550410604,
  2.6: 0.9997639655834706507960,
  2.7: 0.9998656672600594756709,
  2.8: 0.9999249868053345409758,
  2.9: 0.9999589021219005411643,
  3.0: 0.9999779095030014145586,
  3.1: 0.99998835134263280040397,
});

/// Returns an approximation of the real valued error function defined as:
/// `erf(x) = 2/sqrt(pi) * integral(from_0, to_x, exp(-t*t), dt)`
/// * Note: `dxMax` is the maximum integration sub-interval used.
/// * The smaller `dxMax` the smaller the max. deviation:
///    - `dxMax = 0.1 => max. deviation: 8.0e-7`
///    - `dxMax = 0.05 => max. deviation: 2.0e-7`
///    - `dxMax = 0.01 => max. deviation: 8.0e-9`
///    - `dxMax = 0.001 => max deviation: 8.0e-11`
num erf(num x, {num dxMax = 0.1}) {
  if (x == 0) return 0.0;

  final positiveArg = (x > 0) ? true : false;

  // erf(-x) = erf(x) => Using only positive x-values.
  x = x.abs();

  // erf(8.0) = 0.999999999999999999999999999989 ( with 30-digit precision).
  if (x > 8) {
    return positiveArg ? 1.0 : -1.0;
  }

  // Find nearest extrapolation starting point.
  final x0 = (x > 3.0) ? 3.0 : (x * 10).floor() / 10;
  final x1 = (x > 3.0) ? 3.0 : (x * 10).ceil() / 10;

  final interval = (x - x0) < (x - x1).abs() ? x - x0 : x - x1;

  // Return early if no extrapolation is needed.
  if (interval == 0.0) return (positiveArg) ? erfTable[x0]! : -erfTable[x0]!;

  // Correct potential negative or large user input for argument dxMax:
  dxMax = dxMax.abs();
  dxMax = (dxMax > 0.1) ? 0.1 : dxMax;

  final n0 = (interval.abs() / dxMax).ceil();
  // To get a similar precision across the whole range of x.
  final nMin = (1 / (2 * dxMax)).ceil();
  final n = (n0 < nMin) ? nMin : n0;

  // Integration sub-interval:
  final dx = interval.abs() / n;

  // Function to be integrated (the factor 2/sqrt(pi) will be added later).
  num _erf(x) => math.exp(-x * x);

  final lowerLimit = (interval.isNegative) ? x : x0;

  var integral = (interval.isNegative)
      ? 0.5 * (_erf(x) + _erf(x1))
      : 0.5 * (_erf(x0) + _erf(x));

  for (var i = 1; i < n; ++i) {
    integral += _erf(lowerLimit + i * dx);
  }

  integral = integral * 2.0 * dx * invSqrtPi;

  // If the interval is positive we integrate from x0 to x and add erfTab(x0).
  // If the interval is negative we integrate from x to x1 and subtract
  //  the result from erf(x1).
  integral = (interval.isNegative)
      ? erfTable[x1]! - integral
      : erfTable[x0]! + integral;

  return (positiveArg) ? integral : -integral;
}

/// Returns the definite integral of `func` over the interval
/// (`lowerLimit`,`upperLimit`) using the
/// trapezoidal approximation.
///
/// Depending on the function the integral might
/// not be defined and convergence is not guaranteed for `dxMax -> 0`.
///
/// The maximum number of integration sub-intervals is `10000`.
num integrate(
  num Function(num x) func,
  num lowerLimit,
  num upperLimit, {
  double dxMax = 0.1,
}) {
  dxMax = dxMax.abs();
  final interval = upperLimit - lowerLimit;

  var n0 = (interval.abs() / dxMax).ceil();
  n0 = (n0 > 100000) ? 100000 : n0;
  final n = (n0 < 10) ? 10 : n0;

  // Integration sub-interval:
  final dx = interval / n;

  var integral = 0.5 * (func(lowerLimit) + func(upperLimit));
  for (var i = 1; i < n; ++i) {
    integral += func(lowerLimit + i * dx);
  }
  return integral * dx;
}

/// Returns the first derivative of the error function.
num dxErf(num x) => 2.0 * invSqrtPi * math.pow(math.e, -x * x);

extension Roots on num {
  /// Returns the n-th root of this.
  double root(n) {
    return math.exp(math.log(this) / n).toDouble();
  }
}

extension MinMaxSum on Iterable<num> {
  num get sum {
    if (isEmpty) {
      throw ExceptionOfType<EmptyIterable>(
          message: 'Summation not possible.',
          invalidState: 'The iterable is empty');
    }
    return fold<num>(0.0, (sum, current) => sum + current);
  }

  /// Returns the smallest entry.
  ///
  /// Throws an exception of type `ExceptionOf`
  num get min {
    if (isEmpty) {
      throw ExceptionOf<num>(
          message: 'Minimum value can not be determined.',
          invalidState: 'The iterable is empty');
    }
    return fold<num>(first, (math.min));
  }

  /// Return the largest entry.
  ///
  /// Throws an exception if the iterable is empty.
  num get max {
    if (isEmpty) {
      throw ExceptionOfType<EmptyIterable>(
          message: 'Maximum value can not be determined.',
          invalidState: 'The iterable is empty');
    }
    return fold<num>(first, (math.max));
  }
}

/// Adds the getter `factorial`.
extension Factorial on int {
  /// Returns the factorial of this.
  int get factorial {
    if (this < 0) throw 'Factorial is not defined for negative numbers.';
    return (this == 0) ? 1 : this * (this - 1).factorial;
  }
}

extension StatisticsUtils on List<num> {
  /// Removes and returns all list entries
  /// with a value satisfying the condition:
  ///
  /// `(value < q1 - factor * iqr) || (value > q3 + factor * iqr)`
  ///
  /// where `iqr = q3 - q1` is the inter-quartile range, `q1` is the first quartile,
  /// and `q3` is the third quartile.
  ///
  /// Note: The default value of `factor` is 1.5.
  List<num> removeOutliers([num factor = 1.5]) {
    final stats = SampleStatistics(this);
    factor = factor.abs();
    if (isEmpty) return <num>[];
    final iqr = stats.quartile3 - stats.quartile1;
    final result = <num>[];
    final lowerFence = stats.quartile1 - factor * iqr;
    final upperFence = stats.quartile3 + factor * iqr;

    removeWhere((current) {
      if (current < lowerFence || current > upperFence) {
        result.add(current);
        return true;
      } else {
        return false;
      }
    });
    return result;
  }

  /// Exports the entries of `this` to the file `filename`.
  /// - Each entry is written to a separate row.
  /// - Set `indexFirstColumn` to `true` to include an index.
  Future<File> export(
    String filename, {
    int precision = 4,
    bool indexFirstColumn = true,
    String label = '',
  }) {
    final file = File(filename);
    final b = StringBuffer();
    b.writeln(label);
    for (var i = 0; i < length; ++i) {
      b.writeln('$i       ${this[i].toStringAsPrecision(4)}');
    }
    return file.writeAsString(b.toString());
  }

  /// Builds a histogram and exports it to the file `filename`.
  /// * Set `normalize` to true to normalize the total column area.
  /// * The default number of histogram intervals (or bins)
  ///   is the cubic root of the sample size.
  Future<File> exportHistogram(
    String filename, {
    bool normalize = true,
    int? intervals,
    ProbabilityDensity? pdf,
  }) {
    final file = File(filename);
    final b = StringBuffer();
    if (length < 2) {
      b.writeln('# Could not generate histogram. List is too short: $this');
      return file.writeAsString(b.toString());
    }
    final stats = SampleStatistics(this);

    final hist = stats.histogram(
      intervals: intervals,
      normalize: normalize,
      probabilityDensity: pdf,
    );

    // hist[0] = [min, min + intervalSize, ..., max].
    final intervalSize = hist[0][2] - hist[0][1];

    intervals ??= hist[0].length;

    b.writeln('# Intervals: $intervals');
    b.writeln('# Min: ${stats.min}');
    b.writeln('# Max: ${stats.max}');
    b.writeln('# Mean: ${stats.mean}');
    b.writeln('# StdDev: ${stats.stdDev}');
    b.writeln('# Median: ${stats.median}');
    b.writeln('# First Quartile: ${stats.quartile1}');
    b.writeln('# Third Quartile: ${stats.quartile3}');
    b.writeln('# Interval size: $intervalSize');

    b.writeln('# Integrated histogram: '
        '${hist[1].sum * intervalSize}');
    b.writeln('#');
    b.writeln(
        '# -------------------------------------------------------------');
    if (normalize) {
      b.write(
          '#      Range            ProbabilityDensity            Truncated Normal\n');
    } else {
      b.write('#      Range            Count\n');
    }
    print(b.toString());
    for (var i = 0; i < hist[0].length; ++i) {
      b.writeln(
          '${hist[0][i]}      ${hist[1][i]}      ${normalize ? hist[2][i] : ''}');
    }
    return file.writeAsString(b.toString());
  }
}
