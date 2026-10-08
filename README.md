
# Sample Statistics
[![Dart](https://github.com/simphotonics/sample_statistics/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/sample_statistics/actions/workflows/dart.yml)


## Introduction

The package [`sample_statistics`][sample_statistics] provides helpers for
calculating *statistics* of numerical samples and generating/exporting
*histograms*. It includes common *probability
distribution* functions, an approximation of the *error function*,
and random sample *generators*.

Throughout the library the acronym *pdf* stands for *Probability Distribution
Function*, while *cdf* stands for *Cummulative Distribution Function*.

## Usage

To use this package include [`sample_statistics`][sample_statistics]
as a dependency in your `pubspec.yaml` file.

### 1. Sample Statistics

To access sample statistics use the class [`Stats`][Stats].
It calculates sample statistics in a lazy fashion and caches results
to avoid lengthy calculations when the same quantity is accessed repeatedly.

```Dart
 import 'package:sample_statistics/sample_statistics.dart'

 void main() {

   final sample = <num>[-10, 0, 1, 2, 3, 4, 5, 6, 20];
   final stats = Stats(sample);

   print('\nRunning statistic_example.dart ...')
   print('Sample: $sample');
   print('min: ${stats.min}');
   print('max:  ${stats.max}');
   print('mean: ${stats.mean}');
   print('median: ${stats.median}');
   print('first quartile:  ${stats.quartile1}');
   print('third quartile:  ${stats.quartile3}');
   print('interquartile range:  ${stats.iqr}');
   print('standard deviation:  ${stats.stdDev}');

   final outliers = sample.removeOutliers();
   print('outliers: $outliers');
   print('sample with outliers removed:  $sample');
   stats.addDataPoints([-2, 7]);
   print('Sample with additional data points: ${stats.sample}');
   print('Sorted sample: ${stats.sortedSample}');
 }
```

<details>  <summary> Click to show console output. </summary>

 ```Console
  $ dart  sample_statistics_example.dart
  Running sample_statistics_example.dart ...
  Sample: [-10, 0, 1, 2, 3, 4, 5, 6, 20]
  min: -10
  max: 20
  mean: 3.4444444444444446
  median: 3
  first quartile: 1
  third quartile: 5
  inter-quartile-range:4
  standard deviation: 7.779960011322538
  outliers:[-10, 20]
  Sample without outliers: [0, 1, 2, 3, 4, 5, 6]
  Sample with additional data points: [0, 1, 2, 3, 4, 5, 6, -2, 7]
  Sorted sample: [-2, 0, 1, 2, 3, 4, 5, 6, 7]

 ```
</details>

### 2. Histograms

To package includes extension methods on [`Stats`][Stats]
provides methods for generating and exporting histograms:

```Dart
import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) {
  final sample = [
    -10, -8, -5,-4, -3, -3,-1, -1, -1, 0, 0, 0,
    0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 7, 10, 14,
  ];

  final stats = Stats(sample);
  print(stats.exportHistogram(verbose: true, normalize: false));
  print(stats.blockHistogram());
}
```
The console output is show below:
```
$ dart example/bin/histogram_example.dart
# Intervals: 8
# Min: -10.00000000
# Max: 14.00000000
# Interval size: 3.428571429
# Mean:   0.8461538462
# StdDev: 5.065114472
# Median: 0.5000000000
# First Quartile: -1.000000000
# Third Quartile: 3.000000000
# Histogram integral: 89.14285714285715
#
# -------------------------------------------------------------
#     Interval Mid-Point                  Count
        -10.00000000                 1.000000000
        -6.571428571                 2.000000000
        -3.142857143                 3.000000000
        0.2857142857                 9.000000000
        3.714285714                  8.000000000
        7.142857143                  1.000000000
        10.57142857                  1.000000000
        14.00000000                  1.000000000

 ▁▂▃▉█▁▁▁
```
On a monochrome terminal the block histogram is rendered as shown above.
On a terminal with Ansi support, the block histogram is rendered as:

${▁▂▃\color{cyan}▉ \color{default} █▁▁▁ }$

If a block contains the ${\color{#22ff33}mean}$ it is colored green.
If it contains the ${\color{#0088ff}median}$
of the sample it is colored blue. In this case, the block containing
the ${\color{#00ffff}mean \space \color{default} and \space \color{cyan} median}$ is printed in a cyan hue.

The image below shows the histogram data plotted using [gnuplot][gnuplot].
![Histogram](https://github.com/simphotonics/sample_statistics/raw/main/images/histogram.svg?sanitize=true)

### 3. Random Sample Generators

The library `sample_generators` includes functions for generating random samples
that follow the probability distribution functions listed below:
 * normal distribution,
 * truncated normal distribution,
 * exponential distribution,
 * uniform distribution,
 * triangular distribution.

Additionally, the library includes the function [`randomSample`][randomSample]
which is based on the [rejection sampling][rejection-sampling] method.
It expects a callback of type [`ProbabilityDensity`][ProbabilityDensity]
and can be used to generate random samples that follow
an *arbitrary* probability distribution function.

The program listed below demonstrates how to generated a random sample
and write a histogram to a file.

```Dart
import 'dart:io';

 import 'package:sample_statistics/sample_statistics.dart';

 void main(List<String> args) async{
   final xMmin = 1.0;
   final xMmax = 9.0;
   final meanOfParent = 5.0;
   final stdDevOfParent = 2.0;
   final sampleSize = 1000;

   // Generating the random sample with 1000 entries.
   final sample = truncatedNormalSample(
     sampleSize,
     xMmin,
     xMmax,
     meanOfParent,
     stdDevOfParent,
   );

   final stats = Stats(sample);
   print(stats.mean);
   print(stats.stdDev);
   print(stats.min);

   // Exporting a histogram.
   // Export histogram
   await File('example/data/truncated_normal$sampleSize.hist').writeAsString(
     sample.exportHistogram(
       pdf: (x) =>
           truncatedNormalPdf(x, xMin, xMax, meanOfParent, stdDevOfParent),
     ),
   );

 }
```

## Examples

For further examples on how to generate random samples, export histograms,
and access sample statistics see folder [example].



## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/sample_statistics/issues

[example]: https://github.com/simphotonics/sample_statistics/tree/main/example

[exportHistogram]:https://pub.dev/documentation/sample_statistics/latest/sample_statistics/StatisticsUtils/exportHistogram.html

[gnuplot]: http://www.gnuplot.info

[histogram]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/Stats/histogram.html

[meanTruncatedNormal]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/meanTruncatedNormal.html

[ProbabilityDensity]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/ProbabilityDensity.html

[normalPdf]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/normalPdf.html

[randomSample]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/randomSample.html

[rejection-sampling]: https://en.wikipedia.org/wiki/Rejection_sampling

[sample_statistics]: https://pub.dev/packages/sample_statistics

[samplePdf]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/samplePdf.html

[Stats]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/Stats-class.html

[truncatedNormalSample]: https://pub.dev/documentation/sample_statistics/latest/sample_statistics/truncatedNormalSample.html