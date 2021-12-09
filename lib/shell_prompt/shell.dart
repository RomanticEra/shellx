part of shell_prompt;

/// Interface for [Command]
abstract class ShellCommand<T> {
  /// a execute of [Command.run]
  FutureOr<T> execute(List<String> args, Logger output);

  // String signature();

  /// help
  void writeHelp(Logger output);

  /// Called whenever user requests autocomplete. Must return list of possible
  /// options.
  Future<List<AutocompleteOption>> autocomplete(List<String> args);
}

/// Enterpoint of this library
class Shell {
  /// construct
  Shell({ShellPrompt? prompt}) {
    _input = ShellInput(onSubmit, prompt: prompt);
    _input.onAutocomplete = onAutocomplete;
  }

  /// dict about [ShellCommand]
  final Map<String, ShellCommand> commands = {};

  late ShellInput _input;

  /// get autocomplete on commands
  Future<List<AutocompleteOption>> onAutocomplete(String input) async {
    final options = <AutocompleteOption>[];
    for (final command in commands.values) {
      final sublist = await command.autocomplete(_getArgs(input));
      options.addAll(sublist);
    }
    return options;
  }

  List<String> _getArgs(String input) {
    final list = input.trim().split(' ').toList();
    return list..removeWhere((s) => s.isEmpty);
  }

  /// resovler command-key to command
  /// run [ShellCommand.execute]
  FutureOr<void> onSubmit(String value) {
    if (value.isNotEmpty) {
      final list = _getArgs(value);
      final cmd = list.first.trim();
      if (commands.containsKey(cmd)) {
        commands[cmd]!.execute(_getArgs(value), logger);
      } else {
        final err = Colorize('ERR: No such command.')..red();
        logger.writeln(err);
      }
    }
  }

  // ignore: public_member_api_docs
  void addCommand(String name, ShellCommand command) {
    commands[name] = command;
  }

  StreamSubscription<List<int>>? _inputSubscription;

  // ignore: public_member_api_docs
  // ignore: prefer_expression_function_bodies,public_member_api_docs
  StreamSubscription<List<int>> run() {
    // _inputSubscription = _input.listen();
    // return _inputSubscription;
    // return _inputSubscription.asFuture();
    return _input.listen();
  }

  // ignore: public_member_api_docs
  void cancel() {
    _inputSubscription?.cancel();
  }
}
