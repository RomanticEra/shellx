// ignore_for_file: prefer_const_constructors
import 'dart:async';

import 'package:shellx_core/shell_prompt/shell_prompt.dart';

void main() {
  ShellInput(onSubmit, prompt: basicShellPrompt(r'$ ')).listen();
}

FutureOr<int> onSubmit(String value) {
  logger.write(value);
  return 0;
}
