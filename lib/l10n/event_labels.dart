import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';

String eventLabel(AppLocalizations l10n, StudioEvent event) {
  return event.map(
    characterMove: (_) => l10n.characterMove,
    characterStartFollow: (_) => l10n.startFollow,
    characterStopFollow: (_) => l10n.stopFollow,
    characterWait: (_) => l10n.wait,
    characterChangeExpression: (_) => l10n.changeExpression,
    dialogueSay: (_) => l10n.dialogue,
    cameraFollow: (_) => l10n.cameraFollow,
    cameraFocus: (_) => l10n.cameraFocus,
    sceneFade: (_) => l10n.fade,
    sceneChange: (_) => l10n.canvasJump,
    audioPlayBgm: (_) => l10n.playBgm,
    audioPlaySound: (_) => l10n.playSound,
    videoPlay: (_) => l10n.playVideo,
  );
}
