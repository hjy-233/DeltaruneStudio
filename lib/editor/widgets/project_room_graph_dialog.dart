import 'dart:math' as math;

import 'package:deltarune_studio/domain/project_audit.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ProjectRoomGraphDialog extends StatelessWidget {
  const ProjectRoomGraphDialog({
    super.key,
    required this.document,
    required this.onRoomSelected,
  });

  final ProjectDocument document;
  final ValueChanged<String> onRoomSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strings = ProjectFeatureStrings.of(context);
    final audit = auditProject(document);
    final roomIssues = audit.issues
        .where(
          (issue) =>
              issue.code == 'missing_room' || issue.code == 'missing_spawn',
        )
        .toList(growable: false);
    return AlertDialog(
      title: Text(strings.roomGraph),
      content: SizedBox(
        width: 820,
        height: 560,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = _RoomGraphLayout.create(
                    document,
                    Size(constraints.maxWidth, constraints.maxHeight),
                  );
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RoomGraphPainter(document, layout),
                        ),
                      ),
                      for (final room in document.rooms)
                        _roomNode(context, room, layout.positions[room.path]!),
                    ],
                  );
                },
              ),
            ),
            if (roomIssues.isNotEmpty) ...[
              const Divider(),
              SizedBox(
                height: 100,
                child: ListView(
                  children: [
                    for (final issue in roomIssues)
                      ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.error_outline,
                          color: Colors.orange,
                        ),
                        title: Text(_issueLabel(strings, issue.code)),
                        subtitle: Text('${issue.subject}: ${issue.detail}'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.ok),
        ),
      ],
    );
  }

  Widget _roomNode(BuildContext context, ProjectRoom room, Offset position) {
    final isMain = room.path == document.manifest.mainScene;
    return Positioned(
      left: position.dx,
      top: position.dy,
      width: _RoomGraphLayout.nodeWidth,
      height: _RoomGraphLayout.nodeHeight,
      child: Material(
        color: isMain
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            Navigator.pop(context);
            onRoomSelected(room.path);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  room.scene.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  room.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _issueLabel(ProjectFeatureStrings strings, String code) {
    return code == 'missing_spawn' ? strings.missingSpawn : strings.missingRoom;
  }
}

class _RoomGraphLayout {
  const _RoomGraphLayout(this.positions);

  static const nodeWidth = 170.0;
  static const nodeHeight = 68.0;
  final Map<String, Offset> positions;

  factory _RoomGraphLayout.create(ProjectDocument document, Size size) {
    final count = math.max(document.rooms.length, 1);
    final columns = math.max(1, math.sqrt(count).ceil());
    final rows = (count / columns).ceil();
    final horizontalGap = math.max(
      30.0,
      (size.width - columns * nodeWidth) / (columns + 1),
    );
    final verticalGap = math.max(
      28.0,
      (size.height - rows * nodeHeight) / (rows + 1),
    );
    final positions = <String, Offset>{};
    for (var index = 0; index < document.rooms.length; index++) {
      final column = index % columns;
      final row = index ~/ columns;
      positions[document.rooms[index].path] = Offset(
        horizontalGap + column * (nodeWidth + horizontalGap),
        verticalGap + row * (nodeHeight + verticalGap),
      );
    }
    return _RoomGraphLayout(positions);
  }
}

class _RoomGraphPainter extends CustomPainter {
  const _RoomGraphPainter(this.document, this.layout);

  final ProjectDocument document;
  final _RoomGraphLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final normal = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    final broken = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2;
    for (final room in document.rooms) {
      final from = layout.positions[room.path];
      if (from == null) continue;
      for (final door in room.scene.objects.where(
        (item) => item.type == 'door',
      )) {
        if (door.targetRoomPath.isEmpty) continue;
        final target = layout.positions[door.targetRoomPath];
        final start =
            from +
            const Offset(
              _RoomGraphLayout.nodeWidth / 2,
              _RoomGraphLayout.nodeHeight / 2,
            );
        if (target == null) {
          canvas.drawLine(start, start + const Offset(32, -24), broken);
          continue;
        }
        final end =
            target +
            const Offset(
              _RoomGraphLayout.nodeWidth / 2,
              _RoomGraphLayout.nodeHeight / 2,
            );
        canvas.drawLine(start, end, normal);
        final direction = end - start;
        if (direction.distance > 1) {
          final unit = direction / direction.distance;
          final tip = end - unit * (_RoomGraphLayout.nodeWidth / 2 + 3);
          final side = Offset(-unit.dy, unit.dx);
          final path = Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo(
              (tip - unit * 12 + side * 6).dx,
              (tip - unit * 12 + side * 6).dy,
            )
            ..lineTo(
              (tip - unit * 12 - side * 6).dx,
              (tip - unit * 12 - side * 6).dy,
            )
            ..close();
          canvas.drawPath(path, normal);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoomGraphPainter oldDelegate) =>
      oldDelegate.document != document || oldDelegate.layout != layout;
}
