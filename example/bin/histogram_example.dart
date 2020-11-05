import 'dart:io';

import 'package:sample_statistics/src/samples/normal_random_sample.dart';
import 'package:sample_statistics/sample_statistics.dart';

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart --enable-experiment==non-nullable histogram_example.dart
/// ```
void main(List<String> args) async {
  // The variable  'sample' is defined in the file normal_random_sample.dart.

  // Generates a histogram and exports it to a file.
  await File('../sample_data/normal_random_sample.hist').writeAsString(
    normalRandomSample.exportHistogram(),
  );
}
