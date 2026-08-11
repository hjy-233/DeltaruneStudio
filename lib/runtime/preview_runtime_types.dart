part of 'preview_controller.dart';

final class TimelineSpan {
  const TimelineSpan({
    required this.event,
    required this.start,
    required this.end,
  });

  final StudioEvent event;
  final double start;
  final double end;

  double get duration => math.max(0.1, end - start);
}

final class TimelineAudioCue {
  const TimelineAudioCue({required this.event, required this.time});

  final StudioEvent event;
  final double time;
}

final class TimelineDialogueTypeCue {
  const TimelineDialogueTypeCue({required this.assetId, required this.time});

  final String assetId;
  final double time;
}

final class DoorDestination {
  const DoorDestination(this.x, this.y);

  final double x;
  final double y;
}

final class PathSample {
  const PathSample({
    required this.x,
    required this.y,
    required this.distance,
    required this.direction,
  });

  final double x;
  final double y;
  final double distance;
  final Direction direction;
}

final class FollowPosition {
  const FollowPosition({
    required this.x,
    required this.y,
    required this.direction,
    required this.isMoving,
  });

  final double x;
  final double y;
  final Direction direction;
  final bool isMoving;
}

final class RectLike {
  const RectLike(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  RectLike inflate(double amount) {
    return RectLike(
      left - amount,
      top - amount,
      width + amount * 2,
      height + amount * 2,
    );
  }

  bool contains(double x, double y) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }
}

sealed class PreviewState {
  const PreviewState();

  const factory PreviewState.stopped() = PreviewStopped;
  const factory PreviewState.playing({
    required RuntimeWorld world,
    bool cleanPreview,
  }) = PreviewPlaying;
  const factory PreviewState.paused({
    required RuntimeWorld world,
    bool cleanPreview,
  }) = PreviewPaused;

  RuntimeWorld? get world => switch (this) {
    PreviewStopped() => null,
    PreviewPlaying(:final world) => world,
    PreviewPaused(:final world) => world,
  };

  bool get isPlaying => this is PreviewPlaying;

  bool get cleanPreview => switch (this) {
    PreviewStopped() => false,
    PreviewPlaying(:final cleanPreview) => cleanPreview,
    PreviewPaused(:final cleanPreview) => cleanPreview,
  };
}

final class PreviewStopped extends PreviewState {
  const PreviewStopped();
}

final class PreviewPlaying extends PreviewState {
  const PreviewPlaying({required this.world, this.cleanPreview = false});
  @override
  final RuntimeWorld world;
  @override
  final bool cleanPreview;
}

final class PreviewPaused extends PreviewState {
  const PreviewPaused({required this.world, this.cleanPreview = false});
  @override
  final RuntimeWorld world;
  @override
  final bool cleanPreview;
}
