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

      final repository = ProjectRepository();
      var source = await repository.create(
        parentPath: temporaryDirectory.path,
        name: 'Sample Game',
      );
      source = await repository.addCharacter(source, 'Kris');
      expect(Directory('${source.path}/.build').existsSync(), isFalse);

      final result = await GodotBuildService().prepare(source);

      expect(File('${result.directory}/project.godot').existsSync(), isTrue);
      expect(File('${result.directory}/runtime/main.gd').existsSync(), isTrue);
      expect(File('${result.directory}/runtime/drs.gd').existsSync(), isTrue);
      expect(
        File(
          '${result.directory}/runtime/dialogue/light_world.png',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/runtime/dialogue/dark_world.png',
        ).existsSync(),
        isTrue,
      );
      final runtimeApi = await File(
        '${result.directory}/runtime/drs.gd',
      ).readAsString();
      for (final method in [
        'enable_player_control',
        'set_expression',
        'follow',
        'camera_follow',
        'camera_shake',
        'register_interactable',
        'set_door_enabled',
        'say_dark',
        'say_portrait',
        'choice',
        'set_flag',
        'set_value',
        'show_image',
        'flash',
        'crossfade_bgm',
        'play_sound_at',
      ]) {
        expect(runtimeApi, contains('func $method'));
      }
      expect(
        File('${result.directory}/drs_project/project.json').existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/drs_project/characters/kris/character.json',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/drs_project/scripts/manual/main.gd',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('${source.path}/scenes/main/scene.json').existsSync(),
        isTrue,
      );
    },
  );
}
