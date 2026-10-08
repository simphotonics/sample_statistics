import 'dart:math' as math;

import 'package:ansi_modifier/ansi_modifier.dart';
import 'package:list_operators/list_operators.dart' show NumericalMethods;

import '../statistics/probability_density.dart' show ProbabilityDensity;
import '../statistics/stats.dart';
import 'color_profile.dart';

extension ExportHistogram on Stats {
  /// Block characters used to build block histograms.
  static const monochromeBlocks = [
    '\u2581',
    '\u2582',
    '\u2583',
    '\u2584',
    '\u2585',
    '\u2586',
    '\u2587',
    '\u2588',
    '\u2589',
  ];

  static final colorBlocks = List.unmodifiableOf([
    '\u2581'.style(ColorProfile.dim),
    '\u2581',
    '\u2582',
    '\u2583',
    '\u2584',
    '\u2585',
    '\u2586',
    '\u2587',
    '\u2588',
    '\u2589',
  ]);

  /// Returns a block histogram in the form of a [String].
  /// * If the same block contains the [mean] and [median] it is styled using
  ///   [ColorProfile.meanMedianHistogramBlock].
  /// * To disable color output set:
  /// ```Dart
  /// AnsiModifier.colorOutput = ColoOutput.off;
  /// ```
  String _singleBlockHistogram() =>
      colorBlocks.first +
      colorBlocks.last.style(ColorProfile.meanMedianHistogramBlock) +
      colorBlocks.first;

  /// Returns a block histogram in the form of a [String].
  /// * The block containing the [mean] value is styled using
  ///   [ColorProfile.meanHistogramBlock].
  /// * The block containing the [median] is styled using
  ///   [ColorProfile.medianHistogramBlock].
  /// * The block containing the [mean] and [median] is styled using
  ///   [ColorProfile.meanMedianHistogramBlock].
  /// * If the sample range is high resulting in a large number of
  ///   histogram intervals only the first 20 and last 20 intervals
  ///   are displayed and the
  ///   number of skipped intervals is shown.
  /// * To disable color output set:
  ///   [Ansi.status] to [AnsiOutput.disabled].
  ///
  /// Usage:
  /// ```
  /// final stats = Stats(sample);
  /// print(stats.blockHistogram);
  /// ```
  /// Sample output (with color output disabled):
  ///
  /// ▉▂__________________ 177  ____________________
  String blockHistogram({int intervals = 0}) {
    final hist = histogram(intervals: intervals);

    /// Return early if the range of values is zero.
    if (hist[0].first == hist[0].last) {
      return _singleBlockHistogram();
    }

    final intervalSize = hist[0][1] - hist[0][0];
    final leftBorder = hist[0].first - intervalSize / 2;
    final counts = hist[1];
    final actualIntervals = counts.length;
    final countsMax = counts.max();

    // The number of available histogram blocks depends on Ansi.status.
    final blocks = switch (Ansi.status) {
      AnsiOutput.enabled => colorBlocks,
      AnsiOutput.disabled => monochromeBlocks,
    };
    final blockCount = blocks.length;
    final deltaCounts = countsMax / (blockCount - 1);

    // The empty histogram.
    final result = List<String>.filled(actualIntervals, ' ');

    // Assign a block string to each value.
    for (var i = 0; i < actualIntervals; i++) {
      final blockIndex = math.min((counts[i] / deltaCounts).ceil(), blockCount);
      result[i] = blocks[blockIndex];
    }

    final length = result.length;

    final indexOfMean = (mean - leftBorder) ~/ intervalSize;
    final indexOfMedian = (median - leftBorder) ~/ intervalSize;

    if (indexOfMedian == indexOfMean) {
      // Replace block if it will not be visible:
      result[indexOfMedian] = switch (result[indexOfMedian]) {
        String b when (b == blocks[0] || b == blocks[1]) => blocks[2],
        String b => b,
      };
      // Colorize block containing mean and median
      result[indexOfMedian] = result[indexOfMedian].style(
        ColorProfile.meanMedianHistogramBlock,
      );
    } else {
      result[indexOfMedian] = switch (result[indexOfMedian]) {
        String b when (b == blocks[0] || b == blocks[1]) => blocks[2],
        String b => b,
      };
      // Colorize block containing the median value.
      result[indexOfMedian] = result[indexOfMedian].style(
        ColorProfile.medianHistogramBlock,
      );
      result[indexOfMean] = switch (result[indexOfMean]) {
        String b when (b == blocks[0] || b == blocks[1]) => blocks[2],
        String b => b,
      };
      // Colorize block containing the mean value.
      result[indexOfMean] = result[indexOfMean].style(
        ColorProfile.meanHistogramBlock,
      );
    }

    /// Avoid situations where iqr = 0
    final iqrStandIn = iqr == 0.0 ? 20 * intervalSize : iqr;

    if (length > 40) {
      var indexLeft = (quartile1 - 3 * iqrStandIn - leftBorder) ~/ intervalSize;
      indexLeft = indexLeft < 0 ? 0 : indexLeft;

      var indexRight =
          (quartile3 + 5 * iqrStandIn - leftBorder) ~/ intervalSize;
      indexRight = indexRight > length - 1 ? length - 1 : indexRight;
      final rightBlocks = 5;
      final skippedRight = length - rightBlocks - indexRight;

      // Make histogram more compact
      return '${result.skip(indexLeft).take(indexRight - indexLeft).join()}  '
          '$skippedRight  '
          '${result.skip(length - rightBlocks).take(rightBlocks).join()}';
    } else {
      return result.join();
    }
  }

  /// Builds a histogram from the entries of `this`
  /// and writes the data entries to a [String].
  /// * If [normalize] is `true` the histogram count will be normalized such
  ///   that the total histogram area is equal to 1 .0.
  /// * [intervals]: The number of same-size intervals used to construct
  ///    the histogram.
  /// * [pdf]: The probability density function used to calculate the third
  ///    column.
  /// * [verbose]: Logical flag indicating if sample stats should be printed
  ///    as comments above the histogram data.
  /// * [commentCharacter]: The String character used to prefix comments.
  ///    It defaults to `#`, the comment character used by Gnuplot.
  /// * [precision]: The precision used when converting numbers to a [String].
  String exportHistogram({
    bool normalize = true,
    int intervals = 0,
    ProbabilityDensity? pdf,
    bool verbose = false,
    String commentCharacter = '#',
    int precision = 10,
  }) {
    final b = StringBuffer();
    if (sample.length < 2) {
      b.writeln(
        '$commentCharacter Could not generate histogram. '
        'The sample $sample is too short.',
      );
      return b.toString();
    }
    final paddingRight = precision + max.floor();

    final hist = histogram(
      intervals: intervals,
      normalize: normalize,
      probabilityDensity: pdf,
    );

    final bool hasPdf = pdf != null;

    // hist[0] = [min, min + intervalSize, ..., max].
    final intervalSize = hist[0][1] - hist[0][0];
    final actualIntervals = hist[0].length;

    if (verbose) {
      b.writeln('$commentCharacter Intervals: $actualIntervals');
      b.writeln(
        '$commentCharacter Min: '
        '${min.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Max: '
        '${max.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Interval size: '
        '${intervalSize.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Mean:   '
        '${mean.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter StdDev: '
        '${stdDev.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Median: '
        '${median.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter First Quartile: '
        '${quartile1.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Third Quartile: '
        '${quartile3.toStringAsPrecision(precision)}',
      );
      b.writeln(
        '$commentCharacter Histogram integral: '
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
        '$commentCharacter Interval Mid-Point           '
        '${normalize ? 'Probability Density' : 'Count'}     '
        'Prob. Density Function\n',
      );
      for (var i = 0; i < actualIntervals; ++i) {
        b.writeln(
          '       '
          '${hist[0][i].toStringAsPrecision(precision).padRight(paddingRight)}     '
          '${hist[1][i].toStringAsPrecision(precision)}     '
          '${hist[2][i].toStringAsPrecision(precision)}',
        );
      }
    } else {
      b.write(
        '$commentCharacter     Interval Mid-Point                  '
        '${normalize ? 'Probability Density' : 'Count'}\n',
      );
      for (var i = 0; i < actualIntervals; ++i) {
        b.writeln(
          '        '
          '${hist[0][i].toStringAsPrecision(precision).padRight(paddingRight)}     '
          '${hist[1][i].toStringAsPrecision(precision)}     ',
        );
      }
    }
    return b.toString();
  }
}
