import 'dart:math';

import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart function_table_example.dart
/// ```
void main(List<String> args) {
  final lookupTable = sin.export(
    range: [pi, 2 * pi],
    label: '#      x       sin(x)',
    steps: 20,
    precision: 10,
  );

  print(lookupTable);
}
