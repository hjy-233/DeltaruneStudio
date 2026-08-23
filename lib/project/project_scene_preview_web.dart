import 'package:flutter/material.dart';

import 'project_manifest.dart';

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
