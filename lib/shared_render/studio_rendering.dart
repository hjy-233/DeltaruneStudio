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
      final expressionId =
          runtimeObject?.expressionId ?? value.initialExpression;
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
      if (expressionFrames.isNotEmpty) {
        if (expressionFrames.length == 1) {
          return expressionFrames.first;
        }
        final fps = expression!.framesPerSecond <= 0
            ? 6.0
            : expression.framesPerSecond;
        final frame = (currentTime * fps).floor();
        final frameIndex = expression.loop
            ? frame % expressionFrames.length
            : frame.clamp(0, expressionFrames.length - 1);
        return expressionFrames[frameIndex];
      }
      if (character.animations.isEmpty) {
        return null;
      }
      final facing = runtimeObject?.facing ?? value.facing;
      final facingFrames = character.animations
          .where((animation) => animation.direction == facing)
          .toList();
      final neutralFrames = character.animations
          .where((animation) => animation.direction == null)
          .toList();
      final frames = facingFrames.isNotEmpty
          ? facingFrames
          : neutralFrames.isNotEmpty
          ? neutralFrames
          : character.animations;
      if (frames.length == 1 || runtimeObject?.isMoving == false) {
        return frames.first.assetId;
      }
      final frameIndex = ((currentTime / 0.22).floor()) % frames.length;
      return frames[frameIndex].assetId;
    },
    orElse: () => null,
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
