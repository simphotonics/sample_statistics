import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) {
  final sample = [
    -10,
    -8,
    -5,
    -4,
    -3,
    -3,
    -1,
    -1,
    -1,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    1,
    2,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    7,
    10,
    14,
  ];

  final stats = Stats(sample);

  final intervals = 8;

  print(
    stats.exportHistogram(
      verbose: true,
      normalize: false,
      intervals: intervals,
    ),
  );
  print(
    stats.blockHistogram(
      intervals: intervals,
      indent: '//   ',
      infoOption: HistogramInfoOption.showMinMax
      ,
    ),
  );
}
