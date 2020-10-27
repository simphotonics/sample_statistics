import 'package:exception_templates/exception_templates.dart';

/// Exception thrown if an iterable is unexpectedly empty.
///
/// For example when trying to return the min. value of an empty iterable.
class EmptyIterable extends ExceptionType {}
