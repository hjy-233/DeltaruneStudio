import 'dart:io';

import 'package:deltarune_studio/data/project_repository.dart';
import 'package:deltarune_studio/domain/project_settings.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/godot/godot_build_service.dart';
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
      source = source.copyWith(
        manifest: source.manifest.copyWith(
          gameSettings: const ProjectGameSettings(
            viewportWidth: 320,
            viewportHeight: 240,
            windowWidth: 1280,
            windowHeight: 960,
            startFullscreen: true,
          ),
          exportSettings: const ProjectExportSettings(
            bundleIdentifier: 'studio.deltarune.sample',
            version: '2.0.0',
          ),
        ),
      );
      expect(Directory('${source.path}/.build').existsSync(), isFalse);

      final result = await GodotBuildService().prepare(source);

      expect(File('${result.directory}/project.godot').existsSync(), isTrue);
      expect(
        await File('${result.directory}/project.godot').readAsString(),
        contains('config/name="Sample Game"'),
      );
      final projectSettings = await File(
        '${result.directory}/project.godot',
      ).readAsString();
      expect(projectSettings, contains('window/size/viewport_width=320'));
      expect(projectSettings, contains('window/size/mode=3'));
      expect(File('${result.directory}/runtime/main.gd').existsSync(), isTrue);
      expect(File('${result.directory}/runtime/drs.gd').existsSync(), isTrue);
      expect(
        File('${result.directory}/runtime/debug_overlay.gd').existsSync(),
        isTrue,
      );
      expect(
        File('${result.directory}/runtime/variable_debugger.gd').existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/runtime/project_content_runtime.gd',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('${result.directory}/export_presets.cfg').existsSync(),
        isTrue,
      );
      expect(
        await File('${result.directory}/export_presets.cfg').readAsString(),
        contains('application/bundle_identifier="studio.deltarune.sample"'),
      );
      expect(
        await File('${result.directory}/export_presets.cfg').readAsString(),
        contains('include_filter="*.json,*.png'),
      );
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
      expect(
        File(
          '${result.directory}/runtime/save_point/save_point_0.png',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/runtime/save_point/save_point_1.png',
        ).existsSync(),
        isTrue,
      );
      for (var frame = 2; frame < 6; frame++) {
        expect(
          File(
            '${result.directory}/runtime/save_point/save_point_$frame.png',
          ).existsSync(),
          isTrue,
        );
      }
      expect(
        await File(
          '${result.directory}/runtime/project_content_runtime.gd',
        ).readAsString(),
        contains('AnimatedSprite2D.new()'),
      );
      final runtimeApi = await File(
        '${result.directory}/runtime/drs.gd',
      ).readAsString();
      final runtimeMain = await File(
        '${result.directory}/runtime/main.gd',
      ).readAsString();
      expect(runtimeMain, contains('"width": _view_size.x'));
      expect(runtimeMain, contains('"height": _view_size.y'));
      expect(runtimeApi, contains('ResourceLoader.exists(resource_path)'));
      expect(runtimeMain, contains('character.position = _rect_center(spawn)'));
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
        'save_game',
        'load_game',
        'has_save',
        'delete_save',
        'create_save_point',
        'dialogue',
        'refresh_scene_interactables',
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
      expect(runtimeMain, contains('drs_hot_reload_current_room'));
      expect(runtimeMain, contains('add_tile_map(scene_data, room_root)'));
      final edited = source.copyWith(
        mainScene: source.mainScene.copyWith(
          objects: const [
            ProjectSceneObject(
              id: 'hot_reload_prop',
              type: 'prop',
              name: 'Hot reload prop',
              asset: '',
              x: 120,
              y: 90,
              zIndex: 1,
            ),
          ],
        ),
      );
      await repository.save(edited);
      expect(await GodotBuildService().syncHotReload(edited), isTrue);
      expect(
        File('${result.directory}/drs_project/.hot_reload').existsSync(),
        isTrue,
      );
      expect(
        await File(
          '${result.directory}/drs_project/scenes/main/scene.json',
        ).readAsString(),
        contains('hot_reload_prop'),
      );
    },
  );

  test('export preflight reports packaged and unsupported files', () async {
    final parent = await Directory.systemTemp.createTemp('drs_preflight_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final document = await repository.create(
      parentPath: parent.path,
      name: 'Preflight Test',
    );
    final unsupported = File('${document.path}/resources/props/data.psd');
    await unsupported.writeAsBytes([1, 2, 3]);
    final reopened = await repository.open(document.path);

    final report = await GodotBuildService().preflight(reopened);

    expect(report.files.map((file) => file.path), contains('project.godot'));
    expect(report.unsupportedFiles, contains('resources/props/data.psd'));
    expect(
      report.files.map((file) => file.path),
      isNot(contains('drs_project/resources/props/data.psd')),
    );
    expect(report.totalBytes, greaterThan(0));
  });
}
