
# Sample Statistics for Dart

[![Build Status](https://travis-ci.com/simphotonics/sample_statistics.svg?branch=main)](https://travis-ci.com/simphotonics/sample_statistics)

## Introduction

The package [`sample_statistics`][sample_statistics] provides helpers for calculating statistics of
numerical samples and generating/exporting histograms. It includes common probability
distribution functions and simple random sample generators.

## Usage

To use this package include [`sample_statistics`][sample_statistics] as a dependency in your `pubspec.yaml` file.
The package uses [null-safety] features and requires Dart SDK version `>=2.10.0`.

### Sample Statistics

To access basis sample statistics use the class [`SampleStats`][SampleStats]. It calculates most
sample statistics in a lazy fashion and caches results to avoid expensive calculations if the
same quantity is accessed repeatedly.

```Dart
 import 'package:sample_statistics/sample_statistics.dart'

 void main() {

   final sample = <num>[-10, 0, 1, 2, 3, 4, 5, 6, 20]
   final stats = SampleStats(sample)

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

<details>  <summary> Click to show console output. </summary>

 ```Console
  $ dart --enable-experiment=non-nullable sample_statistics_example.dart

  Running sample_statistic_example.dart ...
  Sample: [-10, 0, 1, 2, 3, 4, 5, 6, 20]
  min: -10
  max: 20
  mean: 3.4444444444444446
  median: 3
  first quartile: 1
  third quartile: 5
  standard deviation: 7.779960011322538
  outliers:[-10, 20]
  sample with outliers removed: [0, 1, 2, 3, 4, 5, 6]

 ```
</details>

### Random Sample Generators

This package [`sample_statistics`][sample_statistics] includes functions that can be used to generate random samples.

The function [`samplePdf`][samplePdf] is based on the [rejection sampling][rejection-sampling] method.
It expects a callback of type [`ProbabilityDensity`][ProbabilityDensity] and can be used
to generate random samples that follow an arbitrary probability distribution function.
Additinally, the package includes random sample generators based on the following probability distribution functions:
 * normal distribution,
 * truncated normal distribution,
 * exponential distribution,
 * uniform distribution,
 * triangular distribution.

```Dart
 import 'package:sample_statistics/sample_statistics.dart';

 void main(List<String> args) {
   final min = 1.0;
   final max = 9.0;
   final mean = 5.0;
   final stdDev = 2.0;

   // Generating the random sample with 1000 entries.
   final sample = sampleTruncatedNormalPdf(1000, min, max, mean, stdDev);

   final stats = SampleStats(sample);
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

The method [`histogram`][histogram] provided by the class [`SampleStats`][SampleStats]
returns an object of type `List<List<num>>` (each list entry is a numerical list).
The first entry contains the left margins of the histogram intervals or bins.
The second entry contains a count of how many sample values fall into each interval. By default,
the count is normalized such that the total area under the histogram is equal to 1.0.
This is useful when comparing a histogram to a probability density function.

The method [`histogram`][histogram] accepts the optional parameter `probabilityDensity`,
a function of type [`ProbabilityDensity`][ProbabilityDensity]. If this function is
specified it is used to
generate the values in the third list entry by evaluating the
probability density function for each interval.

The figure below shows the histograms obtained from two random samples following
a truncated normal distribution with `min = 1.5`, `max = 6.0` and parent distribution
with `mean = 3.0`, and `stdDev = 1.0`.
The samples were generated using the function [`sampleTruncatedNormalPdf`][sampleTruncatedNormalPdf].


![Directed Graph Image](https://github.com/simphotonics/sample_statistics/blob/main/example/plots/histogram_truncated_normal_2.svg)

The figure on the left shows the histogram of a sample with size 1000. The figure on the right shows
the histogram of a sample with size 6750. Increasing the random sample size leads to an increasingly
closer match between the shape of the histogram and the underlying probability distribution.

The mean of a truncated normal distribution can be calculate using the function
[`meanTruncatedNormal`][meanTruncatedNormal]. Using the parameters mentioned above one can determine
a theoretical mean of 3.134. It can be seen that in the limit of a large sample
size the *sample mean* approaches
the *mean* of the underlying probability distribution.

## Examples

For further examples on how to generate random samples, export histograms,
and access sample statistics see folder [example].



## Features and bugs

Please file feature requests and bugs at the [issue tracker].


[CachedObjectFactory]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/CachedObjectFactory.html

[example]: https://github.com/simphotonics/sample_statistic/tree/master/example

[histogram]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/SampleStats/histogram.html

[issue tracker]: https://github.com/simphotonics/sample_statistics/issues

[meanTruncatedNormal]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/meanTruncatedNormal.html

[null-safety]: https://dart.dev/null-safety

[ProbabilityDensity]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/ProbabilityDensity.html

[rejection-sampling]: https://en.wikipedia.org/wiki/Rejection_sampling

[sample_statistics]: https://pub.dev/packages/sample_statistics

[samplePdf]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/samplePdf.html

[SampleStats]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/SampleStats-class.html

[sampleTruncatedNormalPdf]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/sampelTruncatedNormalPdf.html