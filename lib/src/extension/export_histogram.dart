import 'dart:math' as math;

import 'package:ansi_modifier/ansi_modifier.dart';
import 'package:list_operators/list_operators.dart' show NumericalMethods;

import '../statistics/probability_density.dart' show ProbabilityDensity;
import '../statistics/stats.dart';
import 'color_profile.dart';

extension ExportHistogram on Stats {
  /// Block characters used to build block histograms.
  static const blocks = [
    '_',
    '\u2581',
    '\u2582',
    '\u2583',
    '\u2584',
    '\u2585',
    '\u2586',
    '\u2587',
    '\u2588',
  ];

  static const rightArrow = '\u2198';
  static const leftArrow = '\u2199';
  static const meanSymbol = '\u0078\u0304';
  static const medianSymbol = '\u0078\u0303';
  static const gap = ' ';
  // static const tilde = '\u223c';
  // static const dashTilde = '\u2242';
  // static const dash = '\u2212';

  /// Returns a block histogram in the form of a [String].
  /// * If the same block contains the [mean] and [median] it is styled using
  ///   [ColorProfile.meanMedianHistogramBlock].
  /// * To disable color output set:
  /// ```Dart
  /// AnsiModifier.colorOutput = ColoOutput.off;
  /// ```
  String _singleBlockHistogram() =>
      blocks.first +
      blocks.last.style(ColorProfile.meanMedianHistogramBlock) +
      blocks.first;

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

    String firstLine = '';

    if (indexOfMedian == indexOfMean) {
      // Colorize block containing the median and mean value.
      result[indexOfMedian] = result[indexOfMedian].style(
        ColorProfile.meanMedianHistogramBlock,
      );
      firstLine =
          ' ' * (indexOfMedian - 2) +
          medianSymbol.style(ColorProfile.median) +
          rightArrow +
          ' ' +
          leftArrow +
          meanSymbol.style(ColorProfile.mean);
    } else {
      // Colorize block containing the median value.
      result[indexOfMedian] = result[indexOfMedian].style(
        ColorProfile.medianHistogramBlock,
        editMethod: EditMethod.clearExisting,
      );
      // Colorize block containing the mean value.
      result[indexOfMean] = result[indexOfMean].style(
        ColorProfile.meanHistogramBlock,
        editMethod: EditMethod.clearExisting,
      );

      if (indexOfMean < indexOfMedian) {
        firstLine =
            ' ' * (indexOfMean) +
            meanSymbol.style(ColorProfile.mean) +
            ' ' * (indexOfMedian - indexOfMean - 1) +
            medianSymbol.style(ColorProfile.median);
      } else {
        firstLine =
            ' ' * (indexOfMedian) +
            medianSymbol.style(ColorProfile.median) +
            ' ' * (indexOfMean - indexOfMedian - 1) +
            meanSymbol.style(ColorProfile.mean);
        // Add median first
      }
    }

    /// Avoid situations where iqr = 0
    final iqrAsIndex = (iqr == 0.0) ? 10 : iqr ~/ intervalSize;
    final leftAnchor = (indexOfMean < indexOfMedian)
        ? indexOfMean
        : indexOfMedian;
    final rightAnchor = (indexOfMean < indexOfMedian)
        ? indexOfMedian
        : indexOfMean;

    // Make sure to keep the mean.
    var indexLeft = leftAnchor - 4 * iqrAsIndex;
    indexLeft = indexLeft < 0 ? 0 : indexLeft;

    // Make sure to keep the median.
    var indexRight = rightAnchor + 4 * iqrAsIndex;

    var skippedLeft = 0;

    // Compose histogram
    final b = StringBuffer();
    if (indexLeft > 40) {
      // Add 5 intervals on the left.
      b.write(result.take(5).join(gap));
      // Add the number of skipped intervals.
      skippedLeft = indexLeft - 5;
      b.write(skippedLeft);
      // Add the histogram
      b.write(result.skip(indexLeft).take(indexRight - indexLeft).join(gap));
    } else {
      // Add the histogram
      b.write(result.take(indexRight).join());
    }

    if ((length - indexRight) > 40) {
      // Add the number of skipped intervals.
      b.write(length - indexRight - 5);
      // Add 5 intervals on the right.
      b.write(result.skip(length - 5).take(5).join(gap));
    } else {
      // Add remaining characters.
      b.write(result.skip(indexRight).join('a'));
    }
    // Add first line
    return switch (skippedLeft) {
      0 => firstLine + '\n' + b.toString(),
      _ =>
        // Account for integer representing the skipped intervals.
        firstLine.substring(skippedLeft - skippedLeft.toString().length) +
            '\n' +
            b.toString(),
    };
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
