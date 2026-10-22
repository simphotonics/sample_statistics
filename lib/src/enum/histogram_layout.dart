enum HistogramLayout(
  /// If the tail of the probabililty density on either side of the
  /// sample median exceeds [maxTailWidth], it will be shortened and the
  /// number of omitted intervals will be displayed.
  final int maxTailWidth,
) {
  /// A histogram with [maxTailWidth] 10.
  compact(10),

  /// A histogram with [maxTailWidth] 20.
  standard(20),

  /// A histogram with [maxTailWidth] 25.
  wide(25),
}
