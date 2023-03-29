import 'dart:io';
import 'dart:math';

import 'package:exception_templates/exception_templates.dart';
import 'package:sample_statistics/sample_statistics.dart';
import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:list_operators/list_operators.dart';

final num sigma0 = 0.1;
final num xMin = -2;
final num xMax = 6;
final num meanOfParent = 2.0;
final num stdDevOfParent = 4.0;
final meanTr = meanTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent);
final stdDevTr =
    stdDevTruncatedNormal(xMin, xMax, meanOfParent, stdDevOfParent);

num inverseCdf(num p, num xMin, num xMax) {
  return xMin + (xMax - xMin) * sqrt(p);
}

final sigma = FixedInterval(
  sigma0,
  stdDevTr * 10,
  //inverseCdf: inverseCdf,
);
final mu = ParametricInterval(
  () => xMin - 6.75 * sigma.next(),
  () => xMax + 6.75 * sigma.next(),
);
//final mu = FixedInterval(0, 8);

final space = SearchSpace.parametric([sigma, mu]
    //dxMax: [1, 4*sigma0]
    );

num _energy(List<num> x) {
  final result = log(
      pow(meanTr - meanTruncatedNormal(xMin, xMax, x[1], x[0]), 2) +
          pow(stdDevTr - stdDevTruncatedNormal(xMin, xMax, x[1], x[0]), 2));
  if (result.isNaN || result.isInfinite) {
    print('Energy is nan');
  }
  return result;
}

final field = EnergyField(_energy, space);

final simulator = LoggingSimulator(
  field,
  gammaStart: 0.7,
  gammaEnd: 0.1,
  outerIterations: 150,
  sampleSize: 650,
);

/// To run this program navigate to the folder: examples/bin and use the
/// command:
/// ```Console
/// $ dart truncated_normal_params_example.dart
/// ```
Future<void> main(List<String> args) async {
  simulator.deltaPositionEnd = [1e-4, 1e-4];
  simulator.deltaPositionStart = [1, 3];
  simulator.startPosition = [stdDevTr, meanTr];

  print(simulator);
  print(await simulator.info);

  final tStart = await simulator.tStart;

  if (tStart.isNaN) {
    print(tStart);
    throw ErrorOf<Simulator>(message: 'tStart == $tStart');
  }

  final fieldSample = List<List<num>>.generate(10000, (_) {
    field.next();
    final result = field.position;
    return result..add(field.value);
  });

  await File('example/data/fieldPerturb.dat')
      .writeAsString(fieldSample.export());

  print('Starting annealing process ...');

  final result = await simulator.anneal(
    isRecursive: true,
    ratio: 0.5,
  );

  final stdDevOfParentEst = result[0];
  final meanOfParentEst = result[1];

  await File('example/data/log.dat').writeAsString(simulator.export());

  final report = <String, num>{
    'meanOfParentEst': meanOfParentEst,
    'stdDevOfParentEst': stdDevOfParentEst,
    'meanError': meanOfParent - meanOfParentEst,
    'stdDevError': stdDevOfParent - stdDevOfParentEst,
    'meanOfParent': meanOfParent,
    'stdDevOfParent': stdDevOfParent,
  };

  print(report);
}
