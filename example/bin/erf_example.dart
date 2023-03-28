import 'dart:io';

import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the main project folder and use the
/// command:
/// ```Console
/// $ dart example/bin/erf_example.dart
/// ```
void main(List<String> args) async {
  final x0 = -2;
  final x1 = 2;

  /// Writes a tabulated list of erf(x) to file erf.dat.
  await File('example/data/erf.dat').writeAsString(
    ((num x) => erf(x)).export(range: [x0,x1], steps: 1000)
  );
}
