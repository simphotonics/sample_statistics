
# Sample Statistics for Dart



## Introduction

The package [`statistics`][statistic] provides libraries for calculating statistics of
numeric samples, as well as generating and exporting histograms. It includes common probability
distribution functions and a simple random sample generator.

## Usage

To use this library include [`statistics`][statistics] as a dependency in your pubspec.yaml file.
The package uses [null-safety] features and requires Dart SDK version `>=2.10.0`.

### Sample Statistic

To access basis sample statistics use the class `SampleStatistics`. It calculates
sample statistics in a lazy fashion and caches results to avoid expensive calculation if the
same quantity is accessed repeatedly.

```Dart
 import 'package:statistics/statistics.dart'

 void main() {

   final sample = <num>[-10, 0, 1, 2, 3, 4, 5, 6, 20]
   final stats = SampleStatistics(sample)

   print('\nRunning statistic_example.dart ...')
   print('Sample: $sample')
   print('min: ${stats.min}')
   print('max:  ${stats.max}')
   print('mean: ${stats.mean}')
   print('median: ${stats.median}')
   print('first quartile:  ${stats.quartile1}')
   print('third quartile:  ${stats.quartile3}')
   print('standard deviation:  ${stats.stdDev}')

   final outliers = sample.removeOutliers();
   print('outliers: $outliers')
   print('sample with outliers removed:  $sample');
 }
```

### Random Sample Generators

To generate random samples that follow a certain probability distribution use the library
`sample_generators`. It includes random number generators for the *normal distribution*,
the *exponential distribution*, and the *truncated normal distribution*.
The function `generateSample()` expects a callback of type `ProbabilityDensity` and can be used
to generate random numbers that follow an arbitrary probability distribution function.

```Dart
 import 'package:statistics/statistics.dart';

 void main(List<String> args) {
   final min = 1.0;
   final max = 9.0;
   final mean = 5.0;
   final stdDev = 2.0;

   // Generating the random sample with 1000 entries.
   final sample = generateTruncatedNormalSample(1000, min, max, mean, stdDev);

   final stats = SampleStatistics(sample);
   print(stats.mean);
   print(stats.stdDev);
   print(stats.min);

   // Exporting a histogram.
   sample.exportHistogram(
     '../plots/truncated_normal.hist',
     pdf: (x) =>
         truncatedNormalPdf(x, stats.min, stats.max, stats.mean, stats.stdDev),
   );
 }
```

### Histograms

To generate a histogram use the method `histogram()` provided by the class `SampleStatistics`.






## Examples

For further example on how to generate random samples, export histograms, and access sample statistics see folder [example].



## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[CachedObjectFactory]: https://pub.dev/documentation/statistics/latest/statistics/CachedObjectFactory.html

[issue tracker]: https://github.com/simphotonics/statistics/issues

[example]: https://github.com/simphotonics/statistic/tree/master/example

[statistics]: https://pub.dev/packages/statistics

[lazy_initialization]: https://en.wikipedia.org/wiki/Lazy_initialization

[null-safety]: https://dart.dev/null-safety

[Lazy]: https://pub.dev/documentation/statistics/latest/statistics/Lazy-class.html
