/// Specifies the info placed along the horizontal axis
/// of the histogram.
enum HistogramInfoOption {
  /// Include the minimum sample value, the interval size, and
  /// the maximum sample value.
  showAll,

  /// Include the minimum and maximum sample values.
  showMinMax,

  /// Histogram info is omitted.
  showNone;

  /// Returns `true` if this is [showAll],
  /// and `false` otherwise.
  bool get isShowAll => this == showAll;

  /// Returns `true` if this is [showMinMax],
  /// and `false` otherwise.
  bool get isShowMinMax => this == showMinMax;

  /// Returns `true` if this is [showNone],
  /// /// and `false` otherwise.
  bool get isShowNone => this == showNone;
}
