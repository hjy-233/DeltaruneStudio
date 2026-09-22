import 'package:flutter/material.dart';

class ProjectEditorPanelDivider extends StatelessWidget {
  const ProjectEditorPanelDivider({super.key, required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: const SizedBox(
          width: 12,
          child: Center(child: VerticalDivider(width: 1, thickness: 1)),
        ),
      ),
    );
  }
}
