import 'package:deltarune_studio/app/deltarune_studio_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: DeltaruneStudioApp()));
}
