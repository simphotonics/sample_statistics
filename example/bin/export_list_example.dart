import 'dart:math';

import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable export_list_example.dart
/// ```
void main(List<String> args) {
  final dx = pi / 100;

  final y = List<num>.generate(101, (i) => sin(pi + i * dx));

  final lookupTable = y.export(
    precision: 4,
    range: [pi, 2 * pi],
    label: '// x  sin(x)',

  );

  print(lookupTable);
}
