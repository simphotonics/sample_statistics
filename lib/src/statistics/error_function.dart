import 'dart:math' as math;

import 'package:lazy_memo/lazy_memo.dart';

/// Square root of pi.
const sqrtPi = 1.77245385090551602729816748334;

/// Constant: 1.0/(sqrt(pi)).
const invSqrtPi = 1.0 / sqrtPi;

/// Constant: sqrt(2.0*pi).
const sqrt2Pi = math.sqrt2 * sqrtPi;

/// Constant: 1.0/(sqrt(2*pi)).
const invSqrt2Pi = 1.0 / sqrt2Pi;

/// Constant: 1.0/sqrt(2).
const invSqrt2 = 1.0 / math.sqrt2;

/// Error function table. 30-digit precision.
///
/// Source: keisan.casio.com
final erfTable = Map<double, double>.unmodifiable({
  0.0: 0.0,
  0.1: 0.112462916018284892203275071744,
  0.2: 0.2227025892104784541401390068,
  0.3: 0.328626759459127427638914047867,
  0.4: 0.42839235504666845510360384532,
  0.5: 0.520499877813046537682746653892,
  0.6: 0.603856090847925922562622436057,
  0.7: 0.677801193837418472975628809244,
  0.8: 0.742100964707660486167110586503,
  0.9: 0.796908212422832128518724785142,
  1.0: 0.842700792949714869341220635083,
  1.1: 0.880205069574081699771867766322,
  1.2: 0.910313978229635380238405775715,
  1.3: 0.934007944940652436603893327504,
  1.4: 0.952285119762648810516482691533,
  1.5: 0.966105146475310727066976261646,
  1.6: 0.976348383344644007774283447142,
  1.7: 0.983790458590774563626242588122,
  1.8: 0.989090501635730714183732810756,
  1.9: 0.992790429235257469948357539303,
  2.0: 0.995322265018952734162069256367,
  2.1: 0.997020533343667014496114983359,
  2.2: 0.998137153702018108556548243971,
  2.3: 0.998856823402643348534652540619,
  2.4: 0.999311486103354921430255067829,
  2.5: 0.99959304798255504106043578426,
  2.6: 0.999763965583470650796008996792,
  2.7: 0.99986566726005947567085988128,
  2.8: 0.999924986805334540975776754752,
  2.9: 0.999958902121900541164316132511,
  3.0: 0.99997790950300141455862722387,
  3.1: 0.999988351342632800403966293837,
  3.2: 0.999993974238848237905028257637,
  3.3: 0.999996942290203561838538196597,
  3.4: 0.999998478006637137714638242862,
  3.5: 0.999999256901627658587254476316,
  3.6: 0.999999644137006992314701184444,
  3.7: 0.999999832848942090853797625924,
  3.8: 0.999999922996072543035871301802,
  3.9: 0.999999965207751402768257721692,
  4.0: 0.99999998458274209971998114784,
  4.1: 0.999999993299972345915101627273,
  5.0: 0.99999999999846254020557196515,
  8.0: 0.999999999999999999999999999989,
  20.0: 1.0,
});

/// Scaled error function table 30-digit precision.
///
/// Source: keisan.casio.com
final erfxTable = Map<double, double>.unmodifiable({
  0.0: 0.0,
  0.1: 0.113593187115041415610281708259,
  0.2: 0.231791254290807484996328102275,
  0.3: 0.359574949137555215587225058742,
  0.4: 0.502723085697048711689198612424,
  0.5: 0.668335072494815609202627145379,
  0.6: 0.865524697173753303307240617925,
  0.7: 1.10638588260593802904447046079,
  0.8: 1.40738029008183663034361198932,
  0.9: 1.79137633535335437984805181124,
  1.0: 2.29069825230323823094953712686,
  1.1: 2.95175419191252858451461332491,
  1.2: 3.84215840006731310383248071325,
  1.3: 5.06183803604511589990788581897,
  1.4: 6.76058352447689803887207320123,
  1.5: 9.16615041990420821819604645679,
  1.6: 12.6298643232721352063754619543,
  1.7: 17.7016463044749714346454813351,
  1.8: 25.2551616517150851685097365195,
  1.9: 36.6995434411608332766481590259,
  2.0: 54.342754356833733334245172622,
  2.1: 82.024344380856503128308524665,
  2.2: 126.233758766436170456464146343,
  2.3: 198.116683847213620586676194052,
  2.4: 317.129830183313476796293651219,
  2.5: 517.802018304280882359041410171,
  2.6: 862.438582541880475604308002305,
  2.7: 1465.37382307665255092783571845,
  2.8: 2540.01428494713866075826396986,
  2.9: 4491.57590972273188422939897164,
  3.0: 8102.90492642420261775957739462,
  3.1: 14912.9963688639632329048817015,
  3.2: 28000.9571981347103482717800154,
  3.3: 53637.1359627584556207771946138,
  3.4: 104819.853844263792077901716599,
  3.5: 208981.133576057352617398308163,
  3.6: 425065.963516427808782070138549,
  3.7: 882046.304327948222524270671329,
  3.8: 1867292.20924646202491268241649,
  3.9: 4032914.86972210219338118036728,
  4.0: 8886110.38350841501170163385134,
  4.1: 19975158.6757053470521918990341,
  5.0: 72004899337.2751678864282828398,
  8.0: 6235149080811616882909238708.86,
  20.0: 5.22146968976414395058876300665E+173
});

/// Returns an approximation of the error
/// function.
/// * Convergence is guaranteed for: `x.abs() =< 1`.
/// * Maximum error: 1.5e-15.
/// * Sylvain Chevillard. The functions erf and erfc computed with arbitrary
///   precision and explicit errorbounds. Information and Computation,
///   Elsevier, 2012, 216, pp.72 – 95.
///   ensl-00356709v3
double _erfBelow1(num x) {
  var alpha = 2 * x.abs() * invSqrtPi;
  var result = 0.0;
  var y = -x * x;
  final n = 20 + 20 * x.toInt();
  for (var i = 1; i < n; ++i) {
    result += alpha;
    alpha = alpha * y * (2 * i - 1) / (2 * i + 1) / i;
  }
  return x.isNegative ? -(result + alpha) : result + alpha;
}

double _erfxBelow1(num x) => math.exp(x * x) * _erfBelow1(x);

/// Returns an approximation of the scaled error
/// function.
/// * Convergence is quaranteed for `x.abs() >= 1`.
/// * Maximum error: 4.0e-16.
/// * Sylvain Chevillard. The functions erf and erfc computed with arbitrary
///   precision and explicit errorbounds. Information and Computation,
///   Elsevier, 2012, 216, pp.72 – 95.
///   ensl-00356709v3
double _erfxAbove1(num x) {
  var alpha = 2 * x.abs() * invSqrtPi;
  var result = 0.0;
  final y = 2 * x * x;
  final n = 10 + 20 * x.abs().toInt();
  for (var i = 1; i < n; ++i) {
    result += alpha;
    alpha = alpha * y / (2 * i + 1);
  }
  return x.isNegative ? -(result + alpha) : result + alpha;
}

/// Returns an approximation of the error
/// function.
/// * Convergence is quaranteed for `x.abs() >= 1`.
/// * Maximum error: 4.0e-16.
/// * Sylvain Chevillard. The functions erf and erfc computed with arbitrary
///   precision and explicit errorbounds. Information and Computation,
///   Elsevier, 2012, 216, pp.72 – 95.
///   ensl-00356709v3
double _erfAbove1(num x) => _erfxAbove1(x) * math.exp(-x * x);

/// Complementary error function for x.abs() > 5.
double _erfcAbove5(num x) {
  var alpha = 1 / ((x.abs() * sqrtPi));
  var result = 0.0;
  final y = -1.0 / (2 * x * x);
  final iMax = 20;
  for (var i = 0; i < iMax; i++) {
    result += alpha;
    alpha = alpha * y * (2 * i - 1);
  }
  return x.isNegative
      ? 2 - math.exp(-x * x) * (result + alpha)
      : math.exp(-x * x) * (result + alpha);
}

/// Scaled complementary error function for x.abs() > 5.
double _erfcxAbove5(num x) => _erfcAbove5(x) * math.exp(x * x);

/// Returns an approximation of the real
/// valued error function defined as:
/// `erf(x) = 2/sqrt(pi) * integral(from: 0, to: x, exp(-t*t), dt)`
///
/// Compared to the approximation provided by gnuplot the maximum
/// error is `1.5e-15` for `x > 1.0` and  `4.0e-16` for `x in (-1, 1)`.
double _erf(num x) {
  if (x == 0) return 0.0;
  if (x.abs() < 1.0) {
    return _erfBelow1(x);
  } else if (x.abs() < 5.6) {
    return _erfAbove1(x);
  } else {
    return 1.0 - _erfcAbove5(x);
  }
}

double _erfx(num x) {
  if (x == 0) return 0.0;
  if (x.abs() < 1.0) {
    return _erfxBelow1(x);
  } else if (x.abs() < 5.6) {
    return _erfxAbove1(x);
  } else {
    return math.exp(x * x) - _erfcxAbove5(x);
  }
}

double _erfc(num x) {
  if (x == 0) return 1.0;
  if (x.abs() < 1.0) {
    return 1 - _erfBelow1(x);
  } else if (x.abs() < 5.6) {
    return 1 - _erfAbove1(x);
  } else {
    return _erfcAbove5(x);
  }
}

double _erfcx(num x) {
  if (x == 0) return 1.0;
  if (x.abs() < 1.0) {
    return math.exp(x * x) - _erfxBelow1(x);
  } else if (x.abs() < 5.6) {
    return math.exp(x * x) - _erfxAbove1(x);
  } else {
    return _erfcxAbove5(x);
  }
}

/// Returns an approximation of the scaled error function defined as:
///
/// `erfx(x) = exp(x * x) * erf(x)`
final erfx = MemoizedFunction(_erfx);

/// Returns an approximation of the complementary scaled error function
/// defined as:
///
/// `erfcx(x) = exp(x * x) * erfc(x)`
final erfcx = MemoizedFunction(_erfcx);

/// Returns an approximation of error function defined as:
///
/// `erf(x) = 2/sqrt(pi) * integral(from: 0, to: x, exp(-t * t), dt)`
///
/// Compared to the approximation provided by gnuplot the maximum
/// error is `1.5e-15` for `x > 1.0` and  `4.0e-16` for `x in (-1, 1)`.
final erf = MemoizedFunction(_erf);

/// Returns an approximation of complementary error function defined as:
///
/// `erfc(x) = 1.0 - erf(x)`
///
/// Compared to the approximation provided by gnuplot the maximum absolute
/// error is `1.5e-15` for `x > 1.0` and  `4.0e-16` for `x in [1, 1]`.
final erfc = MemoizedFunction(_erfc);

/// Returns the first derivative of the error function.
double dxErf(num x) => 2.0 * invSqrtPi * math.exp(-x * x);
