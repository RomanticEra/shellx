/// Fully featured shell prompt implementation.
library shell_prompt;

import 'dart:async';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:colorize/colorize.dart';
import 'package:universal_io/io.dart';

part 'cursor.dart';
part 'input.dart';
part 'shell.dart';

/// logger interface for test
StandardLogger logger = StandardLogger();

/// ada
extension Writeln on Logger {
  /// add
  // @override
  void writeln(Object message) {
    write('$message\n');
  }
}
