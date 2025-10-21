import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart';

import '../exceptions/invalid_function_parameter.dart';
import '../statistics/probability_density.dart';
import '../statistics/stats.dart';

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

extension StatisticsUtils<T extends num> on List<T> {
  /// Removes values smaller than
  /// [quartile1] - [iqr] * [factor] and
  /// larger than [quartile3] + [iqr] * [factor]
  /// and returns the removed entries.
  List<T> removeOutliers([num factor = 1.5]) {
    final stats = Stats(this);
    final outliers = <T>[];
    factor = factor.abs();
    final iqr = stats.quartile3 - stats.quartile1;
    final lowerFence = stats.quartile1 - factor * iqr;
    final upperFence = stats.quartile3 + factor * iqr;
    removeWhere((current) {
      if (current < lowerFence || current > upperFence) {
        outliers.add(current);
        return true;
      } else {
        return false;
      }
    });
    return outliers;
  }

  /// Builds a histogram from the entries of `this`
  /// and writes the data records to a `String`.
  /// * If `normalize == true` the histogram count will be normalized such
  ///   that the total histogram area is equal to 1 .0.
  /// * `intervals`: The number of same-size intervals used to construct
  ///    the histogram.
  /// * `pdf`: The probability density function used to calculate the third
  ///    column.
  /// * `verbose`: Logical flag indicating if sample stats should be printed
  ///    as comments above the histogram data.
  /// * `commentCharacter`: The String character used to prefix comments.
  ///    It defaults to `#` the comment character used by Gnuplot.
  /// * `precision` is used when converting numbers to a [String].
  String exportHistogram({
    bool normalize = true,
    int intervals = 0,
    ProbabilityDensity? pdf,
    verbose = false,
    String commentCharacter = '#',
    int precision = 20,
  }) {
    final b = StringBuffer();
    if (length < 2) {
      b.writeln(
        '$commentCharacter Could not generate histogram. '
        '$this is too short.',
      );
      return b.toString();
    }
    final stats = Stats(this);

    final hist = stats.histogram(
      intervals: intervals,
      normalize: normalize,
      probabilityDensity: pdf,
    );

    final bool hasPdf = pdf != null;

    // hist[0] = [min, min + intervalSize, ..., max].
    final intervalSize = hist[0][1] - hist[0][0];
    // Actual intervals used to build the histogram.
    final gridPoints = hist[0].length;
    final actualIntervals = gridPoints - 1;

    if (verbose) {
      b.writeln('$commentCharacter Intervals: $actualIntervals');
      b.writeln(
        '$commentCharacter Min: '
        '${stats.min.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Max: '
        '${stats.max.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Mean: '
        '${stats.mean.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter StdDev: '
        '${stats.stdDev.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Median: '
        '${stats.median.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter First Quartile: '
        '${stats.quartile1.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Third Quartile: '
        '${stats.quartile3.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Interval size: '
        '${intervalSize.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Integrated histogram: '
        '${hist[1].sum() * intervalSize}',
      );
      b.writeln(commentCharacter);
      b.writeln(
        '$commentCharacter ------------------------------------'
        '-------------------------',
      );
    }
    if (hasPdf) {
      b.write(
        '$commentCharacter     Range      Prob. Density     '
        'Prob. Density Function\n',
      );
    } else {
      b.write(
        '$commentCharacter     Range     Count    Prob. Density Func. \n',
      );
    }
    for (var i = 0; i < gridPoints; ++i) {
      b.writeln(
        '${hist[0][i].toStringAsPrecision(precision)}     '
        '${hist[1][i].toStringAsPrecision(precision)}     '
        '${hist[2][i].toStringAsPrecision(precision)}',
      );
    }
    return b.toString();
  }
}
