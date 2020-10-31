import 'package:statistics/src/samples/normal_random_sample.dart';
import 'package:statistics/statistics.dart';

void main(List<String> args) async {
  // The sample is defined in normal_random_sample.dart.

  // Generates a histogram and exports it to a file.
  await normalRandomSample.exportHistogram(
    '../plots/normal_random_sample.hist',
  );
}
