import 'package:exception_templates/exception_templates.dart';

import '../exceptions/invalid_function_parameter.dart';

/// Adds the getter `factorial`.
extension Factorial on int {
  static final _cache = <int, int>{0: 1};

  /// Returns the factorial of this.
  int get factorial {
    if (this < 0) {
      throw ErrorOfType<InvalidFunctionParameter>(
        message: 'The getter factorial is not defined for negative numbers.',
        invalidState: '$this < 0.',
      );
    }
    if (this == 0) {
      return 1;
    } else {
      return _cache[this] ??= this * (this - 1).factorial;
    }
  }
}
