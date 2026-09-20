import 'package:flutter/widgets.dart';

class ProjectFeatureStrings {
  const ProjectFeatureStrings._(this.zh);

  final bool zh;

  static ProjectFeatureStrings of(BuildContext context) {
    return ProjectFeatureStrings._(
      Localizations.localeOf(context).languageCode == 'zh',
    );
  }

  String get projectSettings => zh ? '项目设置' : 'Project settings';
  String get gameSettings => zh ? '游戏' : 'Game';
  String get exportSettings => zh ? '导出' : 'Export';
  String get viewportSize => zh ? '逻辑画面尺寸' : 'Logical viewport';
  String get windowSize => zh ? '窗口尺寸' : 'Window size';
  String get startFullscreen => zh ? '启动时全屏' : 'Start in fullscreen';
  String get pixelPerfect => zh ? '像素精确渲染' : 'Pixel-perfect rendering';
  String get defaultSaveSlot => zh ? '默认存档槽位' : 'Default save slot';
  String get enableWasd => zh ? '启用 WASD 移动' : 'Enable WASD movement';
  String get enableArrowKeys => zh ? '启用方向键移动' : 'Enable arrow-key movement';
  String get bundleIdentifier => zh ? '应用包标识符' : 'Bundle identifier';
  String get version => zh ? '版本' : 'Version';
  String get gameIcon => zh ? '游戏图标' : 'Game icon';
  String get defaultExportTarget => zh ? '默认导出平台' : 'Default export target';
  String get exportDirectory => zh ? '导出目录' : 'Export directory';
  String get choose => zh ? '选择' : 'Choose';
  String get roomGraph => zh ? '房间连接图' : 'Room connections';
  String get resourceAudit => zh ? '资源引用检查' : 'Resource audit';
  String get unusedResource => zh ? '未使用资源' : 'Unused resource';
  String get missingResource => zh ? '缺失资源' : 'Missing resource';
  String get missingRoom => zh ? '目标房间缺失' : 'Missing target room';
  String get missingSpawn => zh ? '目标出生点缺失' : 'Missing target spawn point';
  String get usedBy => zh ? '使用位置' : 'Used by';
  String get noReferences => zh ? '未被引用' : 'Not referenced';
  String get noAuditIssues => zh ? '没有发现引用问题。' : 'No reference problems found.';
  String get duplicateAnimation => zh ? '复制动画' : 'Duplicate animation';
  String get moveFrameLeft => zh ? '向前移动帧' : 'Move frame earlier';
  String get moveFrameRight => zh ? '向后移动帧' : 'Move frame later';
}
