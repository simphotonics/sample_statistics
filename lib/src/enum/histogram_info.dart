/// Specifies the info placed along the horizontal axis
/// of the histogram.
enum HistogramInfoOption {
  /// Include the sample min/max and the interval size.
  ///
  /// The default format is:
  /// ```
  ///       ██▄▄
  /// ▂▂▂▂▇▇████▅▅▂▂▂▂▂▂
  /// -10   ←→ 3.000  14
  /// ```
  /// If the number of intervals is too short,
  /// min, interval size, and max are listed sequentially.
  /// ```
  ///       ██▄▄
  /// ▂▂▂▂▇▇████▅▅▂▂▂▂
  /// min: -10, interval: 3.000, max: 14
  /// ```
  showAll,

  /// Include the symbol "←→" below the block containing the
  /// sample median. The sample min/max and the interval size
  /// are included if possible.
  ///
  /// The default format is:
  /// ```
  ///       ██▄▄
  /// ▂▂▂▂▇▇████▅▅▂▂▂▂▂▂▂
  /// -10   ←→ 3.000   14
  /// ```
  /// If the number of intervals is too short, the median
  /// symbol is included and other info is included if possible.
  /// ```
  ///   ██▄▄
  /// ▂▇████▅▅▂▂__▂▂
  ///   ←→ 3.000  14
  /// ```
  showMedian,

  /// Include the mininum and maximum of the sample values.
  ///
  /// The default format is:
  /// ```
  ///       ██▄▄
  /// ▂▂▂▂▇▇████▅▅▂▂▂▂▂▂
  /// -10             14
  /// ```
  /// If the number of intervals is too short,
  /// min and max are listed sequentially.
  /// ```
  ///       ██▄▄
  /// ▂▂▂▂▇▇████▅▅▂▂▂▂__
  /// min: -10.00, max: 14.00
  /// ```
  showMinMax,

  /// Histogram info is omitted.
  showNone;

  /// Returns `true` if this is [showAll],
  /// and `false` otherwise.
  bool get isShowAll => this == showAll;

  bool get isShowMedian => this == showMedian;

  /// Returns `true` if this is [showMinMax],
  /// and `false` otherwise.
  bool get isShowMinMax => this == showMinMax;

  /// Returns `true` if this is [showNone],
  /// /// and `false` otherwise.
  bool get isShowNone => this == showNone;
}
