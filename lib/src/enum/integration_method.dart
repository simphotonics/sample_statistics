/// Enumeration used to select different integration methods.
enum IntegrationMethod {
  /// The function is approximated by the average of its
  /// values at the left and right end-point of the integration
  /// sub-interval.
  trapezoidal,

  /// The function is approximated by its value at the
  /// mid-point of the sub-interval.
  midPoint,
}
