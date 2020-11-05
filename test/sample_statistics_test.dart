import 'package:minimal_test/minimal_test.dart';
import 'package:sample_statistics/sample_statistics.dart';

import 'package:sample_statistics/src/samples/normal_random_sample.dart';

void main(List<String> args) {
  final stats = SampleStats(normalRandomSample);

  group('Basic', () {
    test('min', () {
      expect(stats.min, -1.949079932);
    });
    test('max', () {
      expect(stats.max, 26.55182824);
    });
    test('mean', () {
      expect(stats.mean, 10.168769294545003);
    });
    test('median', () {
      expect(stats.median, 10.232570379999999);
    });
    test('stdDev', () {
      expect(stats.stdDev, 5.370025848202738);
    });
    test('quartile1', () {
      expect(stats.quartile1, 6.1556007975);
    });
    test('quartile3', () {
      expect(stats.quartile3, 14.234971445);
    });
  });

  group('Histogram', () {
    test('Columns', () {
      expect(stats.histogram().length, 3);
      expect(stats.histogram(normalize: false).length, 2);
    });
    test('Number of intervals', () {
      expect(stats.histogram(intervals: 8).first.length, 9);
    });
    test('Range', () {
      final hist = stats.histogram(intervals: 10);
      expect(hist.first.first, stats.min);
      expect(hist.first.last, stats.max);
    });
    test('Normalization', () {
      final numberOfIntervals = 10;
      final hist = stats.histogram(intervals: numberOfIntervals);
      var sum = hist[1].fold<num>(0.0, (sum, current) => sum + current);
      expect(sum * (stats.max - stats.min) / numberOfIntervals, 1.0);
    });
    test('Total count (non-normalized histograms)', () {
      final hist = stats.histogram(normalize: false);
      var sum = hist[1].fold<num>(0.0, (sum, current) => sum + current);
      expect(sum, normalRandomSample.length);
    });
  });

  group('Export Histogram', () {
    final hist = normalRandomSample.exportHistogram();
    test('Data', () {
      expect(
          hist,
          '# Intervals: 9\n'
          '# Min: -1.949079932\n'
          '# Max: 26.55182824\n'
          '# Mean: 10.168769294545003\n'
          '# StdDev: 5.370025848202738\n'
          '# Median: 10.232570379999999\n'
          '# First Quartile: 6.1556007975\n'
          '# Third Quartile: 14.234971445\n'
          '# Interval size: 3.5626135215\n'
          '# Integrated histogram: 1.0000000000000002\n'
          '#\n'
          '# -------------------------------------------------------------\n'
          '#     Range     Prob. Density     Prob. Density Function\n'
          '-1.949079932     0.011227712396700958     0.005823641421806686\n'
          '1.6135335894999998     0.042103921487628586     0.02088281945606896\n'
          '5.176147111     0.05613856198350478     0.048220974466195325\n'
          '8.7387606325     0.07017320247938098     0.07170264436558527\n'
          '12.301374154     0.06175241818185526     0.06865729739404493\n'
          '15.863987675499999     0.02806928099175239     0.04233412392030096\n'
          '19.426601197     0.008420784297525718     0.016809190179090088\n'
          '22.989214718499998     0.0     0.004297890497413179\n'
          '26.55182824     0.0028069280991752394     0.0007076463044876412\n'
          '');
    });
  });
}
