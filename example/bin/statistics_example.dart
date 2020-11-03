import 'package:sample_statistics/sample_statistics.dart';

/// Used to enable/disable color output.
enum ColorOutput { ON, OFF }

/// Ansi color modifier: Reset to default.
const String RESET = '\u001B[0m';

/// Ansi color modifier: blue foreground.
const String BLUE = '\u001B[1;94m';

/// Ansi color modifier: cyan foreground.
const String CYAN = '\u001B[36m';

/// Ansi color modifier: cyan bold text.
const String CYAN_BOLD = '\u001B[1;36m';

/// Ansi color modifier: green foreground.
const String GREEN = '\u001B[1;32m';

/// Ansi color modifier: red foreground.
const String RED = '\u001B[31m';

/// Ansi color modifier: yellow foreground.
const String YELLOW = '\u001B[33m';

/// Ansi color modifier: magenta foreground.
const String MAGENTA = '\u001B[35m';

/// Applies an ansi compliant color modifier to a `String`.
String colorize(
  String message,
  String color, {
  ColorOutput colorOutput = ColorOutput.ON,
}) {
  color = (colorOutput == ColorOutput.ON) ? color : '';
  final reset = (colorOutput == ColorOutput.ON) ? RESET : '';

  return message = message.isEmpty ? '' : '$color$message$reset';
}

void main() {
  final sample = <num>[-10, 0, 1, 2, 3, 4, 5, 6, 20];
  final stats = SampleStats(sample);

  print(colorize('\nRunning statistic_example.dart ...', GREEN));

  print(colorize('Sample: ', BLUE) + sample.toString());

  print(colorize('min: ', MAGENTA) + stats.min.toString());

  print(colorize('max: ', BLUE) + stats.max.toString());

  print(colorize('mean: ', MAGENTA) + stats.mean.toString());

  print(colorize('median: ', BLUE) + stats.median.toString());

  print(colorize('first quartile: ', MAGENTA) + stats.quartile1.toString());

  print(colorize('third quartile: ', BLUE) + stats.quartile3.toString());

  print(colorize('standard deviation: ', MAGENTA) + stats.stdDev.toString());

  final outliers = sample.removeOutliers();
  print(colorize('outliers:', BLUE) + outliers.toString());

  print(
      colorize('sample with outliers removed: ', MAGENTA) + sample.toString());



}
