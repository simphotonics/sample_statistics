import 'dart:math' as math show max;

import 'package:lazy_memo/lazy_memo.dart';
import 'package:list_operators/list_operators.dart';

import '../extensions/root.dart';
import 'probability_density.dart';

/// Provides access to basic statistical entities of a
/// numerical random sample.
class Stats<T extends num> {
  Stats(this.sample);

  /// Numerical data sample. Must not be empty.
  final List<T> sample;

  /// Sorted sample stored as lazy variable.
  late final _sortedSample = Lazy<List<T>>(() => sample..sort());

  /// Sample mean.
  late final _mean = Lazy<double>(() => sample.mean());

  /// Corrected sample standard deviation.
  late final Lazy<double> _stdDev = Lazy<double>(() => sample.stdDev());

  /// Returns the smallest sample value.
  late final _min = Lazy<T>(() => _sortedSample().first);

  /// Returns the smallest sample value.
  T get min => _min();

  /// Returns the largest sample value.
  late final _max = Lazy<T>(() => _sortedSample().last);

  /// Return the largest sample value.
  T get max => _max();

  /// Returns the first quartile.
  num get quartile1 => _quartile1();

  late final _quartile1 = Lazy<num>(() {
    final length = _sortedSample().length;
    final halfLength = (length.isOdd) ? length ~/ 2 + 1 : length ~/ 2;
    final q1 = halfLength ~/ 2;
    return (halfLength.isEven)
        ? (_sortedSample()[q1 - 1] + _sortedSample()[q1]) / 2
        : _sortedSample()[q1];
  });

  /// Returns the sample median (second quartile).
  num get median => _median();

  late final _median = Lazy<num>(() {
    final q2 = _sortedSample().length ~/ 2;
    return (sample.length.isEven)
        ? (_sortedSample()[q2 - 1] + _sortedSample()[q2]) / 2
        : _sortedSample()[q2];
  });

  /// Returns the third quartile.
  num get quartile3 => _quartile3();

  late final _quartile3 = Lazy<num>(() {
    final length = _sortedSample().length;
    final halfLength = (length.isOdd) ? length ~/ 2 + 1 : length ~/ 2;
    final q3 = length ~/ 2 + halfLength ~/ 2;
    return (halfLength.isEven)
        ? (_sortedSample()[q3 - 1] + _sortedSample()[q3]) / 2
        : _sortedSample()[q3];
  });

  /// Returns the sample mean.
  ///
  /// Throws an exception of type `ExceptionOf<SampleStats>` if the
  /// sample is empty.
  double get mean => _mean();

  /// Returns the corrected sample standard deviation.
  /// * The sample must contain at least 2 entries.
  /// * The normalization constant for the corrected standard deviation is
  ///   `sample.length - 1`.
  double get stdDev => _stdDev();

  /// Returns the optimal interval according to the Freedman-Diaconis rule
  /// taking into account the inter-quartile range and the sample size.
  double get intervalSize =>
      2 * (quartile3 - quartile1) / (_sortedSample().length.root(3));

  /// Returns the optimal number of intervals. The interval size
  /// is estimated using the Freedman-Diaconis rule.
  int get intervals => math.max((max - min) ~/ intervalSize, 3);

  /// Returns an object of type `List<List<num>>` containing a sample histogram.
  /// * The first list contains the interval mid points. The left most interval
  ///   has boundaries: `min - h/2 ... min + h/2. The right most interval has
  ///   boundaries: `max - h/2 ... max + h/2`.
  ///
  /// * The second list represent a count of how many sample values fall into
  ///   each interval. If `normalize == true`, the histogram count
  ///   will be normalized using the factor: `sampleSize * intervalSize`, such
  ///   that the total area of the histogram bar is equal to one.
  ///   This is useful when comparing the histogram to a
  ///   probability distribution.
  /// * The third list contains the `probabilityDensity` evaluated at each point
  ///   `(min, min + h, ..., max)`.
  ///   The default value of `probabilityDensity` is `normalPdf(x, mean, stdDev)`,
  ///   where `mean` is the sample mean and `stdDev` is the sample standard
  ///   deviation.
  List<List<double>> histogram({
    bool normalize = true,
    int intervals = 0,
    ProbabilityDensity? probabilityDensity,
  }) {
    final sampleSize = _sortedSample().length;

    intervals = intervals < 2 ? this.intervals : intervals;

    /// Make sure we have at least 2 intervals
    while (intervals < 2) {
      intervals++;
    }

    final intervalSize = (max - min) / intervals;
    final gridPoints = intervals + 1;

    final xValues = List<double>.generate(
      gridPoints,
      (i) => min + i * intervalSize,
      growable: false,
    );
    final yValues = List<double>.filled(gridPoints, 0.0);

    final leftBorder = min - intervalSize / 2;

    // Generating histogram
    for (final current in _sortedSample()) {
      // Calculate interval index of current.
      final index = (current - leftBorder) ~/ intervalSize;
      ++yValues[index];
    }

    if (normalize) {
      for (var i = 0; i < gridPoints; ++i) {
        yValues[i] = yValues[i] / (sampleSize * intervalSize);
      }
    }

    // Add value row for probability density.
    probabilityDensity ??= (x) => normalPdf(x, mean, stdDev);
    final pdf = List<double>.generate(
      gridPoints,
      (i) => probabilityDensity!(min + i * intervalSize),
    );
    return [xValues, yValues, pdf];
  }

  /// Requests an update of the cached variables:
  /// * `sortedSample`,
  /// * `mean`,
  /// * `median`,
  /// * `stdDev`,
  /// * `min`,
  /// * `max`,
  /// * `quartile1`,
  /// * `quartile2`,
  void update() {
    _sortedSample.updateCache();
    _mean.updateCache();
    _median.updateCache();
    _stdDev.updateCache();
    _min.updateCache();
    _max.updateCache();
    _quartile1.updateCache();
    _quartile3.updateCache();
  }
}
