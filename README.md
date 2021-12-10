<!-- This file uses generated code. Visit https://pub.dev/packages/readme_helper for usage information. -->
# shellx_core

[![build: status][actions_badge]][actions_link] [![pub package][pub_badge]][pub_link]
[![style: analysis][analysis_badge]][analysis_link]
[![License: MIT][license_badge]][license_link]

A Core tool for Command-line Shell with listening stdin

[actions_badge]: https://github.com/huang12zheng/shellx_core/actions/workflows/main.yaml/badge.svg
[actions_link]: https://github.com/huang12zheng/shellx_core/actions/workflows/main.yaml
[pub_badge]:https://img.shields.io/pub/v/shellx_core.svg
[pub_link]:https://pub.dartlang.org/packages/shellx_core
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[analysis_badge]: https://img.shields.io/badge/style-romantic__analysis-purple
[analysis_link]: https://github.com/RomanticEra/romantic_analysis

Extend from [kafka-shell](https://github.com/pulyaevskiy/kafka-shell)

<!-- #include example/README.md -->
```dart
import 'dart:async';

import 'package:melos/melos.dart';
import 'package:shellx_core/shellx_core.dart';
import 'package:universal_io/io.dart';

Future<void> main(List<String> args) async {
  final config = await MelosWorkspaceConfig.fromDirectory(Directory.current);
  Shell()
    ..fromMelos(config.scripts.keys)
    ..run();
}

// Map.fromIterables(scripts, scripts.map((e) => MelosCommand(e)));

extension MeolsShell on Shell {
  void fromMelos(Iterable<String> scripts) => scripts.forEach(addMelos);
  void addMelos(String element) => addCommand(element, MelosCommand(element));
}

```

<!-- // end of #include -->
