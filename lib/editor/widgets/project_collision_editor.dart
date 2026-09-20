import 'dart:math' as math;

import 'package:deltarune_studio/domain/project_character.dart';
import 'package:flutter/material.dart';

class ProjectCollisionEditor extends StatelessWidget {
  const ProjectCollisionEditor({
    super.key,
    required this.character,
    required this.onChanged,
  });

  final ProjectCharacterDefinition character;
  final ValueChanged<ProjectCollisionBox> onChanged;

  @override
  Widget build(BuildContext context) {
    const canvasSize = Size(240, 180);
    final scale = math.min(
      canvasSize.width / math.max(character.defaultWidth * 2, 80),
      canvasSize.height / math.max(character.defaultHeight * 2, 80),
    );
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final collision = character.collision;
    final left = center.dx + collision.x * scale;
    final top = center.dy + collision.y * scale;
    return Center(
      child: SizedBox.fromSize(
        size: canvasSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Stack(
            children: [
              Positioned(
                left: center.dx - character.defaultWidth * scale / 2,
                top: center.dy - character.defaultHeight * scale / 2,
                width: character.defaultWidth * scale,
                height: character.defaultHeight * scale,
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.15)),
              ),
              Positioned(
                left: left,
                top: top,
                width: math.max(collision.width * scale, 8),
                height: math.max(collision.height * scale, 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: (details) => onChanged(
                          collision.copyWith(
                            x: collision.x + details.delta.dx / scale,
                            y: collision.y + details.delta.dy / scale,
                          ),
                        ),
                        child: Container(
                          color: Colors.cyan.withValues(alpha: 0.25),
                          foregroundDecoration: BoxDecoration(
                            border: Border.all(color: Colors.cyan, width: 2),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -5,
                      bottom: -5,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeDownRight,
                        child: GestureDetector(
                          onPanUpdate: (details) => onChanged(
                            collision.copyWith(
                              width: math.max(
                                1,
                                collision.width + details.delta.dx / scale,
                              ),
                              height: math.max(
                                1,
                                collision.height + details.delta.dy / scale,
                              ),
                            ),
                          ),
                          child: Container(
                            width: 11,
                            height: 11,
                            color: Colors.cyan,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
