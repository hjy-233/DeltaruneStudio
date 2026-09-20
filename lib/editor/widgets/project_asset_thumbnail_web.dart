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
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.image_outlined),
    );
  }
}
