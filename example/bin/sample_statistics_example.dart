import 'package:sample_statistics/sample_statistics.dart';

/// Used to enable/disable color output.
enum ColorOutput { on, off }

/// Ansi color modifier: Reset to default.
const String resetColour = '\u001B[0m';

/// Ansi color modifier: blue foreground.
const String blue = '\u001B[1;94m';

/// Ansi color modifier: cyan foreground.
const String cyan = '\u001B[36m';

/// Ansi color modifier: cyan bold text.
const String cyanBold = '\u001B[1;36m';

/// Ansi color modifier: green foreground.
const String green = '\u001B[1;32m';

/// Ansi color modifier: red foreground.
const String red = '\u001B[31m';

/// Ansi color modifier: yellow foreground.
const String yellow = '\u001B[33m';

/// Ansi color modifier: magenta foreground.
const String magenta = '\u001B[35m';

/// Applies an ansi compliant color modifier to a `String`.
String colorize(
  String message,
  String color, {
  ColorOutput colorOutput = ColorOutput.on,
}) {
  color = (colorOutput == ColorOutput.on) ? color : '';
  final reset = (colorOutput == ColorOutput.on) ? resetColour : '';

  return message = message.isEmpty ? '' : '$color$message$reset';
}

void main() {
  final sample = [-10, 0, 1, 2, 3, 4, 5, 6, 20];
  final stats = Stats(sample);

  print(colorize('\nRunning sample_statistics_example.dart ...', green));

  print(colorize('Sample: ', blue) + sample.toString());

  print(colorize('min: ', magenta) + stats.min.toString());

  print(colorize('max: ', blue) + stats.max.toString());

  print(colorize('mean: ', magenta) + stats.mean.toString());

  print(colorize('median: ', blue) + stats.median.toString());

  print(colorize('first quartile: ', magenta) + stats.quartile1.toString());

  print(colorize('third quartile: ', blue) + stats.quartile3.toString());

  print(colorize('standard deviation: ', magenta) + stats.stdDev.toString());

  sample.removeOutliers();
  print(colorize('outliers:', blue) + sample.toString());

  print(
      colorize('sample with outliers removed: ', magenta) + sample.toString());
}
