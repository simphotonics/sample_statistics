
# Sample Statistics for Dart



## Introduction

The package [`statistics`][statistic] provides libraries for calculating statistics of
numerical samples, as well as generating and exporting histograms. It includes common probability
distribution functions and simple random sample generators.

## Usage

To use this package include [`statistics`][statistics] as a dependency in your pubspec.yaml file.
The package uses [null-safety] features and requires Dart SDK version `>=2.10.0`.

### Sample Statistic

To access basis sample statistics use the class `SampleStatistics`. It calculates
sample statistics in a lazy fashion and caches results to avoid expensive calculations if the
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
`sample_generators`. It includes random number generators for common probabiliy distribution such
as for the *normal distribution*,
the *exponential distribution*, the *truncated normal distribution*.

The function `sample()` expects a callback of type `ProbabilityDensity` and can be used
to generate random numbers that follow an arbitrary probability distribution function.

```Dart
 import 'package:statistics/statistics.dart';

 void main(List<String> args) {
   final min = 1.0;
   final max = 9.0;
   final mean = 5.0;
   final stdDev = 2.0;

   // Generating the random sample with 1000 entries.
   final sample = truncatedNormalSample(1000, min, max, mean, stdDev);

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

To generate a histogram the first step is to divide the random sample range `max - min`
into a suitable number of intervals.
The second step consists of counting how many sample entries fall into each
interval.

The method `histogram` provided by the class `SampleStatistics`
returns an object of type `List<List<num>>` (each list entry is a numerical list).
The first entry contains the left margins of the histogram intervals or bins.
The second entry contains a count of how many sample values fall into each interval. By default,
the count is normalized such that the total area under the histogram is equal to 1.0.
This is useful when comparing a histogram to a probability density function.

The method `histogram` accepts the optional parameter `probabilityDensity`, a function of type `ProbabilityDensity`. If this function is specified it is used to
generate the values in the third list entry by evaluating the
probability density function for each interval.

The figure below shows the histograms obtained from two random samples following a truncated
normal distribution with `min = 1.5`, `max = 6.0`, `mean = 3.0`, and `stdDev = 1.0`.
The samples were generated using the function `truncatedNormalSample`
provided by the library `sample_generators`.

![Directed Graph Image](https://github.com/simphotonics/statistics/blob/main/example/plots/histogram_truncated_normal_2.svg)

The figure on the left shows the histogram of a sample with size 1000. The figure on the right
shows the histogram of a sample with size 6750. Increasing the random sample size leads to a
better match between the shape of the histogram and the underlying probability distribution.

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
