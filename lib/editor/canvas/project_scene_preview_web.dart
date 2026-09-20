import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:flutter/material.dart';

class ProjectScenePreview extends StatelessWidget {
  const ProjectScenePreview({super.key, required this.document});

  final ProjectDocument document;

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: Text('Scene preview is available on desktop.')),
    );
  }
}
