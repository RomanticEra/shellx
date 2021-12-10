// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:shellx_core/shell_prompt/shell_prompt.dart';
// import 'package:universal_io/io.dart';

void main() {
  ShellInput(onSubmit, prompt: basicShellPrompt(r'$ ')).listen();
}

Future<void> onSubmit(String value) async {
  logger.write(value);
  // return 0;
}
