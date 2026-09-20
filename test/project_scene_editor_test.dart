import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/canvas/project_scene_editor.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('canvas uses the same object anchors as the Godot runtime', (
    tester,
  ) async {
    const character = ProjectSceneObject(
      id: 'character',
      type: 'character',
      name: 'Character',
      asset: 'missing.png',
      x: 320,
      y: 240,
      zIndex: 0,
      width: 32,
      height: 48,
    );
    const door = ProjectSceneObject(
      id: 'door',
      type: 'door',
      name: 'Door',
      asset: '',
      x: 100,
      y: 120,
      zIndex: 1,
      width: 32,
      height: 48,
    );
    const document = ProjectDocument(
      manifest: ProjectManifest(
        formatVersion: 2,
        id: 'test',
        name: 'Test',
        mainScene: 'scenes/main/scene.json',
      ),
      mainScene: ProjectScene(
        id: 'main',
        name: 'Main',
        objects: [character, door],
      ),
      path: '/missing',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            height: 700,
            child: ProjectSceneEditor(
              document: document,
              onChanged: (_) {},
              onSelectionChanged: (_) {},
              inspectorWidth: 360,
              onInspectorWidthChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final characterAnchor = tester.widget<FractionalTranslation>(
      find.byKey(const ValueKey('scene-object-character-anchor')),
    );
    final doorAnchor = tester.widget<FractionalTranslation>(
      find.byKey(const ValueKey('scene-object-door-anchor')),
    );

    expect(characterAnchor.translation, const Offset(-0.5, -0.5));
    expect(doorAnchor.translation, Offset.zero);
  });
}
