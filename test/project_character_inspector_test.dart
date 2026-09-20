import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/panels/project_character_inspector.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('animation frames are added through an explicit menu button', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 1200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const animation = ProjectCharacterAnimation(
      id: 'walk-down',
      name: 'walk',
      direction: 'down',
    );
    const character = ProjectCharacterFile(
      path: 'characters/kris/character.json',
      definition: ProjectCharacterDefinition(
        id: 'kris',
        name: 'Kris',
        animations: [animation],
      ),
    );
    const document = ProjectDocument(
      manifest: ProjectManifest(
        formatVersion: 2,
        id: 'test',
        name: 'Test',
        mainScene: 'scenes/main/scene.json',
      ),
      mainScene: ProjectScene(id: 'main', name: 'Main'),
      path: '/missing',
      assets: [
        ProjectAsset(
          path: 'resources/characters/walk_0.png',
          name: 'walk_0.png',
          type: 'characters',
        ),
      ],
      characters: [character],
    );
    ProjectCharacterFile? updated;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 900,
            child: ProjectCharacterInspector(
              document: document,
              character: character,
              onChanged: (value) => updated = value,
              onDelete: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    final addFrameButton = find.byKey(const ValueKey('walk-down:addFrame'));
    expect(addFrameButton, findsOneWidget);
    expect(tester.widget<OutlinedButton>(addFrameButton).onPressed, isNotNull);

    await tester.ensureVisible(addFrameButton);
    await tester.pumpAndSettle();
    await tester.tap(addFrameButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('walk_0.png'));
    await tester.pumpAndSettle();

    expect(updated?.definition.animations.single.frames, [
      'resources/characters/walk_0.png',
    ]);
  });
}
