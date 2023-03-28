import 'package:list_operators/list_operators.dart' show ExportListOfList;

import 'integrate.dart' show NumericalFunction;

/// Extension providing the methods `export` and `table`.
extension FunctionTable on NumericalFunction {
  /// Returns a `String` containing a function table. Usage demonstrated below.
  /// * `range`: A list containing the start and end points of the
  /// function argument. If `range` contains more than 2 entries these
  /// will be interpreted as the function arguments.
  /// * `steps`: Number of table entries. Note: This parameter is
  /// ignored if `range` contains more than 2 entries. In that case
  /// `steps == range.length`.
  /// * `label`: The first line of the output `String`.
  /// * `precision`: The precision used to convert numbers to strings.
  /// ---
  /// Usage:
  /// ```
  /// import dart:math;
  /// final table = sin.export(
  ///   label: 'x     sin(x)',
  ///   range: [0, 2*pi],
  ///   steps: 5,
  ///   precision: 4,
  /// );
  /// print(table);
  /// ```
  /// A sample output is listed below:
  /// ```
  /// x     sin(x)
  /// 0.0000 0.0000
  /// 0.39270 0.38268
  /// 0.78540 0.70711
  /// 1.1781 0.92388
  /// 1.5708 1.0000
  /// ```
  String export({
    List<num> range = const [0, 1],
    int steps = 100,
    int precision = 20,
    String label = '#     x     y',
    String delimiter = ' ',
  }) {
    final table = this.table(range: range, steps: steps);
    return [
      table.keys.toList(),
      table.values.toList(),
    ].export(
        label: label, precision: precision, delimiter: delimiter, flip: true);
  }

  /// Returns a map of type `Map<num, num>`
  /// containing a function table. Usage demonstrated below.
  /// * `range`: A list containing the start and end points of the
  /// function argument. If `range` contains more than 2 entries these
  /// will be interpreted as the function arguments.
  /// * `steps`: Number of table entries. Note: This parameter is
  /// ignored if `range` contains more than 2 entries. In that case
  /// `steps == range.length`.
  /// ---
  /// Usage:
  /// ```
  /// import dart:math;
  /// final table = sin.export(
  ///   range: [0, 2*pi],
  ///   steps: 5,
  /// );
  /// ```
  Map<num, num> table({
    List<num> range = const [0, 1],
    int steps = 100,
  }) {
    final result = <num, num>{};
    final x0 = (range.isEmpty) ? 0 : range.first;
    final dx = (range.isEmpty)
        ? 1
        : (range.length < 2)
            ? 1
            : (range.last - range.first) / (steps - 1);
    num arg = 0;
    for (var i = 0; i < steps; ++i) {
      arg = x0 + i * dx;
      result[arg] = this(arg);
    }
    return result;
  }
}
