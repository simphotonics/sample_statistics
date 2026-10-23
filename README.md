
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

Extension methods on [`Stats`][Stats]
can be used to generate and export histograms:

```Dart
import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) {
  final sample = [
    -20,-10,-8, -5, -4, -3, -3, -1, -1, -1, -1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
    1, 2, 2, 2, 3, 3, 4, 4, 5, 7, 10, 14, 40,
  ];

  final stats = Stats(sample);
  print(stats.exportHistogram(verbose: true, normalize: false));
}
```
The console output is show below:
```Console
$ dart example/bin/histogram_example.dart
# Intervals: 9
# Min: -10.00000000
# Max: 14.00000000
# Interval size: 3.000000000
# Mean:   0.7857142857
# StdDev: 4.878958168
# Median: 0.000000000
# First Quartile: -1.000000000
# Third Quartile: 3.000000000
# Histogram integral: 84.0
#
# -------------------------------------------------------------
#     Interval Mid-Point                  Count
        -10.00000000     1.000000000
        -7.000000000     1.000000000
        -4.000000000     4.000000000
        -1.000000000     9.000000000
        2.000000000      7.000000000
        5.000000000      3.000000000
        8.000000000      1.000000000
        11.00000000      1.000000000
        14.00000000      1.000000000
```
A histogram constructed from Unicode block character may be printed using the
command:
```Dart
// Ansi.status = AnsiOutput.disabled; // Uncomment if the terminal is not
//                                       Ansi compatible.
print(stats.blockHistogram());
```
On a monochrome terminal the block histogram is rendered as shown below:
![Block Histogram](https://github.com/simphotonics/sample_statistics/raw/main/images/block_histogram_monochrome.svg?sanitize=true)

On a terminal with Ansi support, the block histogram is rendered as:
![Block Histogram](https://github.com/simphotonics/sample_statistics/raw/main/images/block_histogram.svg?sanitize=true)


If a block contains the sample *mean*, it is rendered in a green hue.
If it contains the *median* of the sample it is colored blue.
If the same block contains the *mean* and *median* is printed in a cyan hue.
The arrows indicating the interval size are placed below the block
containing the sample *median*.

Note: If the inter-quartal range is small compared to the range of the data
sample, then the number of histogram intervals will be large.
To shorten the histogram string, some intervals are skipped and the number of
skipped intervals will be printed instead.

The image below shows the histogram data presented above plotted using gnuplot.
![Histogram](https://github.com/simphotonics/sample_statistics/raw/main/images/histogram.svg?sanitize=true)

### 3. Random Sample Generators

The library also includes functions for generating random samples
that follow a:
 * normal prob. dist.,
 * truncated normal prob. dist.,
 * exponential prob. dist.,
 * uniform prob. dist.,
 * triangular prob. dist.

Additionally, the library includes the function [`randomSample`][randomSample]
which is based on the [rejection sampling][rejection-sampling] method.
It expects a callback of type [`ProbabilityDensity`][ProbabilityDensity]
and can be used to generate random samples that follow
an *arbitrary* probability distribution function.

The program listed below demonstrates how to generated a random sample
and write histogram data to a file.

```Dart
import 'dart:io';

import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) async {
  final mean = 5.0;
  final stdDev = 2.0;
  final sampleSize = 1000;

  // Generating the random sample with 1000 entries.
  final sample = normalSample(sampleSize, mean, stdDev);
  final stats = Stats(sample);

  print(stats.mean);
  print(stats.stdDev);
  print(stats.min);

  // Exporting a histogram.
  await File('normal$sampleSize.hist').writeAsString(
    stats.exportHistogram(
      pdf: (x) => normalPdf(x, mean, stdDev),
      includeStats: true,
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