import 'package:deltarune_studio/domain/project_audit.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports missing, unused, and broken door references', () {
    const used = 'resources/props/sign.png';
    const unused = 'resources/props/unused.png';
    const room = ProjectRoom(
      path: 'scenes/main/scene.json',
      scene: ProjectScene(
        id: 'main',
        name: 'Main',
        objects: [
          ProjectSceneObject(
            id: 'sign',
            type: 'prop',
            name: 'Sign',
            asset: used,
            x: 10,
            y: 20,
            zIndex: 0,
          ),
          ProjectSceneObject(
            id: 'door',
            type: 'door',
            name: 'Broken Door',
            asset: '',
            x: 30,
            y: 40,
            zIndex: 1,
            targetRoomPath: 'scenes/missing/room.json',
          ),
        ],
      ),
    );
    final document = ProjectDocument(
      manifest: ProjectManifest(
        formatVersion: 2,
        id: 'test',
        name: 'Test',
        mainScene: 'scenes/main/scene.json',
      ),
      mainScene: room.scene,
      path: '/tmp/test',
      rooms: [room],
      assets: [
        ProjectAsset(path: used, name: 'sign.png', type: 'props'),
        ProjectAsset(path: unused, name: 'unused.png', type: 'props'),
      ],
    );

    final result = auditProject(document);

    expect(result.referencesFor(used), contains('Main / Sign'));
    expect(
      result.issues.map((issue) => issue.code),
      contains('unused_resource'),
    );
    expect(result.issues.map((issue) => issue.code), contains('missing_room'));
  });
}
