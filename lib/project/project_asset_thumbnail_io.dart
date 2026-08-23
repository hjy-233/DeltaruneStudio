import 'dart:io';

import 'package:flutter/material.dart';

class ProjectAssetThumbnail extends StatelessWidget {
  const ProjectAssetThumbnail({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image_outlined);
    }
    return Image.file(
      file,
      width: 42,
      height: 42,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}
