import 'dart:io';

import 'package:flutter/material.dart';

import 'project_manifest.dart';

class ProjectScenePreview extends StatelessWidget {
  const ProjectScenePreview({super.key, required this.document});

  final ProjectDocument document;

  @override
  Widget build(BuildContext context) {
    final scene = document.mainScene;
    final objects = [...scene.objects]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ColoredBox(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / 640;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (scene.background != null)
                  Positioned.fill(
                    child: _assetImage(document.path, scene.background!),
                  ),
                for (final object in objects)
                  Positioned(
                    left: object.x * scale,
                    top: object.y * scale,
                    child: Transform.translate(
                      offset: Offset(-16 * scale, -24 * scale),
                      child: _PreviewObject(
                        object: object,
                        rootPath: document.path,
                        scale: scale,
                      ),
                    ),
                  ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Text(
                    scene.name,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _assetImage(String rootPath, String relativePath) {
    final file = File('$rootPath/$relativePath');
    if (!file.existsSync()) {
      return const Center(
        child: Text('Missing scene asset', style: TextStyle(color: Colors.red)),
      );
    }
    return Image.file(
      file,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
    );
  }
}

class _PreviewObject extends StatelessWidget {
  const _PreviewObject({
    required this.object,
    required this.rootPath,
    required this.scale,
  });

  final ProjectSceneObject object;
  final String rootPath;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final file = File('$rootPath/${object.asset}');
    if (!file.existsSync()) {
      return Text(
        object.name,
        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
      );
    }
    return Transform.scale(
      scale: scale,
      alignment: Alignment.topLeft,
      child: Image.file(file, filterQuality: FilterQuality.none),
    );
  }
}
