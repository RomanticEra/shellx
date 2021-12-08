import 'dart:io';

void main() async {
  final scriptPath = Platform.script.path;

  final workspacePath = (scriptPath.split('/')
        ..removeLast()
        ..removeLast())
      .join('/');
  final allGits = await Directory(workspacePath)
      .list(recursive: true)
      .where((file) => file is Directory && file.path.endsWith('.git'))
      .map((event) => event.parent.path)
      // ignore workspace
      .where((event) => event != workspacePath)
      .toList();
  print(allGits.join('\n'));
}
