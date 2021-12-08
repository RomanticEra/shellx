import 'package:args/command_runner.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<int>('shellx_core', 'A Core tool for Command-line Shell with listening stdin')
      // ..addCommand(CreateCommand())
      ;
  await runner.run(args);
}
