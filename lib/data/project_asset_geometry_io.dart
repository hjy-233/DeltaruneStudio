import 'dart:io';
import 'dart:ui' as ui;

import 'package:deltarune_studio/domain/project_character.dart';

Future<ProjectCollisionBox?> readOpaqueCollisionBox(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;
    var left = image.width;
    var top = image.height;
    var right = -1;
    var bottom = -1;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (data.getUint8((y * image.width + x) * 4 + 3) == 0) continue;
        if (x < left) left = x;
        if (x > right) right = x;
        if (y < top) top = y;
        if (y > bottom) bottom = y;
      }
    }
    final box = right < left || bottom < top
        ? ProjectCollisionBox(
            x: -image.width / 2,
            y: -image.height / 2,
            width: image.width.toDouble(),
            height: image.height.toDouble(),
          )
        : ProjectCollisionBox(
            x: left - image.width / 2,
            y: top - image.height / 2,
            width: (right - left + 1).toDouble(),
            height: (bottom - top + 1).toDouble(),
          );
    image.dispose();
    codec.dispose();
    return box;
  } on Object {
    return null;
  }
}
