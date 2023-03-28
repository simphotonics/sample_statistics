import 'package:sample_statistics/sample_statistics.dart';

void main(List<String> args) async {
  final xMin = 2.0;
  final xMax = 7.0;
  final stdDevOfParent = 2.0;
  final meanOfParent = 4.0;

  final meanTr = meanTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent);
  final stdDevTr =
      stdDevTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent);

  print(
      'Mean of Parent: $meanOfParent, Standard Dev. of Parent: $stdDevOfParent');
  print('Truncated normal: mean: $meanTr, stdDev: $stdDevTr');
  print('----------------');

  print(await truncatedNormalToNormal(xMin, xMax, meanTr, stdDevTr));
}
