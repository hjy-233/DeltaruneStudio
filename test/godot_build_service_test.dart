import 'dart:io';

import 'package:deltarune_studio/project/godot_build_service.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'prepares a generated Godot project without changing the source layout',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'deltarune-studio-godot-',
      );
      addTearDown(() => temporaryDirectory.delete(recursive: true));

      final source = await ProjectRepository().create(
        parentPath: temporaryDirectory.path,
        name: 'Sample Game',
      );
      expect(Directory('${source.path}/.build').existsSync(), isFalse);

      final result = await GodotBuildService().prepare(source);

      expect(File('${result.directory}/project.godot').existsSync(), isTrue);
      expect(File('${result.directory}/runtime/main.gd').existsSync(), isTrue);
      expect(
        File('${result.directory}/drs_project/project.json').existsSync(),
        isTrue,
      );
      expect(
        File('${source.path}/scenes/main/scene.json').existsSync(),
        isTrue,
      );
    },
  );
}
