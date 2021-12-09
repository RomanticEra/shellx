// ignore_for_file: public_member_api_docs

part of shell_prompt;

void doNull() {}

class Cursor {
  int position = 0;
  void Function() _onDelete = doNull;

  void moveLeft(int count) {
    var _count = count;
    while (_count > 0) {
      logger.write('\b');
      position--;
      _count--;
    }
  }

  void moveRight(int count) {
    logger.write('\x1b\x5b\x43');
    position++;
  }

  void delete(int count) {
    logger.write('\b \b');
    position--;
  }

  bool handleKey(List<int> input, String currentText) =>
      _handleDelete(input, currentText);
  void Function() get onDelete => throw Exception('Do use inner prop');
  set onDelete(void Function() onDelete) => _onDelete = onDelete;

  bool _handleDelete(List<int> input, String currentText) {
    if (input.length == 1 && input[0] == 127) {
      if (currentText.isEmpty) {
        return true;
      }

      logger.write('\b \b');
      _onDelete();
      return true;
    } else {
      return false;
    }
  }
}
