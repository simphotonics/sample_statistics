/// Specifies the layout of a block histogram.
enum HistogramLayout {
  /// The minimum number of intervals is chosen such that the info line
  /// can accommodate the minimum sample value, the interval size, and
  /// the maximum sample value.
  fitInfo,

  /// The minimum number of intervals is chose such that the info line
  /// can accommodate the minimum and maximum sample values.
  fitMinMax,

  /// The info line is not included.
  omitInfo;

  /// Returns `true` if this is [fitInfo],
  /// and `false` otherwise.
  bool get isFitInfo => this == fitInfo;

  /// Returns `true` if this is [fitMinMax],
  /// and `false` otherwise.
  bool get isMinMax => this == fitMinMax;

  /// Returns `true` if this is [omitInfo],
  /// /// and `false` otherwise.
  bool get isOmitInfo => this == omitInfo;
}
