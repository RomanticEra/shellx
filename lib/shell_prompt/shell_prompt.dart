/// Fully featured shell prompt implementation.
library shell_prompt;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:colorize/colorize.dart';

part 'cursor.dart';
part 'input.dart';
part 'shell.dart';

/// logger interface for test
final logger = StandardLogger();
