/// Includes an approximation of the error function and an iteration function
/// based on the trapezoidal rule.
library utility_functions;

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

/// Error function table.
final erfTable = Map<double, double>.unmodifiable({
  0.0: 0.0,
  0.1: 0.1124629160182848922033,
  0.2: 0.2227025892104784541401,
  0.3: 0.3286267594591274276389,
  0.4: 0.4283923550466684551036,
  0.5: 0.5204998778130465376828,
  0.6: 0.6038560908479259225626,
  0.7: 0.6778011938374184729756,
  0.8: 0.7421009647076604861671,
  0.9: 0.7969082124228321285187,
  1.0: 0.8427007929497148693412,
  1.1: 0.8802050695740816997719,
  1.2: 0.9103139782296353802384,
  1.3: 0.9340079449406524366039,
  1.4: 0.9522851197626488105165,
  1.5: 0.96610514647531072706697,
  1.6: 0.9763483833446440077743,
  1.7: 0.9837904585907745636262,
  1.8: 0.9890905016357307141837,
  1.9: 0.9927904292352574699484,
  2.0: 0.9953222650189527341621,
  2.1: 0.9970205333436670144961,
  2.2: 0.9981371537020181085566,
  2.3: 0.9988568234026433485347,
  2.4: 0.9993114861033549214303,
  2.5: 0.9995930479825550410604,
  2.6: 0.9997639655834706507960,
  2.7: 0.9998656672600594756709,
  2.8: 0.9999249868053345409758,
  2.9: 0.9999589021219005411643,
  3.0: 0.9999779095030014145586,
  3.1: 0.99998835134263280040397,
  3.2: 0.99999397423884823790502,
  3.3: 0.9999969422902035618385,
  3.4: 0.9999984780066371377146,
  3.5: 0.99999925690162765858725,
  3.6: 0.9999996441370069923147,
  3.7: 0.9999998328489420908538,
  3.8: 0.9999999229960725430359,
  3.9: 0.9999999652077514027683,
  4.0: 0.99999998458274209971998115,
  4.1: 0.99999999329997234591510163,
});

/// Returns the polynominal defined by
/// the coefficients `a`:
/// `a[0] + a[1] * x + ... + a[n-1] * pow(x, n - 1)`.
///
/// Recursive function based on Horner's rule.
num polynomial(num x, Iterable<num> a) {
  if (a.isEmpty) return 0;
  return a.first + x * polynomial(x, a.skip(1));
}

/// Returns an approximation of the error
/// function.
/// * Convergence is guaranteed for: `x.abs() =< 1`.
/// * Maximum error: 1.5e-15.
/// * Sylvain Chevillard. The functions erf and erfc computed with arbitrary
///   precision and explicit errorbounds. Information and Computation,
///   Elsevier, 2012, 216, pp.72 – 95.
///   ensl-00356709v3
num _erfBelow1(num x) {
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

/// Returns an approximation of the error
/// function.
/// * Convergence is quaranteed for `x.abs() >= 1`.
/// * Maximum error: 4.0e-16.
/// * Sylvain Chevillard. The functions erf and erfc computed with arbitrary
///   precision and explicit errorbounds. Information and Computation,
///   Elsevier, 2012, 216, pp.72 – 95.
///   ensl-00356709v3
num _erfAbove1(num x) {
  var alpha = 2 * x.abs() * invSqrtPi * math.exp(-x * x);
  var result = 0.0;
  var y = 2 * x * x;

  final n = 10 + 20 * x.abs().toInt();

  for (var i = 1; i < n; ++i) {
    result += alpha;
    alpha = alpha * y / (2 * i + 1);
  }
  return x.isNegative ? -(result + alpha) : result + alpha;
}

/// Returns an approximation of the real
/// valued error function defined as:
/// `erf(x) = 2/sqrt(pi) * integral(from: 0, to: x, exp(-t*t), dt)`
///
/// Compared to the approximation provided by gnuplot the maximum
/// error is `1.5e-15` for `x > 1.0` and  `4.0e-16` for `x in (-1, 1)`.
num _erf(num x) {
  if (x == 0) return 0.0;
  if (x.abs() < 1.0) {
    return _erfBelow1(x);
  } else if (x.abs() < 8) {
    return _erfAbove1(x);
  } else {
    return x.isNegative ? -1.0 + 1.0e-28 : 1.0 - 1.0e-28;
  }
}

/// Returns an approximation of the real
/// valued error function defined as:
/// `erf(x) = 2/sqrt(pi) * integral(from: 0, to: x, exp(-t*t), dt)`
///
/// Compared to the approximation provided by gnuplot the maximum
/// error is `1.5e-15` for `x > 1.0` and  `4.0e-16` for `x in (-1, 1)`.
final erf = MemoizedFunction(_erf);

/// Returns the definite integral of `func` over the interval
/// (`lowerLimit`,`upperLimit`) using the
/// trapezoidal approximation.
///
/// Depending on the function the integral might
/// not be defined and convergence is not guaranteed for `dxMax -> 0`.
///
/// The maximum number of integration sub-intervals is `10000`.
num integrate(
  num Function(num x) func,
  num lowerLimit,
  num upperLimit, {
  double dxMax = 0.1,
}) {
  dxMax = dxMax.abs();
  final interval = upperLimit - lowerLimit;

  var n0 = (interval.abs() / dxMax).ceil();
  n0 = (n0 > 100000) ? 100000 : n0;
  final n = (n0 < 10) ? 10 : n0;

  // Integration sub-interval:
  final dx = interval / n;

  var integral = 0.5 * (func(lowerLimit) + func(upperLimit));
  for (var i = 1; i < n; ++i) {
    integral += func(lowerLimit + i * dx);
  }
  return integral * dx;
}

/// Returns the first derivative of the error function.
num dxErf(num x) => 2.0 * invSqrtPi * math.pow(math.e, -x * x);
