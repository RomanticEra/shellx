import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pubspec/pubspec.dart';

class TagModel {
  final String gitTag;
  final PubSpec pubspec;
  final String lossInfo;

  TagModel(this.gitTag, this.pubspec, this.lossInfo);
}

void main(List<String> args) async {
  final instance = GitPackages();
  await instance.template(instance.stratery0);
}

class GitPackages {
  String workspacePath;
  GitPackages() {
    workspacePath = (Platform.script.path.split('/')
          ..removeLast()
          ..removeLast())
        .join('/');
  }
  List<String> _allIngoreGits;
  FutureOr<List<String>> get allGitsFuture async =>
      _allIngoreGits ??= await Directory(workspacePath)
          .list(recursive: true)
          .where((file) => file.path.endsWith('.gitignore'))
          .map((event) => event.parent.path)
          .toList();

  template(Function(String, TagModel) callback) async {
    await Future.forEach<String>(await allGitsFuture, (String gitPath) async {
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
      final pubspecFuture =
          PubSpec.loadFile([gitPath, 'pubspec.yaml'].join('/'));
      final lossInfoFuture = Process.run(
        'git',
        ['status', '-s'],
        workingDirectory: gitPath,
      ).then((value) => value.stdout.toString());

      final model =
          await Future.wait([gitTagFuture, pubspecFuture, lossInfoFuture])
              .then((resp) => TagModel(resp[0], resp[1], resp[2]));
      await callback(gitPath, model);
    });
  }

  stratery0(String gitPath, TagModel model) async {
    if (gitPath != workspacePath) {
      if (model.gitTag.endsWith(model.pubspec.version.toString()) &&
          model.gitTag != 'null') {
        await Process.run(
          'git',
          ['tag', '-d', model.gitTag],
          workingDirectory: gitPath,
        ).catchError((e) => throw e);
        await Process.run(
          'git',
          ['tag', '-a', model.gitTag, '-m', model.gitTag],
          workingDirectory: gitPath,
        ).catchError((e) => throw e);
      }
    }
  }
}
