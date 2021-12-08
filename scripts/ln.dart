import 'dart:io';

void main() async {
  // final dir = Directory.current;
  final scriptPath = Platform.script.path;
  final projectDirPath = (scriptPath.split('/')
        ..removeLast()
        ..removeLast())
      .join('/');
  final lnList = [
    '/Users/huangzheng/RomanticEra/romantic_common',
    '/Users/huangzheng/RomanticEra/romantic_analysis',
    '/Users/huangzheng/RomanticEra/romantic_fake',
    '/Users/huangzheng/masonx',
  ];
  // print(dir.absolute);
  for (final item in lnList) {
    final packageName = item.split('/').last;
    final targetPath = [projectDirPath, 'packages', packageName].join('/');
    final ProcessResult result =
        await Process.run('git submodule add', [item, targetPath]);
    print([packageName + ':', result.exitCode, result.stderr].join(' '));
    // print(['ln', '-s', item, targetPath]);
  }
}
