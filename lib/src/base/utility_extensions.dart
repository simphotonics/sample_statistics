library utility_extensions;

import 'dart:math' as math;

import 'package:exception_templates/exception_templates.dart';

import '../exceptions/empty_iterable.dart';
import '../exceptions/invalid_function_parameter.dart';

import 'density_functions.dart';
import 'sample_stats.dart';

/// Extension on `num` providing the method
/// `root`.
extension Roots on num {
  /// Returns the n-th root of this as a `double`.
  /// * Usage: `final n = 32.root(5);`
  /// * Only supported for positive numbers.
  ///
  /// Important: The dot operator has higher precedence than the minus sign.
  ///
  /// Therefore: `-32.root(5) == -(32.root(5)) == -2`.
  ///
  /// Whereas:  `(-32).root(5)` throws an error of
  /// type `ErrorOfType<InvalidFunctionParameter`.
  double root(n) {
    if (isNegative) {
      throw ErrorOfType<InvalidFunctionParameter>(
        message: 'Can not calculate roots of negative numbers.',
        invalidState: '$this < 0',
      );
    }
    return math.exp(math.log(this) / n).toDouble();
  }
}

/// Extension on `Iterable<num>` providing the
/// getters: `min`, `max`, and `sum`.
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
  static final _cache = <int, int>{0: 1};

  /// Returns the factorial of this.
  int get factorial {
    if (this < 0) {
      throw ErrorOfType<InvalidFunctionParameter>(
        message: 'The getter factorial is not defined for negative numbers.',
        invalidState: '$this < 0.',
      );
    }
    if (this == 0) {
      return 1;
    } else {
      return _cache[this] ??= this * (this - 1).factorial;
    }
  }
}

/// Extension on `List<num>` providing the
/// method `removeOutliers`.
extension StatisticsUtils on List<num> {
  /// Removes and returns all list entries
  /// with a value satisfying the condition:
  ///
  /// `(value < q1 - factor * iqr) || (value > q3 + factor * iqr)`
  ///
  /// where `iqr = q3 - q1` is the inter-quartile range,
  /// `q1` is the first quartile,
  /// and `q3` is the third quartile.
  ///
  /// Note: The default value of `factor` is 1.5.
  List<num> removeOutliers([num factor = 1.5]) {
    final stats = SampleStats(this);
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

  /// Builds a histogram from the entries of `this`
  /// and writes the data records to a `String`.
  /// * If `normalize == true` the histogram count will be normalized such
  ///   that the total histogram area is equal to 1.0.
  /// * If `normalize == true`, the function `pdf` is evaluated for
  ///   each histogram interval and added as a third column.
  /// * The parameter `pdf` defaults to:
  ///   `(x) => normalPdf(x, sampleMean, sampleStdDev)`.
  String exportHistogram({
    bool normalize = true,
    int? intervals,
    ProbabilityDensity? pdf,
    verbose = false,
    String commentCharacter = '#',
    int precision = 20,
  }) {
    final b = StringBuffer();
    if (length < 2) {
      b.writeln('$commentCharacter Could not generate histogram. '
          'List is too short: $this');
      return b.toString();
    }
    final stats = SampleStats(this);

    final hist = stats.histogram(
      intervals: intervals,
      normalize: normalize,
      probabilityDensity: pdf,
    );

    // hist[0] = [min, min + intervalSize, ..., max].
    final intervalSize = hist[0][2] - hist[0][1];

    intervals ??= hist[0].length;

    b.writeln('$commentCharacter Intervals: $intervals');
    b.writeln('$commentCharacter Min: '
        '${stats.min.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter Max: '
        '${stats.max.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter Mean: '
        '${stats.mean.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter StdDev: '
        '${stats.stdDev.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter Median: '
        '${stats.median.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter First Quartile: '
        '${stats.quartile1.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter Third Quartile: '
        '${stats.quartile3.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter Interval size: '
        '${intervalSize.toStringAsPrecision(precision)}');
    b.writeln('$commentCharacter Integrated histogram: '
        '${hist[1].sum * intervalSize}');
    b.writeln('$commentCharacter');
    b.writeln('$commentCharacter ------------------------------------'
        '-------------------------');
    if (normalize) {
      b.write('$commentCharacter     Range     Prob. Density     '
          'Prob. Density Function\n');
    } else {
      b.write('$commentCharacter     Range     Count\n');
    }
    if (verbose) {
      print(b.toString());
    }
    for (var i = 0; i < hist[0].length; ++i) {
      b.writeln('${hist[0][i].toStringAsPrecision(precision)}     '
          '${hist[1][i].toStringAsPrecision(precision)}     '
          '${normalize ? hist[2][i].toStringAsPrecision(precision) : ''}');
    }
    return b.toString();
  }
}

/// Extension on `List<num>` providing the methods
/// `export` and `exportHistogram`.
extension Export on List<num> {
  /// Writes the entries of `this` to a `String`.
  /// - Values are separated by `delimiter`.
  /// - Each data record is written to a separate row.
  /// - If `range` is not specified the first column will contain
  ///  a data-record index.
  ///
  /// Usage:
  /// ```
  /// final dx = pi/100;
  /// final y = List<num>.generate(101, (i) => sin(pi + i*dx) );
  ///
  /// final lookupTable = y.export(
  ///   precision: 4,
  ///   range: [pi, 2*pi],
  ///   label: '// x  sin(x)',
  ///
  /// );
  /// ```
  /// The `String` tab has the following content:
  /// ```Console
  /// // x  sin(x)
  /// 3.142 1.225e-16
  /// 3.173 -0.03141
  /// 3.204 -0.06279
  /// ...
  /// 6.221 -0.03141
  /// 6.252 -2.449e-16
  /// ```
  String export({
    int precision = 20,
    List<num>? range = const [0, 1],
    String label = '#     x     y',
    String delimiter = ' ',
  }) {
    final b = StringBuffer();
    b.writeln(label);

    final x0 = (range == null)
        ? 0
        : (range.isEmpty)
            ? 0
            : range.first;
    final dx = (range == null)
        ? 1
        : (range.length < 2)
            ? 1
            : (range.last - range.first) / length;

    for (var i = 0; i < length; ++i) {
      b.writeln('${(x0 + i * dx).toStringAsPrecision(precision)}'
          '$delimiter${this[i].toStringAsPrecision(precision)}');
    }
    return b.toString();
  }
}
