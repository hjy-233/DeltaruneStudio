import 'dart:async';

import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/domain/project_character.dart';
import 'package:flutter/material.dart';

import 'project_asset_thumbnail.dart';

class ProjectAnimationPreview extends StatefulWidget {
  const ProjectAnimationPreview({
    super.key,
    required this.projectPath,
    required this.animation,
  });

  final String projectPath;
  final ProjectCharacterAnimation animation;

  @override
  State<ProjectAnimationPreview> createState() =>
      _ProjectAnimationPreviewState();
}

class _ProjectAnimationPreviewState extends State<ProjectAnimationPreview> {
  Timer? _timer;
  int _frame = 0;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant ProjectAnimationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _frame = _frame.clamp(0, _lastFrame);
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _lastFrame =>
      widget.animation.frames.isEmpty ? 0 : widget.animation.frames.length - 1;

  void _restartTimer() {
    _timer?.cancel();
    if (!_playing || widget.animation.frames.length < 2) {
      return;
    }
    final milliseconds = (1000 / widget.animation.fps.clamp(1, 60)).round();
    _timer = Timer.periodic(Duration(milliseconds: milliseconds), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_frame >= _lastFrame && !widget.animation.loop) {
          _playing = false;
          _timer?.cancel();
          return;
        }
        _frame = (_frame + 1) % widget.animation.frames.length;
      });
    });
  }

  void _togglePlayback() {
    setState(() {
      _playing = !_playing;
      if (_playing && _frame >= _lastFrame) {
        _frame = 0;
      }
    });
    _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final frames = widget.animation.frames;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Center(
                child: frames.isEmpty
                    ? const Icon(Icons.image_not_supported_outlined)
                    : ProjectAssetThumbnail(
                        key: ValueKey(frames[_frame]),
                        path: '${widget.projectPath}/${frames[_frame]}',
                        width: 88,
                        height: 88,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: _playing ? l10n.pausePreview : l10n.playPreview,
              onPressed: frames.isEmpty ? null : _togglePlayback,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            Expanded(
              child: Text(
                '${l10n.animationPreview}\n${frames.isEmpty ? 0 : _frame + 1}/${frames.length}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
