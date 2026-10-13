import 'dart:collection';

import 'package:lazy_memo/lazy_memo.dart';
import 'package:list_operators/list_operators.dart';

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
  List<T> removeOutliers([num factor = 3 ]) {
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
