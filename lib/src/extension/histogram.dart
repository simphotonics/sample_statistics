import 'dart:math' as math;

import 'package:ansi_modifier/ansi_modifier.dart';
import 'package:list_operators/list_operators.dart' show NumericalMethods;

import '../enum/histogram_info.dart';
import '../enum/histogram_layout.dart';
import '../statistics/probability_density.dart' show ProbabilityDensity;
import '../statistics/stats.dart';
import 'color_profile.dart';
import 'precision.dart';
import 'root.dart';

/// A custom function converting a [num] to a [String].
typedef NumToString = String Function(num argument);

/// Returns a [String] representing an approximation of [argument]
/// with 2 non zero digits.
///
/// Calls the extension method [Precision.toStringAsFixedDigits].
String numToString(num argument) =>
    (argument is int) ? argument.toString() : argument.toStringAsFixedDigits(2);

extension Histogram on Stats {
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

  /// The blocks printed in sequential order from shortest to tallest.
  static final blockLadder =
      blankBlock * 9 +
      blocks.skip(1).take(8).join() +
      '\n' +
      blocks.take(9).join() +
      blocks[8] * 8;

  /// Blank spaces matching the width of a histogram block.
  static const blankBlock = '  ';

  /// The block size in character widths.
  static const blockSize = 2;

  /// The symbol used to label the histogram interval size. If geometrically
  /// possible, it is placed under the block containing the sample [median].
  static const intervalSymbol = '\u2190\u2192';

  /// Returns the optimal number of histogram intervals. The interval size
  /// is estimated using the Freedman-Diaconis rule.
  ///
  /// Returns a minimum interval number of 1. A degenerate histogram where the
  /// sample min and max coincide will have only one interval.
  int get intervals =>
      (intervalSize == 0) ? 1 : (max - min) ~/ intervalSize + 1;

  /// Returns the optimal interval size according to the Freedman-Diaconis rule
  /// taking into account the inter-quartile range and the sample size.
  ///
  /// Note: A sample where [min] and [max] coincide will have [iqr] zero,
  /// resulting in an interval size of zero.
  double get intervalSize {
    return 2.0 * iqr / (sortedSample.length.root(3));
  }

  /// Returns data representing a sample histogram.
  ///
  /// * The first list represents the interval mid points. The first interval
  ///   has boundaries: `min - h/2 ... min + h/2`, the last has
  ///   boundaries: `max - h/2 ... max + h/2`, where `h` is the interval width.
  ///
  /// * The second list represents a count of how many sample values fall into
  ///   each interval. If [normalize] is `true`, the histogram count
  ///   will be normalized such that the total area under the
  ///   histogram bars is equal to one.
  ///   This is useful when comparing the histogram to a
  ///   probability distribution.
  ///
  /// * The third list is added if [probabilityDensity] is not `null`.
  ///   It contains the result of evaluating [probabilityDensity] at each point
  ///   `(min, min + h, ..., max)`.
  ///
  /// * If [intervals] is zero, then the number of histogram intervals will be
  /// calculated using the Freedman-Diaconis rule.
  ///
  /// * Use [minIntervals] to force a minimun number of intervals.
  List<List<double>> histogram({
    bool normalize = true,
    int intervals = 0,
    int minIntervals = 0,
    ProbabilityDensity? probabilityDensity,
  }) {
    var actualIntervals = intervals <= 0 ? this.intervals : intervals;

    if (actualIntervals < minIntervals) {
      actualIntervals = minIntervals;
    }

    // The left-most interval has boundaries: [min - intervalSize/2].
    final intervalSize = (max == min)
        ? 0.0
        : (max - min) / (actualIntervals - 1);

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
      final index = (intervalSize > 0)
          ? (current - leftBorder) ~/ intervalSize
          : 0;
      ++counts[index];
    }

    if (normalize && intervalSize > 0) {
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
  /// * The same block contains the [mean] and [median] therefore
  ///   it is styled using [ColorProfile.meanMedianHistogramBlock].
  /// * To disable color output set:
  /// ```Dart
  /// AnsiModifier.colorOutput = ColoOutput.off;
  /// ```
  String _singleBlockHistogram({
    HistogramInfoOption infoOption = HistogramInfoOption.showNone,
    String indent = '',
    NumToString numToString = numToString,
  }) {
    return indent +
        blankBlock * 3 +
        blocks[8].style(ColorProfile.meanMedianHistogramBlock) +
        '\n' +
        indent +
        blocks.first * 3 +
        blocks[8].style(ColorProfile.meanMedianHistogramBlock) +
        blocks.first * 3 +
        (infoOption.isShowNone
            ? ''
            : '\n' + indent + 'min, max: ${numToString(min)}');
  }

  /// Returns a block histogram in the form of a [String].
  ///
  /// * If [intervals] is 0, it will be calculated using the
  ///   Freedman-Diaconis rule.
  /// * [minIntervals]: The minimum number of histogram intervals.
  /// * The parameter [infoOption] can be used to customize the bottom line
  ///   of the histogram.
  /// * [scalingFactor]: [min], [max], and [mean] are divided by this factor.
  ///  ---
  /// * The block containing the [mean] value is styled using
  ///   [ColorProfile.meanHistogramBlock].
  /// * The block containing the [median] is styled using
  ///   [ColorProfile.medianHistogramBlock].
  /// * The block containing the [mean] and [median] is styled using
  ///   [ColorProfile.meanMedianHistogramBlock].
  /// * If the sample range is high resulting in a large number of
  ///   histogram intervals some interval are skipped and
  ///   the number of skipped intervals is shown.
  /// * To disable color output set:
  ///   [Ansi.status] to [AnsiOutput.disabled].
  /// ```
  /// // Usage
  /// final stats = Stats(sample);
  /// print(stats.blockHistogram);
  /// // prints:
  /// //      ██▅▅
  /// // ▂▂▂▂██████▆▆▂▂▂▂▂▂
  /// // -10   ←→ 3.000  14
  /// ```
  String blockHistogram({
    int intervals = 0,
    int minIntervals = 0,
    String indent = '',
    HistogramInfoOption infoOption = HistogramInfoOption.showAll,
    HistogramLayout layout = HistogramLayout.standard,
    num scalingFactor = 1,
    NumToString numToString = numToString,
  }) {
    final hist = histogram(intervals: intervals, minIntervals: minIntervals);

    /// Return early if the range of values is zero.
    if (hist[0].first == hist[0].last) {
      return _singleBlockHistogram(
        infoOption: infoOption,
        indent: indent,
        numToString: numToString,
      );
    }

    final intervalSize = hist[0][1] - hist[0][0];
    final leftBorder = hist[0].first - intervalSize / 2;
    final counts = hist[1];
    final actualIntervals = counts.length;
    final countsMax = counts.max();

    final blockIndexMax = blocks.length - 1;
    final deltaCounts = countsMax / (blockIndexMax);

    // The empty histogram.
    final graphLower = List<String>.filled(actualIntervals, '');

    // Assign a block string to each sample value.
    for (var i = 0; i < actualIntervals; i++) {
      final blockIndex = math.min(
        (counts[i] / deltaCounts).round(),
        blockIndexMax,
      );
      graphLower[i] = blocks[blockIndex];
    }

    final graphUpper = <String>[];

    /// The number of histogram blocks.
    final length = graphLower.length;

    final graphInfo = List.filled(length, '  ');

    // Convert placeholders to block characters
    for (var i = 0; i < length; i++) {
      graphUpper.add(switch (graphLower[i]) {
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

    String shorten(List<String> input, {bool addSkipped = true}) {
      /// Avoid situations where iqr = 0
      final iqrAsIndex = (iqr == 0.0) ? 10 : iqr ~/ intervalSize;

      // Make sure to include the median.
      var indexLeft = indexOfMedian - 2 * iqrAsIndex;
      indexLeft = indexLeft < 0 ? 0 : indexLeft;

      final stepsMax = 5 * iqrAsIndex;
      int steps = 0;
      while (graphLower[indexLeft] != blocks[0] &&
          indexLeft > 0 &&
          steps < stepsMax) {
        indexLeft--;
        steps++;
      }

      final indexMax = length - 1;
      var indexRight = math.min(indexOfMedian + 2 * iqrAsIndex, indexMax);

      steps = 0;
      while (graphLower[indexRight] != blocks[0] &&
          indexRight < indexMax &&
          steps < stepsMax) {
        indexRight++;
        steps++;
      }

      if (indexRight < indexMax) {
        // If possible shift indexRight to show one interval using blocks[0]
        // before the number of skipped intervals is printed.
        indexRight++;
      }
      final b = StringBuffer();
      if (indexLeft > layout.maxTailWidth) {
        b.write(input.take(5).join());
        final skipped = indexLeft - 5;
        if (addSkipped) {
          // Add the number of skipped intervals
          b.write(skipped);
        } else {
          // Add space characters instead of the number of skipped intervals
          b.write(' ' * skipped.toString().length);
        }
        // Add the relevant part of the histogram
        b.write(input.skip(indexLeft).take(indexRight - indexLeft).join());
      } else {
        b.write(input.take(indexRight).join());
      }

      if (length - indexRight > 15) {
        final skipped = length - indexRight - 5;
        if (addSkipped) {
          // Add the number of skipped intervals
          b.write(skipped);
        } else {
          // Add space characters instead of number
          b.write(' ' * skipped.toString().length);
        }
        // Add the last 5 intervals
        b.write(input.skip(length - 5).take(5).join());
      } else {
        b.write(input.skip(indexRight).join());
      }

      return b.toString();
    }

    /// Composes the info line of the histogram (containing
    /// the sample min, max, and the interval size).
    String infoLine() {
      late final minInfo = (min is int && scalingFactor == 1)
          ? min.toString()
          : numToString(min / scalingFactor);
      late final maxInfo = (max is int && scalingFactor == 1)
          ? max.toString()
          : numToString(max / scalingFactor);
      late final intervalInfo = numToString(intervalSize / scalingFactor);
      late final info = shorten(graphInfo, addSkipped: false);
      late final i = info.indexOf(intervalSymbol);
      late final styledIntervalSymbol = (indexOfMedian == indexOfMean)
          ? intervalSymbol.style(ColorProfile.meanMedianHistogramBlock)
          : intervalSymbol.style(ColorProfile.medianHistogramBlock);
      late final styledIntervalInfo = (indexOfMedian == indexOfMean)
          ? intervalInfo.style(ColorProfile.meanMedianHistogramBlock)
          : intervalInfo.style(ColorProfile.medianHistogramBlock);

      switch (infoOption) {
        case HistogramInfoOption.showNone:
          return '';
        case HistogramInfoOption.showMinMax:
          if (minInfo.length + 2 <= i &&
              info.length - (i + intervalSymbol.length + 2) < maxInfo.length) {
            return '\n' +
                indent +
                minInfo +
                info.substring(minInfo.length, info.length - maxInfo.length) +
                maxInfo;
          } else {
            return '\n' + indent + 'min: $minInfo, max: $maxInfo';
          }
        case HistogramInfoOption.showMedian:
          final part0 = (minInfo.length + 1 <= i)
              ? minInfo +
                    info.substring(minInfo.length, i) +
                    styledIntervalSymbol
              : info.substring(0, i) + styledIntervalSymbol;
          var part1 = '';
          if (info.length >= i + 3 + intervalInfo.length + 2 + maxInfo.length) {
            part1 =
                ' ' +
                styledIntervalInfo +
                info.substring(
                  i + 3 + intervalInfo.length,
                  info.length - maxInfo.length,
                ) +
                maxInfo;
          } else if (info.length >= i + 4 + maxInfo.length) {
            part1 =
                '  ' +
                info.substring(i + 4, info.length - maxInfo.length) +
                maxInfo;
          }
          return '\n' + indent + part0 + part1;

        case HistogramInfoOption.showAll:
          if (minInfo.length + 2 <= i &&
              info.length - i >=
                  intervalSymbol.length +
                      1 +
                      intervalInfo.length +
                      2 +
                      maxInfo.length) {
            return '\n' +
                indent +
                minInfo +
                info.substring(minInfo.length, i) +
                styledIntervalSymbol +
                ' ' +
                styledIntervalInfo +
                info.substring(
                  i + 3 + intervalInfo.length,
                  info.length - maxInfo.length,
                ) +
                maxInfo;
          } else {
            return '\n' +
                indent +
                'min: $minInfo, interval: $intervalInfo, max: $maxInfo';
          }
      }
    }

    return indent +
        shorten(graphUpper, addSkipped: false) +
        '\n' +
        indent +
        shorten(graphLower) +
        (infoOption.isShowNone ? '' : infoLine());
  }

  /// Builds a histogram from the entries of `this`
  /// and writes the data entries to a [String].
  /// * If [normalize] is `true` the histogram count will be normalized such
  ///   that the t +otal histogram area is equal to 1 .0.
  /// * [intervals]: The number of same-size intervals used to construct
  ///    the histogram.
  /// * [pdf]: The probability density function used to calculate the third
  ///    column.
  /// * [includeStats]: Logical flag indicating if sample stats should be
  ///    printed as header above the histogram data.
  /// * [commentCharacter]: The String character used to prefix comments.
  ///    It defaults to `#`, the comment character used by Gnuplot.
  /// * [precision]: The precision used when converting numbers to a [String].
  String exportHistogram({
    bool normalize = true,
    int intervals = 0,
    ProbabilityDensity? pdf,
    bool includeStats = false,
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
    final actualIntervals = hist[0].length;
    final intervalSize = actualIntervals < 2 ? 0 : hist[0][1] - hist[0][0];

    if (includeStats) {
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
