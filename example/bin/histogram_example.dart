import 'package:statistics/src/samples/normal_random_sample.dart';
import 'package:statistics/statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable histogram_example.dart
/// ```
void main(List<String> args) async {
  // The variable  'sample' is defined in the file normal_random_sample.dart.

  // Generates a histogram and exports it to a file.
  await normalRandomSample.exportHistogram(
    '../sample_data/normal_random_sample.hist',
  );
}
