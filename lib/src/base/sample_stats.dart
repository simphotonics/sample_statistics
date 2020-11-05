import 'dart:math' as math;

import 'package:exception_templates/exception_templates.dart';
import 'package:lazy_memo/lazy_memo.dart';

import '../exceptions/empty_iterable.dart';
import 'density_functions.dart';
import 'utility_extensions.dart';

/// Provides access to basic statistical entities of a
/// numerical random sample.
class SampleStats {
  SampleStats(this.sample)
      : sortedSample = Lazy<List<num>>(() {
          assertNotEmpty(sample);
          return sample..sort();
        }),
        _mean = Lazy<num>(() => sample.sum / sample.length);

  /// Numerical data sample. Must not be empty.
  final List<num> sample;

  /// Sorted sample stored as lazy variable.
  final Lazy<List<num>> sortedSample;

  /// Sample mean.
  final Lazy<num> _mean;

  /// Corrected sample standard deviation.
  Lazy<double>? _stdDev;

  /// Returns the smallest sample value.
  num get min {
    if (sortedSample.isUpToDate) {
      return sortedSample().first;
    } else {
      return sample.min;
    }
  }

  /// Return the largest sample value.
  num get max {
    if (sortedSample.isUpToDate) {
      return sortedSample().last;
    } else {
      return sample.max;
    }
  }

  /// Returns the first quartile.
  num get quartile1 {
    final length = sample.length;
    final halfLength = (length.isOdd) ? length ~/ 2 + 1 : length ~/ 2;
    final q1 = halfLength ~/ 2;
    return (halfLength.isEven)
        ? (sortedSample()[q1 - 1] + sortedSample()[q1]) / 2
        : sortedSample()[q1];
  }

  /// Returns the sample median (second quartile).
  num get median {
    final q2 = sample.length ~/ 2;
    return (sample.length.isEven)
        ? (sortedSample()[q2 - 1] + sortedSample()[q2]) / 2
        : sortedSample()[q2];
  }

  /// Returns the third quartile.
  num get quartile3 {
    final length = sample.length;
    final halfLength = (length.isOdd) ? length ~/ 2 + 1 : length ~/ 2;
    final q3 = length ~/ 2 + halfLength ~/ 2;
    return (halfLength.isEven)
        ? (sortedSample()[q3 - 1] + sortedSample()[q3]) / 2
        : sortedSample()[q3];
  }

  /// Returns the sample mean.
  ///
  /// Throws an exception of type `ExceptionOf<SampleStats>` if the
  /// sample is empty.
  num get mean => _mean();

  /// Returns the corrected sample standard deviation.
  /// * The sample must contain at least 2 entries.
  /// * The normalization constant for the corrected standard deviation is
  ///   `sample.length - 1`.
  num get stdDev {
    if (sample.length < 2) {
      throw ExceptionOf<SampleStats>(
        message: 'Sample standard deviation can not be calculated.',
        invalidState: sample,
        expectedState: 'A sample with at least 2 entries.',
      );
    }
    if (_stdDev == null) {
      _stdDev = Lazy<double>(() => math.sqrt(
            sample.fold<num>(
                    0,
                    (sum, current) =>
                        sum + (current - mean) * (current - mean)) /
                (sample.length - 1),
          ));
      return _stdDev!();
    } else {
      return _stdDev!();
    }
  }

  /// Returns an object of type `List<List<num>>` containing a sample histogram.
  /// * The first list represents the range of the sample values divided into
  ///   a suitable number of `intervals`:`(min, min + h, ... max)`, where `h` is
  ///   the `intervalSize`.
  ///   The default number of intervals is
  ///   calculated using the Freedman-Diaconis rule.
  ///
  /// * The second list represent a count of how many sample values fall into
  ///   each interval.
  ///    - If `normalize == true`, the histogram count will be normalized using the
  ///     factor: `sampleSize * intervalSize`. This is suitable when comparing
  ///     the histogram to a probability distribution.
  /// * The third list is only added if `normalized == true`. It contains the
  ///   `probabilityDensity` evaluated at each point `(min, min + h, ..., max)`.
  ///   - The default value of `probabilityDensity` is `normalPdf(x, mean, stdDev)`,
  ///   where `mean` is the sample mean and `stdDev` is the sample standard
  ///   deviation.
  List<List<num>> histogram({
    bool normalize = true,
    int? intervals,
    ProbabilityDensity? probabilityDensity,
  }) {
    final sampleSize = sample.length;
    // Number of intervals (Freedman-Diaconis rule).
    final optimalIntervalSize =
        2 * (quartile3 - quartile1) / sampleSize.root(3);
    intervals ??= (max - min) ~/ optimalIntervalSize;
    final intervalSize = (max - min) / intervals;
    final n = intervals + 1;
    probabilityDensity ??= (num x) => normalPdf(x, mean, stdDev);
    // final minMid = min + 0.5 * intervalSize;
    final xValues = List<num>.generate(n, (i) => min + i * intervalSize);
    final yValues = List<num>.generate(n, (_) => 0.0);

    for (final current in sample) {
      // Calculate interval index of current.
      final index = (current - min) ~/ intervalSize;
      ++yValues[index];
    }

    if (normalize) {
      for (var i = 0; i < n; ++i) {
        yValues[i] = yValues[i] / (sampleSize * intervalSize);
      }
      final pdf = List<num>.generate(
          n, (i) => probabilityDensity!(min + i * intervalSize));
      return [xValues, yValues, pdf];
    } else {
      return [xValues, yValues];
    }
  }

  /// Requests an update of the cached variables:
  /// * `sortedSample`,
  /// * `mean`,
  /// * `stdDev`.
  void update() {
    sortedSample.updateCache();
    _mean.updateCache();
    _stdDev?.updateCache();
  }

  /// Throws an exception if `sample` is empty.
  static void assertNotEmpty(Iterable sample) {
    if (sample.isEmpty) {
      throw ExceptionOfType<EmptyIterable>(
        message: 'Stats can not be calculated.',
        invalidState: 'Sample is empty.',
      );
    }
  }
}
