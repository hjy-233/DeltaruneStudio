import 'package:flutter/material.dart';

import 'project_manifest.dart';

class ProjectSceneEditor extends StatelessWidget {
  const ProjectSceneEditor({
    super.key,
    required this.document,
    required this.onChanged,
  });

  final ProjectDocument document;
  final ValueChanged<ProjectScene> onChanged;

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 4 / 3,
      child: ColoredBox(
        color: Colors.black,
        child: Center(child: Text('Scene editing is available on desktop.')),
      ),
    );
  }
}
