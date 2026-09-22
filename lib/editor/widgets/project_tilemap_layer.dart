import 'dart:io';

import 'package:deltarune_studio/domain/project_content.dart';
import 'package:flutter/material.dart';

class ProjectTileMapLayer extends StatelessWidget {
  const ProjectTileMapLayer({
    super.key,
    required this.projectPath,
    required this.tileMap,
    required this.scale,
    this.showCollision = true,
  });

  final String projectPath;
  final ProjectTileMap tileMap;
  final double scale;
  final bool showCollision;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [for (final cell in tileMap.cells) _cell(cell)]);
  }

  Widget _cell(ProjectTileCell cell) {
    final width = tileMap.tileWidth * scale;
    final height = tileMap.tileHeight * scale;
    Widget child;
    if (cell.kind == 'collision') {
      child = showCollision
          ? ColoredBox(color: Colors.cyan.withValues(alpha: 0.28))
          : const SizedBox.shrink();
    } else {
      final file = File('$projectPath/${cell.asset}');
      child = file.existsSync()
          ? Image.file(
              file,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            )
          : const ColoredBox(color: Colors.red);
    }
    return Positioned(
      left: cell.column * width,
      top: cell.row * height,
      width: width,
      height: height,
      child: child,
    );
  }
}
