import 'package:deltarune_studio/app/deltarune_studio_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
  }
  runApp(const ProviderScope(child: DeltaruneStudioApp()));
}
