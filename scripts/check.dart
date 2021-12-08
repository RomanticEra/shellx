import 'dart:convert';
import 'dart:io';
import 'package:ansi_styles/ansi_styles.dart';
import 'package:pubspec/pubspec.dart';

class tagModel {
  final String gitTag;
  final PubSpec pubspec;
  final String lossInfo;

  tagModel(this.gitTag, this.pubspec, this.lossInfo);
}

void main(List<String> args) async {
  final scriptPath = Platform.script.path;

  final workspacePath = (scriptPath.split('/')
        ..removeLast()
        ..removeLast())
      .join('/');
  final allIngoreGits = await Directory(workspacePath)
      .list(recursive: true)
      .where((file) => file.path.endsWith('.gitignore'))
      .map((event) => event.parent.path)
      .toList();
  List<String> lossInfos = [];
  await Future.forEach<String>(allIngoreGits, (String gitPath) async {
    final gitTagFuture = Process.run(
      'git',
      ['tag', '-l'],
      workingDirectory: gitPath,
    ).then(
      (value) {
        var tempVar = value.stdout
            .toString()
            .split(ascii.decode([10]))
            .where((element) => element.trim() != '');
        return tempVar.isEmpty ? 'null' : tempVar.last;
      },
    );
    final pubspecFuture = PubSpec.loadFile([gitPath, 'pubspec.yaml'].join('/'));
    final lossInfoFuture = Process.run(
      'git',
      ['status', '-s'],
      workingDirectory: gitPath,
    ).then((value) => value.stdout.toString());

    final model =
        await Future.wait([gitTagFuture, pubspecFuture, lossInfoFuture])
            .then((resp) => tagModel(resp[0], resp[1], resp[2]));

    String outStr;
    if (gitPath != workspacePath) {
      outStr = [
        model.gitTag == 'null' ? '${model.pubspec.name} null' : model.gitTag,
        model.pubspec.version,
      ].join(' ');
    }

    if (model.lossInfo != '') {
      print(AnsiStyles.redBright(outStr));
      lossInfos.add(AnsiStyles.redBright(model.pubspec.name));
      lossInfos.add(model.lossInfo);
    } else {
      print(outStr);
    }
  });
  if (args.contains('-l')) print(lossInfos.join('\n'));
}
