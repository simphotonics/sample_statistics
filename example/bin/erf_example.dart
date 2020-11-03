import 'package:statistics/statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable erf_example.dart
/// ```
void main(List<String> args) async{
  final x0 = -10;
  final x1 = 10;
  final range = x1 - x0;
  final n = 1000;
  final dx = range / n;
  final y = List<num>.generate(n, (i) => erf(x0 + i * dx));

  /// Writes a tabulated list of erf(x) to file erf.dat.
  await y.export('../sample_data/erf.dat', range: [x0, x1]);
}
