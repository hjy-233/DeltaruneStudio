import 'dart:io';

import 'package:flutter/material.dart';

class ProjectAssetThumbnail extends StatelessWidget {
  const ProjectAssetThumbnail({
    super.key,
    required this.path,
    this.width = 42,
    this.height = 42,
  });

  final String path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image_outlined);
    }
    return Image.file(
      file,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}
