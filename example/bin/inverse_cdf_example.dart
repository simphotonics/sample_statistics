import 'dart:io';
import 'dart:math';

import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:list_operators/list_operators.dart';

double inverseCdf(num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);

final xMin = -10.0;
final xMax = 4.0;

final stdDevMin = (xMax - xMin).abs() / 30;
final stdDevMax = (xMax - xMin).abs() / (2 * sqrt(3));
final sigma = FixedInterval(stdDevMin, stdDevMax, inverseCdf: inverseCdf);
final mu = ParametricInterval(
    () => xMax - 15 * sigma.next(), () => xMin + 15 * sigma.next());
final space = SearchSpace.parametric([sigma, mu]);

Future<void> main(List<String> args) async {
  final sample = List<List<num>>.generate(2000, (_) => space.next());

  await File('../data/search_space.dat').writeAsString(
    sample.export(),
  );
}
