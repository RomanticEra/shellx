// ignore_for_file: prefer_const_constructors
import 'package:romantic_common/romantic_common.dart';
import 'package:shellx_core/shell_prompt/shell_prompt.dart';
import 'package:test/test.dart';

void main() {
  group('[ShellxCore][Cursor]', () {
    test('Cursor.moveLeft', () {
      final cursor = Cursor();
      logger = TestLogger();
      cursor.moveLeft(2);
      expect(cursor.position, -2);
      expect((logger as TestLogger).output, '\b\b');
    });
    test('Cursor.moveRight', () {
      final cursor = Cursor();
      logger = TestLogger();
      cursor.moveRight(2);
      expect(cursor.position, 1);
      expect((logger as TestLogger).output, '\x1b\x5b\x43');
    });
    test('Cursor.delete', () {
      final cursor = Cursor();
      logger = TestLogger();
      cursor.delete(2);
      expect(cursor.position, -1);
      expect((logger as TestLogger).output, '\b \b');
    });
    test('Cursor.handleKey', () {
      final cursor = Cursor();
      final flag = cursor.handleKey([98, 99, 100], 'sh');
      expect(flag, false);
    });
    test('Cursor.handleKey[Delete]', () {
      final cursor = Cursor();
      logger = TestLogger();
      cursor.handleKey([127], 'sh');
      expect((logger as TestLogger).output, '\b \b');
      // expect(flag, false);
    });
  });
}
