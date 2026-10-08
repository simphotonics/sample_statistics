import 'dart:collection';
import 'dart:math' as math show max;

import 'package:lazy_memo/lazy_memo.dart';
import 'package:list_operators/list_operators.dart';

import '../extension/root.dart' show Root;
import 'probability_density.dart' show ProbabilityDensity;

/// Provides access to basic statistical entities of a
/// numerical sample.
class Stats<T extends num>(List<T> sample) {
  /// A copy of the original numerical data sample. Must not be empty.
  final List<T> _sample = List.of(sample);

  /// Sorted sample stored as a lazy variable.
  late final sortedSample = LazyList<T>(() => List.of(_sample)..sort());

  /// Sample mean.
  late final _mean = Lazy(() => _sample.mean());

  /// Corrected sample standard deviation.
  late final _stdDev = Lazy(() => _sample.stdDev());

  late final _quartile1 = Lazy<num>(() {
    final length = sample.length;
    final halfLength = length.isEven ? length ~/ 2 : (length - 1) ~/ 2;

    if (halfLength.isEven) {
      final quaterIndex = halfLength ~/ 2;
      return (sortedSample[quaterIndex - 1] + sortedSample[quaterIndex]) / 2;
    } else {
      final quaterIndex = (halfLength - 1) ~/ 2;
      return sortedSample[quaterIndex];
    }
  });

  late final _median = Lazy<num>(() {
    final length = sample.length;
    if (length.isEven) {
      final midIndex = length ~/ 2;
      return (sortedSample[midIndex - 1] + sortedSample[midIndex]) / 2;
    } else {
      final midIndex = (length - 1) ~/ 2;
      return sortedSample[midIndex];
    }
  });

  late final _quartile3 = Lazy<num>(() {
    final length = sample.length;
    final halfLength = length.isEven ? length ~/ 2 : (length - 1) ~/ 2;

    if (halfLength.isEven) {
      final threeQuaterIndex = length - halfLength ~/ 2;

      return (sortedSample[threeQuaterIndex - 1] +
              sortedSample[threeQuaterIndex]) /
          2;
    } else {
      final threeQuaterIndex = length - (halfLength) ~/ 2 - 1;
      return sortedSample[threeQuaterIndex];
    }
  });

  /// Returns the optimal number of histogram intervals. The interval size
  /// is estimated using the Freedman-Diaconis rule.
  int get intervals => math.max((max - min) ~/ intervalSize, 3);

  /// Returns the optimal interval size according to the Freedman-Diaconis rule
  /// taking into account the inter-quartile range and the sample size.
  double get intervalSize => 2 * (iqr) / (sortedSample.length.root(3));

  /// Returns the inter quartile range.
  num get iqr => quartile3 - quartile1;

  /// Return the largest sample value.
  T get max => sortedSample.last;

  /// Returns the sample mean.
  double get mean => _mean();

  /// Returns the sample median (second quartile).
  num get median => _median();

  /// Returns the smallest sample value.
  T get min => sortedSample.first;

  /// Returns the first quartile.
  num get quartile1 => _quartile1();

  /// Returns the third quartile.
  num get quartile3 => _quartile3();

  /// Returns an [UnmodifiableListView] of [sample].
  List<T> get sample => UnmodifiableListView(_sample);

  /// Returns the corrected sample standard deviation.
  ///
  /// * The sample must contain at least 2 entries.
  /// * The normalization constant for the corrected standard deviation is
  ///   `sample.length - 1`.
  double get stdDev => _stdDev();

  /// Adds the entries in [data] to [sample] and calls [invalidateCache] to
  /// recalculate cached statistics.
  void addDataPoints(List<T> data) {
    _sample.addAll(data);
    invalidateCache();
  }

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
    intervals = intervals < 2 ? this.intervals : intervals;

    /// Make sure we have at least 3 intervals
    while (intervals < 2) {
      intervals++;
    }

    final intervalSize = (max - min) / (intervals - 1);

    final xValues = List<double>.generate(
      intervals,
      (i) => min + i * intervalSize,
      growable: false,
    );

    final counts = List<double>.filled(intervals, 0.0);
    final leftBorder = min - intervalSize / 2;

    // Generating histogram
    for (final current in sortedSample) {
      // Calculate interval index of current.
      final index = (current - leftBorder) ~/ intervalSize;
      ++counts[index];
    }

    if (normalize) {
      final factor = counts.sum() * intervalSize;
      for (var i = 0; i < intervals; ++i) {
        counts[i] = counts[i] / factor;
      }
    }

    if (probabilityDensity == null) {
      return [xValues, counts];
    } else {
      final pdf = List<double>.generate(
        intervals,
        (i) => probabilityDensity(min + i * intervalSize),
      );
      return [xValues, counts, pdf];
    }
  }

  /// Requests an update of the cached variables:
  /// * [mean],
  /// * [median],
  /// * [quartile1],
  /// * [quartile3],
  /// * [sortedSample],
  /// * [stdDev],
  void invalidateCache() {
    _mean.invalidateCache();
    _median.invalidateCache();
    _quartile1.invalidateCache();
    _quartile3.invalidateCache();
    sortedSample.invalidateCache();
    _stdDev.invalidateCache();
  }

  /// Removes values smaller than
  /// [quartile1] - [iqr] * [factor] and
  /// larger than [quartile3] + [iqr] * [factor]
  /// and returns the removed entries.
  ///
  /// Calls [invalidateCache].
  List<T> removeOutliers([num factor = 1.5]) {
    final outliers = <T>[];
    factor = factor.abs();
    final lowerFence = quartile1 - factor * iqr;
    final upperFence = quartile3 + factor * iqr;

    _sample.removeWhere((current) {
      if (current < lowerFence || current > upperFence) {
        outliers.add(current);
        return true;
      } else {
        return false;
      }
    });
    invalidateCache();
    return outliers;
  }
}
