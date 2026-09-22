import 'package:flutter/material.dart';

class ProjectSavePointIcon extends StatelessWidget {
  const ProjectSavePointIcon({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'runtime/godot_template/runtime/save_point/save_point_0.png',
      width: 20 * scale,
      height: 19 * scale,
      filterQuality: FilterQuality.none,
    );
  }
}
