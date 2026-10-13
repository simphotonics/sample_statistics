import 'dart:math' as math;

import 'package:ansi_modifier/ansi_modifier.dart';
import 'package:list_operators/list_operators.dart' show NumericalMethods;

import '../statistics/probability_density.dart' show ProbabilityDensity;
import '../statistics/stats.dart';
import 'color_profile.dart';
import 'root.dart';

extension ExportHistogram on Stats {
  /// Block characters used to build block histograms.
  static const blocks = [
    '__',
    '\u2581\u2581',
    '\u2582\u2582',
    '\u2583\u2583',
    '\u2584\u2584',
    '\u2585\u2585',
    '\u2586\u2586',
    '\u2587\u2587',
    '\u2588\u2588',
    'b1',
    'b2',
    'b3',
    'b4',
    'b5',
    'b6',
    'b7',
    'b8',
  ];

  static const blank = '  ';

  static const rightArrow = '\u2198';
  static const leftArrow = '\u2199';
  static const tilde = '\u223c';
  static const dash = '\u2212';
  static const meanSymbol = '\u02C7';
  static const medianSymbol = '\u00b0';
  static const intervalSymbol = '\u2190\u2192';

  /// Returns the optimal number of histogram intervals. The interval size
  /// is estimated using the Freedman-Diaconis rule.
  int get intervals => math.max((max - min) ~/ intervalSize, 3);

  /// Returns the optimal interval size according to the Freedman-Diaconis rule
  /// taking into account the inter-quartile range and the sample size.
  double get intervalSize => 2.59 * (iqr) / (sortedSample.length.root(3));

  /// Returns an object of type `List<List<num>>` containing a sample histogram.
  ///
  /// * The first list contains the interval mid points. The first interval
  ///   has boundaries: `min - h/2 ... min + h/2`, the last has
  ///   boundaries: `max - h/2 ... max + h/2`, where `h` is the interval width.
  ///
  /// * The second list represents a count of how many sample values fall into
  ///   each interval. If [normalize] is `true`, the histogram count
  ///   will be normalized such that the total area of the
  ///   histogram bars is equal to one.
  ///   This is useful when comparing the histogram to a
  ///   probability distribution.
  ///
  /// * The third list is added if [probabilityDensity] is not `null`.
  ///   It contains the result of evaluating [probabilityDensity] at each point
  ///   `(min, min + h, ..., max)`.
  List<List<double>> histogram({
    bool normalize = true,
    int intervals = 0,
    ProbabilityDensity? probabilityDensity,
  }) {
    var actualIntervals = intervals <= 0 ? this.intervals : intervals;

    /// Make sure we have at least 3 intervals
    while (actualIntervals < 2) {
      intervals++;
    }

    // The left-most interval has boundaries: [min - intervalSize/2].
    final intervalSize = (max - min) / (actualIntervals - 1);

    final xValues = List<double>.generate(
      actualIntervals,
      (i) => min + i * intervalSize,
      growable: false,
    );

    final counts = List<double>.filled(actualIntervals, 0.0);
    final leftBorder = min - intervalSize / 2;

    // Generating histogram
    for (final current in sortedSample) {
      // Calculate interval index of current.
      final index = (current - leftBorder) ~/ intervalSize;
      ++counts[index];
    }

    if (normalize) {
      final factor = counts.sum() * intervalSize;
      for (var i = 0; i < actualIntervals; ++i) {
        counts[i] = counts[i] / factor;
      }
    }

    if (probabilityDensity == null) {
      return [xValues, counts];
    } else {
      final pdf = List<double>.generate(
        actualIntervals,
        (i) => probabilityDensity(min + i * intervalSize),
      );
      return [xValues, counts, pdf];
    }
  }

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
  ///   histogram intervals some interval are skipped and
  ///   the number of skipped intervals is shown.
  /// * To omit the line showing the minimum and maximum sample value
  ///   set [showInfo] to false.
  /// * To disable color output set:
  ///   [Ansi.status] to [AnsiOutput.disabled].
  /// ```
  /// // Usage
  /// final stats = Stats(sample);
  /// print(stats.blockHistogram);
  /// ```
  /// Sample output (with color output disabled):
  ///▁▁________________▁▁__▁▁____▁▁▁▁▂▂▄▄██▄▄▃▃▂▂▂▂▁▁__26________▁▁
  ///-20                                 ←→ 1.091                40
  String blockHistogram({int intervals = 0, bool showInfo = true}) {
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
    final graphLower = List<String>.filled(actualIntervals, '');

    // Assign a block string to each value.
    for (var i = 0; i < actualIntervals; i++) {
      final blockIndex = math.min((counts[i] / deltaCounts).ceil(), blockCount);
      graphLower[i] = blocks[blockIndex];
    }

    final graphUpper = <String>[];

    /// The number of histogram blocks.
    final length = graphLower.length;

    final graphInfo = List.filled(length, '  ');

    // Convert placeholders to block characters
    for (var i = 0; i < length; i++) {
      graphUpper.add(switch (graphLower[i]) {
        'b0' => blocks[0],
        'b1' => blocks[1],
        'b2' => blocks[2],
        'b3' => blocks[3],
        'b4' => blocks[4],
        'b5' => blocks[5],
        'b6' => blocks[6],
        'b7' => blocks[7],
        'b8' => blocks[8],
        _ => '  ',
      });

      graphLower[i] = switch (graphLower[i]) {
        'b0' => blocks[8],
        'b1' => blocks[8],
        'b2' => blocks[8],
        'b3' => blocks[8],
        'b4' => blocks[8],
        'b5' => blocks[8],
        'b6' => blocks[8],
        'b7' => blocks[8],
        'b8' => blocks[8],
        String x => x,
      };
    }

    final indexOfMean = (mean - leftBorder) ~/ intervalSize;
    final indexOfMedian = (median - leftBorder) ~/ intervalSize;

    // Write the interval symbol <->.
    graphInfo[indexOfMedian] = intervalSymbol;

    if (indexOfMedian == indexOfMean) {
      // Colorize block containing the median and mean value.
      graphLower[indexOfMedian] = graphLower[indexOfMedian].style(
        ColorProfile.meanMedianHistogramBlock,
      );
      graphUpper[indexOfMedian] = graphUpper[indexOfMedian].style(
        ColorProfile.meanMedianHistogramBlock,
      );
    } else {
      // Colorize block containing the median value.
      graphLower[indexOfMedian] = graphLower[indexOfMedian].style(
        ColorProfile.medianHistogramBlock,
        editMethod: EditMethod.clearExisting,
      );
      graphUpper[indexOfMedian] = graphUpper[indexOfMedian].style(
        ColorProfile.medianHistogramBlock,
        editMethod: EditMethod.clearExisting,
      );
      // Colorize block containing the mean value.
      graphLower[indexOfMean] = graphLower[indexOfMean].style(
        ColorProfile.meanHistogramBlock,
        editMethod: EditMethod.clearExisting,
      );

      graphUpper[indexOfMean] = graphUpper[indexOfMean].style(
        ColorProfile.meanHistogramBlock,
        editMethod: EditMethod.clearExisting,
      );
    }

    /// Avoid situations where iqr = 0
    final iqrAsIndex = (iqr == 0.0) ? 10 : iqr ~/ intervalSize;

    // Make sure to keep the median.
    var indexLeft = indexOfMedian - 2 * iqrAsIndex;
    indexLeft = indexLeft < 0 ? 0 : indexLeft;

    while (graphLower[indexLeft] != blocks[0] && indexLeft > 0) {
      indexLeft--;
    }

    final indexMax = length - 1;
    var indexRight = math.min(indexOfMedian + 2 * iqrAsIndex, indexMax);

    while (graphLower[indexRight] != blocks[0] && indexRight < indexMax) {
      indexRight++;
    }

    if (indexRight < indexMax) {
      indexRight++;
    }

    var skippedLeft = 0;

    final b1 = StringBuffer();
    final b2 = StringBuffer();
    final b3 = StringBuffer();

    final minInfo = ((min is int)
        ? min.toString()
        : min.toStringAsPrecision(4));
    final maxInfo = ((max is int)
        ? max.toString()
        : max.toStringAsPrecision(4));
    final intervalInfo = intervalSize.toStringAsPrecision(4);

    // Compose histogram
    if (indexLeft > 25) {
      // Add 5 intervals on the left.
      b1.write(graphUpper.take(5).join());
      b2.write(graphLower.take(5).join());
      b3.write(graphInfo.take(5).join());
      // Add the number of skipped intervals.
      skippedLeft = indexLeft - 5;
      b1.write(' ' * skippedLeft.toString().length);
      b2.write(skippedLeft);
      b3.write(' ' * skippedLeft.toString().length);
      // Add the histogram
      b1.write(graphUpper.skip(indexLeft).take(indexRight - indexLeft).join());
      b2.write(graphLower.skip(indexLeft).take(indexRight - indexLeft).join());
      b3.write(graphInfo.skip(indexLeft).take(indexRight - indexLeft).join());
    } else {
      // Add the histogram
      b1.write(graphUpper.take(indexRight).join());
      b2.write(graphLower.take(indexRight).join());
      b3.write(graphInfo.take(indexRight).join());
    }

    if ((length - indexRight) > 25) {
      // Add the number of skipped intervals.
      b1.write(' ' * (length - indexRight - 5).toString().length);
      b2.write(length - indexRight - 5);
      b3.write(' ' * (length - indexRight - 5).toString().length);
      // Add 5 intervals on the right.
      b1.write(graphUpper.skip(length - 5).take(5).join());
      b2.write(graphLower.skip(length - 5).take(5).join());
      b3.write(graphInfo.skip(length - 5).take(5).join());
    } else {
      // Add remaining characters.
      b1.write(graphUpper.skip(indexRight).join());
      b2.write(graphLower.skip(indexRight).join());
      b3.write(graphInfo.skip(indexRight).join());
    }
    final info = b3.toString();
    final i = info.indexOf(intervalSymbol);

    if (minInfo.length < i &&
        i + 3 < info.length &&
        i + 3 + intervalInfo.length < info.length - maxInfo.length) {
      return b1.toString() +
          '\n' +
          b2.toString() +
          '\n' +
          minInfo +
          info.substring(minInfo.length, i + 3) +
          intervalInfo +
          info.substring(
            i + 3 + intervalInfo.length,
            info.length - maxInfo.length,
          ) +
          maxInfo;
    } else {
      return b1.toString() + '\n' + b2.toString();
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
    final paddingRight = precision + max.floor().toString().length;

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
