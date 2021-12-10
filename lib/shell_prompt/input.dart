part of shell_prompt;

// ignore: public_member_api_docs
typedef ShellInputSubmit = FutureOr<void> Function(String value);

// ignore: public_member_api_docs
typedef ShellInputAutocomplete = Future<List<AutocompleteOption>> Function(
  String input,
);

/// Interface for Prompt On Shell
typedef ShellPrompt = void Function(StandardLogger);

/// basic Prompt On Shell
ShellPrompt basicShellPrompt(String text) => (output) => output.write(text);

/// Option for autocomplete functionality.
class AutocompleteOption {
  /// consturct
  AutocompleteOption(this.label, this.value);

  /// [label] will be shown in the list of possible options.
  final String label;

  /// [value] must contain full command string. When user selects any options
  /// `value` is used to completely replace
  /// whatever input contained at the moment.
  final String value;
}

/// encapsulation history for [ShellInput._handleUpArrow] and
/// [ShellInput._handleDownArrow]
class InputHistory {
  /// history command
  final List<String> history = [];
  // String originStr = '';

  /// count of you press UpArrow
  int diffIndex = 0;

  /// edge safe up
  void up() {
    if (diffIndex < history.length) diffIndex++;
  }

  /// edge safe down
  void down() {
    if (diffIndex > 1) diffIndex--;
  }

  /// add value to history
  void add(String value) {
    if (value.trim() != '' && !history.contains(value)) history.add(value);
  }

  /// simple to get value
  String get value => history[history.length - diffIndex];
}

/// ShellInput implements typical behavior for input field in CLI.
class ShellInput {
  /// construct
  ShellInput(this.onSubmit, {ShellPrompt? prompt}) {
    if (prompt == null) {
      this.prompt = basicShellPrompt(r'$ ');
    } else {
      this.prompt = prompt;
    }

    stdin.echoMode = false;
    stdin.lineMode = false;

    _handlers = <String, ShellInputSubmit>{
      '\x1b\x5b\x43': _handleRightArrow,
      '\x1b\x5b\x44': _handleLeftArrow,
      '\x1b\x5b\x41': _handleUpArrow,
      '\x1b\x5b\x42': _handleDownArrow,
      '\x7f': _handleDelete,
      '\x09': _handleTab,
      '\n': _handleReturn
    };
  }
  // ignore: public_member_api_docs
  late ShellPrompt prompt;
  // ignore: public_member_api_docs
  final ShellInputSubmit onSubmit;
  // ignore: public_member_api_docs
  ShellInputAutocomplete? onAutocomplete;
  // ignore: public_member_api_docs
  final Cursor cursor = Cursor();
  String _value = '';

  final InputHistory _history = InputHistory();

  late Map<String, ShellInputSubmit> _handlers;

  bool _submitInProgress = false;

  /// listen stdin
  StreamSubscription<List<int>> listen() {
    _printPrompt();
    final sub = stdin.asBroadcastStream().listen(
      (_) async {
        if (_submitInProgress) return;

        String str;
        try {
          str = ascii.decode(_);
        } on FormatException {
          str = utf8.decode(_);
        }

        if (_handlers.containsKey(str)) {
          final res = _handlers[str]!(str);
          if (res is Future) {
            await res;
          }
          return;
        } else if (str.contains('\x1b')) {
          // print(_);
        } else {
          // print(_);
          _handleInsert(str);
        }
      },
      cancelOnError: true,
    );

    return sub;
  }

  void _printPrompt() {
    prompt(logger);
  }

  Future<void> _handleReturn(String key) async {
    logger.write(key);
    try {
      _submitInProgress = true;
      final result = onSubmit(_value);

      if (result is Future) {
        await result;
      }
      _printPrompt();
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } catch (e) {
    } finally {
      _submitInProgress = false;
      _history.add(_value);
      _value = '';
      cursor.position = 0;
    }
  }

  void _beep() {
    logger.write(String.fromCharCodes([0x07]));
  }

  Future<void> _handleTab(String key) async {
    if (onAutocomplete == null) {
      _beep();
      return;
    }
    final options = await onAutocomplete!(_value);
    if (options.isEmpty) {
      _beep();
      return;
    }

    if (options.length == 1) {
      cursor.moveLeft(_value.length);
      _value = '${options.first.value} ';
      logger.write(_value);
      cursor.position = _value.length;
    } else {
      // TODO(hz): show options on second <tab>.
      _beep();
    }
  }

  void _handleInsert(String key) {
    if (cursor.position == _value.length) {
      _value += key;
      cursor.position += key.length;
      logger.write(key);
    } else if (cursor.position < _value.length) {
      final rightSide = _value.substring(cursor.position);
      final toWrite = key + rightSide;
      _value = _value.substring(0, cursor.position) + toWrite;
      logger.write(toWrite);
      // cursor.moveLeft(toWrite.length - 1);
      cursor
        ..position = _value.length
        ..moveLeft(rightSide.length);
    }
  }

  void _handleRightArrow(String key) {
    if (cursor.position < _value.length) {
      cursor.moveRight(1);
    }
  }

  void _handleLeftArrow(String key) {
    if (cursor.position > 0) {
      cursor.moveLeft(1);
    }
  }

  void _handleUpArrow(String key) {
    if (_history.history.isEmpty) return;
    cursor.newLine(_value.length);
    _history.up();
    // print(_history.diffIndex);
    _value = _history.value;
    logger.write(_value);
    cursor.position = _value.length;
  }

  void _handleDownArrow(String key) {
    if (_history.history.isEmpty) return;
    cursor.newLine(_value.length);
    _history.down();
    // print(_history.diffIndex);
    _value = _history.value;
    logger.write(_value);
    cursor.position = _value.length;
  }

  void _handleDelete(String key) {
    if (_value.isEmpty || cursor.position == 0) {
      return;
    }

    if (cursor.position == _value.length) {
      _value = _value.substring(0, _value.length - 1);
      cursor.delete(1);
    } else if (cursor.position < _value.length) {
      final toWrite = _value.substring(cursor.position);
      _value = _value.substring(0, cursor.position - 1) + toWrite;
      cursor.moveLeft(1);
      logger.write('$toWrite ');
      cursor
        ..position = _value.length + 1
        ..moveLeft(toWrite.length + 1);
    }
  }
}