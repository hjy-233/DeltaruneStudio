import 'dart:async';
import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  Future<void> playAssetId(
    StudioReady ready,
    BuiltInAssetLibrary? builtIns,
    String assetId,
  ) async {
    if (assetId.isEmpty) {
      return;
    }
    final source = await _audioSourceForAssetId(ready, builtIns, assetId);
    if (source == null) {
      debugPrint('Audio source missing for asset: $assetId');
      return;
    }
    await _playSoundSource(source);
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
    await _playSoundSource(AudioSource.file(file.path));
  }

  Future<void> _playSoundSource(AudioSource source) async {
    final player = AudioPlayer();
    _soundPlayers.add(player);
    try {
      await player.setLoopMode(LoopMode.off);
      await player.setAudioSource(source);
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

  Future<AudioSource?> _audioSourceForAssetId(
    StudioReady ready,
    BuiltInAssetLibrary? builtIns,
    String assetId,
  ) async {
    final asset = ready.assetById(assetId);
    if (asset != null && asset.kind == AssetKind.audio) {
      final dataUri = asset.dataUri;
      if (dataUri != null && dataUri.isNotEmpty) {
        return AudioSource.uri(Uri.parse(dataUri));
      }
      final directory = ready.projectDirectory;
      if (directory != null) {
        final file = File(p.join(directory.path, asset.relativePath));
        if (await file.exists()) {
          return AudioSource.file(file.path);
        }
      }
    }
    final builtIn = builtIns?.assets.firstWhere(
      (item) => item.id == assetId && item.kind == AssetKind.audio,
      orElse: () => const BuiltInAsset(
        id: '',
        name: '',
        kind: AssetKind.audio,
        assetPath: '',
        sourcePath: '',
        resolvedPath: '',
      ),
    );
    if (builtIn == null || builtIn.id.isEmpty) {
      return null;
    }
    if (!kIsWeb) {
      final file = File(builtIn.resolvedPath);
      if (await file.exists()) {
        return AudioSource.file(file.path);
      }
    }
    try {
      await rootBundle.load(builtIn.assetPath);
      return AudioSource.asset(builtIn.assetPath);
    } on Object {
      return null;
    }
  }

  Future<void> _disposeSoundPlayer(AudioPlayer player) async {
    if (!_soundPlayers.remove(player)) {
      return;
    }
    await player.dispose();
  }
}
