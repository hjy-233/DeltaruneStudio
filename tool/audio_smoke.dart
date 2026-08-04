import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const audioPath =
    '/Users/zhuangweiwei/Documents/Deltarune Studio/Demo.drs/assets/audio/'
    'asset_4ec6aef0-8012-490f-859a-baf45871a43e_snd_joker_chaos.wav';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AudioSmokeApp());
}

final class AudioSmokeApp extends StatefulWidget {
  const AudioSmokeApp({super.key});

  @override
  State<AudioSmokeApp> createState() => _AudioSmokeAppState();
}

final class _AudioSmokeAppState extends State<AudioSmokeApp> {
  final AudioPlayer _player = AudioPlayer();
  var _status = 'Starting...';

  @override
  void initState() {
    super.initState();
    unawaited(_play());
  }

  Future<void> _play() async {
    try {
      final file = File(audioPath);
      _log('exists=${file.existsSync()} path=$audioPath');
      final duration = await _player.setFilePath(audioPath);
      _log('loaded duration=$duration');
      await _player.play();
      _log('play returned state=${_player.playerState}');
    } on Object catch (error, stackTrace) {
      _log('failed: $error\n$stackTrace');
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[audio_smoke] $message');
    if (mounted) {
      setState(() => _status = message);
    }
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_status),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => unawaited(_play()),
                  child: const Text('Play test sound'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
