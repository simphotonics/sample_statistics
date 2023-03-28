import 'dart:io';

import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart erfc_example.dart
/// ```
void main(List<String> args) async {
  final x0 = -1000;
  final x1 = 1000;

  /// Writes a tabulated list of erfc(x) to file erfc.dat.
  await File('../data/erfc.dat').writeAsString(
    ((num x) => erfc(x)).export(range: [x0,x1], steps: 1000)
  );
}
