import 'dart:async';
import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

final class PreviewAudioPlayer {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final Set<AudioPlayer> _soundPlayers = {};

  Future<void> playEvent(StudioReady ready, StudioEvent event) async {
    final assetId = switch (event) {
      AudioPlayBgmEvent(:final assetId) => assetId,
      AudioPlaySoundEvent(:final assetId) => assetId,
      _ => null,
    };
    if (assetId == null || assetId.isEmpty) {
      return;
    }
    final file = _assetFile(ready, assetId);
    if (file == null || !file.existsSync()) {
      debugPrint('Audio file missing for asset: $assetId');
      return;
    }
    switch (event) {
      case AudioPlayBgmEvent():
        await _playBgm(file);
      case AudioPlaySoundEvent():
        await _playSound(file);
      default:
        return;
    }
  }

  Future<void> stopAll() async {
    await _bgmPlayer.stop();
    for (final player in _soundPlayers.toList(growable: false)) {
      await player.stop();
      await player.dispose();
      _soundPlayers.remove(player);
    }
  }

  Future<void> dispose() async {
    await stopAll();
    await _bgmPlayer.dispose();
  }

  File? _assetFile(StudioReady ready, String assetId) {
    final directory = ready.projectDirectory;
    final asset = ready.assetById(assetId);
    if (directory == null || asset == null || asset.kind != AssetKind.audio) {
      return null;
    }
    return File(p.join(directory.path, asset.relativePath));
  }

  Future<void> _playBgm(File file) async {
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setFilePath(file.path);
      await _bgmPlayer.play();
    } on Object catch (error, stackTrace) {
      debugPrint('BGM playback failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _playSound(File file) async {
    final player = AudioPlayer();
    _soundPlayers.add(player);
    try {
      await player.setLoopMode(LoopMode.off);
      await player.setFilePath(file.path);
      unawaited(
        player.playerStateStream
            .firstWhere(
              (state) => state.processingState == ProcessingState.completed,
            )
            .then((_) => _disposeSoundPlayer(player)),
      );
      await player.play();
    } on Object catch (error, stackTrace) {
      debugPrint('Sound playback failed: $error');
      debugPrint('$stackTrace');
      await _disposeSoundPlayer(player);
    }
  }

  Future<void> _disposeSoundPlayer(AudioPlayer player) async {
    if (!_soundPlayers.remove(player)) {
      return;
    }
    await player.dispose();
  }
}
