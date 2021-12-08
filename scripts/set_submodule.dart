// import 'dart:async';
// import 'dart:io';
// import 'package:logger/logger.dart';
// import 'package:path/path.dart';
// import 'package:romantic_common/romantic_common.dart';

// // TODO: git submodule sync
// // TODO: rm .git/modules/{MOD_NAME}的缓存
// void main(List<String> args) async {
//   await Workspace().patch();
// }

// final keyConfigPath = '.bak';
// final keySubModule = '$keyConfigPath/submodule.json';
// final logger = Logger();

// class Workspace {
//   final String workspacePath;

//   String get targetPath => [workspacePath, keySubModule].join('/');

//   Workspace()
//       : workspacePath = (Platform.script.path.split('/')
//               ..removeLast()
//               ..removeLast())
//             .join('/');
//   List<String> _allIngoreGits;
//   Future<List<String>> get allGitsFuture async =>
//       _allIngoreGits ??= await Directory(workspacePath)
//           .list(recursive: true)
//           .where((file) => file.path.endsWith('.gitignore'))
//           .map((event) => event.parent.path)
//           .toList();
//   Future<List<String>> get allPackagesGitsFuture async => (await allGitsFuture)
//       .where((e) => e.indexOf('/packages/') != -1)
//       .toList();
//   Future<List<String>> get subModulesWithLocalPathFuture =>
//       allPackagesGitsFuture.then((value) => value
//           .where(
//             (path) => !Directory('path/.git').existsSync(),
//           )
//           .toList());
//   Future<List<String>> get nosubModulesFuture =>
//       allPackagesGitsFuture.then((value) => value
//           .where(
//             (path) => Directory('path/.git').existsSync(),
//           )
//           .toList());
//   Map<String, dynamic> get configData => targetPath.getFileWithJsonSync;

//   void patch() async {
//     // Map<String, dynamic> data = configData;

//     SubModuleState state = await SubModuleState.fromWorkspace(this);
//     final patchProcess = GitProcess(this, state);
//     final patched = await patchProcess.runAddSubModule();
//     // print(patched);

//     // print(state.patch);
//     SubModuleState patchedState = state.getUnionState(patched);
//     // print(patchedState.subModule);

//     // if (patchedState.patch.isNotEmpty) {
//     if (patchedState.subModule.isNotEmpty) {
//       patchedState.save(targetPath);
//       return;
//     }
//     final subtractProcess = GitProcess(this, patchedState);
//     final subtractPatched = await subtractProcess.runSubtractSubModule();

//     SubModuleState finalState = patchedState.getDifferentState(subtractPatched);
//     finalState.save(targetPath);
//   }
// }

// class SubModuleState {
//   final Set<String> remoteSet;
//   final Set<String> subModule;
//   final Set<String> subModuleBak;

//   SubModuleState(this.remoteSet, this.subModule, this.subModuleBak);

//   static fromWorkspace(Workspace workspace) async {
//     final remoteList = await _getRemotesWithLocalPath(
//         await workspace.subModulesWithLocalPathFuture);

//     Map<String, dynamic> data = workspace.configData;

//     final subModule = (data['subModule'] as List).toStringList;
//     final subModuleBak = (data['subModuleBak'] as List).toStringList;
//     return SubModuleState.fromList(remoteList, subModule, subModuleBak);
//   }

//   static Future<List<String>> _getRemotesWithLocalPath(
//       List<String> subModules) async {
//     final List<String> remoteList = [];
//     await Future.forEach<String>(subModules, (element) async {
//       var result = await Process.run(
//           'sh', ['-c', "git remote -v|grep fetch|awk '{print \$2}'"],
//           workingDirectory: element);
//       remoteList.add(result.stdout.toString().trim());
//     });
//     return remoteList;
//   }

//   factory SubModuleState.fromList(List<String> remoteList,
//       List<String> subModule, List<String> subModuleBak) {
//     return SubModuleState(
//         remoteList.toSet(), subModule.toSet(), subModuleBak.toSet());
//   }
//   // A`=A-B-R
//   // B`B+A'
//   SubModuleState getUnionState(Set<String> patched) {
//     final wrongPatch = patch.difference(patched);
//     return SubModuleState(
//       remoteSet.union(patched),
//       patch.difference(patched),
//       subModuleBak.union(subModule.difference(wrongPatch)),
//     );
//   }

//   SubModuleState getDifferentState(Set<String> patched) {
//     return SubModuleState(
//       remoteSet.difference(patched),
//       subModule, // {}
//       subModuleBak,
//     );
//   }

//   Set<String> get configPatch => subModule.difference(subModuleBak);
//   Set<String> get patch => configPatch.difference(remoteSet);

//   void save(String configPath) {
//     Map<String, List<String>> data = {};
//     data['subModule'] = subModule.toList();
//     data['subModuleBak'] = subModuleBak.toList();
//     data.write2File(configPath);
//   }
// }

// class GitProcess {
//   final Workspace workspace;
//   final SubModuleState state;

//   GitProcess(this.workspace, this.state);

//   /// A-B-R
//   Future<Set<String>> runAddSubModule() =>
//       _runAdd(workspace.workspacePath, state.patch);

//   Future<Set<String>> _runAdd(String workspacePath, Set<String> patch) async {
//     Set<String> pateded = {};
//     if (patch.isNotEmpty) {
//       print('would add some submodule as follow:');
//       patch.forEach((url) {
//         print('git submodule add $url');
//       });
//       var checkInput = prompt('Is Continue?(Y/N)');

//       if (checkInput.toLowerCase() == 'y') {
//         await Future.forEach<String>(patch, (element) async {
//           var result = await Process.run('git', ['submodule', 'add', element],
//               workingDirectory: [workspacePath, 'packages'].join('/'));
//           if (result.exitCode != 0) {
//             print(result.stderr);
//             final exitcode = await _runSubModuleUpdate(
//                 workspacePath, basenameWithoutExtension(element));
//             if (exitcode != 0) {
//               print('--------------');
//               print(result.stderr);
//               print(result.exitCode);
//               checkInput = prompt('Is Continue?(Y/N)');
//               if (checkInput.toLowerCase() == 'n') return pateded;
//             }
//           }
//           // result = await Process.run(
//           //     'git', ['commit', '-m', 'Add Submodule $element'],
//           //     workingDirectory: [workspacePath, 'packages'].join('/'));

//           /// R+(A-B-R)
//           pateded.add(element);
//         });
//       }
//     }
//     return pateded;
//   }

//   Future<int> _runSubModuleUpdate(String workspacePath, String basename) async {
//     print('git submodule update');
//     final checkInput = prompt('Is Continue?(Y/N)');
//     var result;
//     if (checkInput.toLowerCase() == 'y') {
//       result = await Process.run(
//           'sh',
//           [
//             '-c',
//             // 'git submodule init packages/$basename'
//             'git submodule update packages/$basename',
//           ],
//           // result = await Process.run('git', ['submodule', 'update', element],
//           workingDirectory: [workspacePath].join('/'));
//       // if (result.exitCode != 0) {
//       //   print('--------------');
//       //   print(result.exitCode);
//       //   print(result.stderr);
//       // }
//     }
//     return result.exitCode;
//   }

//   Future<Set<String>> runSubtractSubModule() =>
//       _runSubtract(state.remoteSet.difference(state.subModuleBak));

//   Future<Set<String>> _runSubtract(Set<String> patch) async {
//     Set<String> pateded = {};
//     await Future.forEach<String>(patch, (element) async {
//       final moduleName = basenameWithoutExtension(element);
//       ProcessResult result;
//       result =
//           await Process.run('git', ['status', '-s'], workingDirectory: element);
//       if (result.exitCode != 0 || result.stdout.toString().trim() != '') {
//         // throw Exception(result.stdout.toString());
//         print(result.stderr);
//         return pateded;
//       }
//       print('git submodule deinit -f $moduleName '
//           // 'git rm --cached $moduleName && '
//           // ' && git rm $moduleName '
//           // ' && git commit -m "Remove submodule $moduleName"',
//           );
//       final checkInput = prompt('Is Continue?(Y/N)');

//       if (checkInput.toLowerCase() == 'y') {
//         /// command with packages
//         result = await Process.run(
//           'sh',
//           [
//             '-c',
//             'git submodule deinit -f packages/$moduleName'
//             // '&& git rm packages/$moduleName'
//             // '&& git commit -m "Remove submodule packages/$moduleName"'
//           ],
//           workingDirectory: workspace.workspacePath,
//         );
//         if (result.exitCode != 0) {
//           print(result.stderr);
//           return pateded;
//         }
//         pateded.add(element);
//       }
//     });
//     return pateded;
//   }
// }

// class DoSubModule extends Workspace {
//   DoSubModule() : super();
// }

// // extension A on String{

// // }

// String prompt(String message) {
//   stdout.write('$message');
//   return stdin.readLineSync() ?? '';
// }
