import 'package:flutter/material.dart';

class ProjectAssetThumbnail extends StatelessWidget {
  const ProjectAssetThumbnail({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.image_outlined);
  }
}
