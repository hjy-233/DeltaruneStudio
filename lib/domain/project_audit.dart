import 'project_manifest.dart';

enum ProjectAuditSeverity { info, warning, error }

class ProjectAuditIssue {
  const ProjectAuditIssue({
    required this.severity,
    required this.code,
    required this.subject,
    required this.detail,
  });

  final ProjectAuditSeverity severity;
  final String code;
  final String subject;
  final String detail;
}

class ProjectAuditResult {
  const ProjectAuditResult({required this.references, required this.issues});

  final Map<String, List<String>> references;
  final List<ProjectAuditIssue> issues;

  List<String> referencesFor(String path) => references[path] ?? const [];
}

ProjectAuditResult auditProject(ProjectDocument document) {
  final references = <String, List<String>>{};
  final issues = <ProjectAuditIssue>[];
  final assetPaths = document.assets.map((asset) => asset.path).toSet();

  void reference(String path, String owner) {
    if (path.isEmpty) return;
    references.putIfAbsent(path, () => []).add(owner);
    if (!assetPaths.contains(path)) {
      issues.add(
        ProjectAuditIssue(
          severity: ProjectAuditSeverity.error,
          code: 'missing_resource',
          subject: path,
          detail: owner,
        ),
      );
    }
  }

  for (final room in document.rooms) {
    reference(room.scene.background ?? '', '${room.scene.name} / background');
    for (final cell in room.scene.tileMap.cells) {
      reference(
        cell.asset,
        '${room.scene.name} / tile ${cell.column},${cell.row}',
      );
    }
    for (final object in room.scene.objects) {
      reference(object.asset, '${room.scene.name} / ${object.name}');
      if (object.characterPath.isNotEmpty &&
          !document.characters.any(
            (character) => character.path == object.characterPath,
          )) {
        issues.add(
          ProjectAuditIssue(
            severity: ProjectAuditSeverity.error,
            code: 'missing_character',
            subject: object.characterPath,
            detail: '${room.scene.name} / ${object.name}',
          ),
        );
      }
      if (object.type == 'door') {
        _auditDoor(document, room, object, issues);
      }
    }
  }
  for (final character in document.characters) {
    for (final animation in character.definition.animations) {
      for (final frame in animation.frames) {
        reference(
          frame,
          '${character.definition.name} / ${animation.name} ${animation.direction}',
        );
      }
    }
  }
  for (final prefab in document.prefabs) {
    reference(prefab.object.asset, 'Prefab / ${prefab.name}');
  }
  for (final dialogue in document.dialogues) {
    reference(dialogue.portrait, 'Dialogue / ${dialogue.id} / portrait');
    reference(dialogue.sound, 'Dialogue / ${dialogue.id} / sound');
  }
  for (final asset in document.assets) {
    if (!references.containsKey(asset.path)) {
      issues.add(
        ProjectAuditIssue(
          severity: ProjectAuditSeverity.info,
          code: 'unused_resource',
          subject: asset.path,
          detail: asset.name,
        ),
      );
    }
  }
  return ProjectAuditResult(references: references, issues: issues);
}

void _auditDoor(
  ProjectDocument document,
  ProjectRoom sourceRoom,
  ProjectSceneObject door,
  List<ProjectAuditIssue> issues,
) {
  if (door.targetRoomPath.isEmpty) return;
  ProjectRoom? target;
  for (final room in document.rooms) {
    if (room.path == door.targetRoomPath) target = room;
  }
  if (target == null) {
    issues.add(
      ProjectAuditIssue(
        severity: ProjectAuditSeverity.error,
        code: 'missing_room',
        subject: door.name,
        detail: '${sourceRoom.scene.name} -> ${door.targetRoomPath}',
      ),
    );
    return;
  }
  if (door.targetSpawnId.isNotEmpty &&
      !target.scene.objects.any(
        (object) => object.type == 'spawn' && object.id == door.targetSpawnId,
      )) {
    issues.add(
      ProjectAuditIssue(
        severity: ProjectAuditSeverity.error,
        code: 'missing_spawn',
        subject: door.name,
        detail: '${target.scene.name} / ${door.targetSpawnId}',
      ),
    );
  }
}
