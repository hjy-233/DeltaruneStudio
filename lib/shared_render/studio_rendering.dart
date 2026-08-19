import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/studio_state.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';

final class DialogueTemplateSpec {
  const DialogueTemplateSpec({
    required this.assetPath,
    required this.width,
    required this.height,
  });

  final String assetPath;
  final double width;
  final double height;
}

const dialogueMinBoxWidth = 280.0;
const dialogueCameraHorizontalInset = 28.0;
const dialogueBottomInset = 18.0;
const dialogueScaledBottomInset = 20.0;
const dialoguePortraitOuterLeft = 28.0;
const dialoguePortraitOuterTop = 26.0;
const dialoguePortraitOuterSize = 108.0;
const dialoguePortraitInnerInset = 10.0;
const dialoguePortraitInnerSize = 88.0;
const dialogueTextLeftWithPortrait = 146.0;
const dialogueTextLeftWithoutPortrait = 42.0;
const dialogueTextTop = 36.0;
const dialogueTextRight = 42.0;
const dialogueTextBottom = 30.0;
const dialogueFontSize = 24.0;
const dialogueLineHeight = 1.35;

DialogueTemplateSpec dialogueTemplateForStyle(DialogueStyle style) {
  return switch (style) {
    DialogueStyle.darkWorld => const DialogueTemplateSpec(
      assetPath: 'assets/dialogue/dark_world/box.png',
      width: 594,
      height: 168,
    ),
    DialogueStyle.regular => const DialogueTemplateSpec(
      assetPath: 'assets/dialogue/light_world/box.png',
      width: 578,
      height: 152,
    ),
  };
}

String visibleDialogueText(DialogueBoxState dialogue) {
  final visibleCharacters = dialogue.visibleCharacters ?? dialogue.text.length;
  return dialogue.text.substring(
    0,
    visibleCharacters.clamp(0, dialogue.text.length),
  );
}

String dialogueTextWithLineBullets(String text) {
  final lines = text.split('\n');
  return [for (final line in lines) '* $line'].join('\n');
}

String? imageAssetIdForObject({
  required StudioReady ready,
  required SceneObject object,
  required RuntimeObject? runtimeObject,
  required double currentTime,
}) {
  return object.maybeMap(
    prop: (value) => value.assetId,
    background: (value) => value.assetId,
    characterInstance: (value) {
      final character = ready.characterById(value.characterId);
      if (character == null) {
        return null;
      }
      final expressionAssetId = _expressionAssetIdForCharacter(
        character: character,
        expressionId: runtimeObject?.expressionId ?? value.initialExpression,
        currentTime: currentTime,
      );
      if (runtimeObject?.expressionOverrideActive == true &&
          expressionAssetId != null) {
        return expressionAssetId;
      }
      if ((runtimeObject?.movementPoseAssetId ?? '').isNotEmpty) {
        return runtimeObject!.movementPoseAssetId;
      }
      final facing = runtimeObject?.facing ?? value.facing;
      final movementAssetId = movementAssetIdForCharacter(
        character: character,
        facing: facing,
        isMoving: runtimeObject?.isMoving ?? false,
        currentTime: currentTime,
      );
      if (movementAssetId != null) {
        return movementAssetId;
      }
      if (expressionAssetId != null) {
        return expressionAssetId;
      }
      final frames = _animationFramesForFacing(character, facing);
      if (frames.isEmpty) {
        return null;
      }
      if (frames.length == 1) {
        return frames.first.assetId;
      }
      final frameIndex = _frameIndex(
        currentTime: currentTime,
        framesPerSecond: 1 / 0.22,
        frameCount: frames.length,
      );
      return frames[frameIndex].assetId;
    },
    orElse: () => null,
  );
}

String? _expressionAssetIdForCharacter({
  required Character character,
  required String? expressionId,
  required double currentTime,
}) {
  final expression = character.expressions
      .where((expression) => expression.id == expressionId)
      .firstOrNull;
  final expressionFrames = <String>[];
  if (expression != null) {
    expressionFrames.addAll(expression.assetIds);
    if ((expression.assetId ?? '').isNotEmpty) {
      expressionFrames.add(expression.assetId!);
    }
  }
  if (expressionFrames.isEmpty) {
    return null;
  }
  if (expressionFrames.length == 1) {
    return expressionFrames.first;
  }
  final frameIndex = _frameIndex(
    currentTime: currentTime,
    framesPerSecond: expression!.framesPerSecond,
    frameCount: expressionFrames.length,
    loop: expression.loop,
  );
  return expressionFrames[frameIndex];
}

String? movementAssetIdForCharacter({
  required Character character,
  required Direction facing,
  required bool isMoving,
  required double currentTime,
}) {
  if (!isMoving) {
    return null;
  }
  final frames = _animationFramesForFacing(character, facing);
  if (frames.isEmpty) {
    return null;
  }
  if (frames.length == 1) {
    return frames.first.assetId;
  }
  final frameIndex = _frameIndex(
    currentTime: currentTime,
    framesPerSecond: 1 / 0.22,
    frameCount: frames.length,
  );
  return frames[frameIndex].assetId;
}

String? standingMovementAssetIdForCharacter({
  required Character character,
  required Direction facing,
}) {
  final frames = _animationFramesForFacing(character, facing);
  return frames.isEmpty ? null : frames.first.assetId;
}

List<AnimationClip> _animationFramesForFacing(
  Character character,
  Direction facing,
) {
  final facingFrames = character.animations
      .where((animation) => animation.direction == facing)
      .toList();
  final neutralFrames = character.animations
      .where((animation) => animation.direction == null)
      .toList();
  return facingFrames.isNotEmpty
      ? facingFrames
      : neutralFrames.isNotEmpty
      ? neutralFrames
      : character.animations;
}

int _frameIndex({
  required double currentTime,
  required double framesPerSecond,
  required int frameCount,
  bool loop = true,
}) {
  final fps = framesPerSecond <= 0 ? 6.0 : framesPerSecond;
  final frame = (currentTime * fps).floor();
  return loop ? frame % frameCount : frame.clamp(0, frameCount - 1);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
