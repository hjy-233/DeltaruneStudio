import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:deltarune_studio/shared_render/studio_rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats manual dialogue lines with one bullet per logical line', () {
    expect(
      dialogueTextWithLineBullets('Hello world\nSecond line'),
      '* Hello world\n* Second line',
    );
  });

  test('clips dialogue text by visible character count before formatting', () {
    const dialogue = DialogueBoxState(
      text: 'Hello\nWorld',
      style: DialogueStyle.darkWorld,
      visibleCharacters: 7,
    );

    expect(visibleDialogueText(dialogue), 'Hello\nW');
    expect(
      dialogueTextWithLineBullets(visibleDialogueText(dialogue)),
      '* Hello\n* W',
    );
  });
}
