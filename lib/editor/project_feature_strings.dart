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
  String get tileMap => zh ? 'TileMap / 碰撞绘制' : 'TileMap / collision painter';
  String get ground => zh ? '地面' : 'Ground';
  String get wall => zh ? '墙体' : 'Wall';
  String get collision => zh ? '碰撞' : 'Collision';
  String get erase => zh ? '擦除' : 'Erase';
  String get tileResource => zh ? '笔刷资源' : 'Brush resource';
  String get tileWidth => zh ? '格宽' : 'Tile width';
  String get tileHeight => zh ? '格高' : 'Tile height';
  String get apply => zh ? '应用' : 'Apply';
  String get cancel => zh ? '取消' : 'Cancel';
  String get prefabs => zh ? '对象预设' : 'Object prefabs';
  String get savePrefab => zh ? '保存为预设' : 'Save as prefab';
  String get insertPrefab => zh ? '插入预设' : 'Insert prefab';
  String get dialogues => zh ? '对话资源' : 'Dialogues';
  String get newDialogue => zh ? '新建对话' : 'New dialogue';
  String get dialogueId => zh ? '对话 ID' : 'Dialogue ID';
  String get portrait => zh ? '头像' : 'Portrait';
  String get dialogueSound => zh ? '打字音效' : 'Typing sound';
  String get dialogueStyle => zh ? '边框样式' : 'Frame style';
  String get textEnglish => zh ? '英文文本' : 'English text';
  String get textChinese => zh ? '中文文本' : 'Chinese text';
  String get interaction => zh ? '交互组件' : 'Interaction';
  String get interactionDistance => zh ? '交互距离' : 'Interaction distance';
  String get interactionPrompt => zh ? '交互提示' : 'Interaction prompt';
  String get interactionFunction => zh ? '调用函数' : 'Function';
  String get interactionOnce => zh ? '仅触发一次' : 'Trigger once';
  String get requireFacing => zh ? '需要面向物品' : 'Require facing';
  String get objectCollision => zh ? '物品碰撞箱' : 'Object collision';
  String get exportPreflight => zh ? '导出预检' : 'Export preflight';
  String get packagedFiles => zh ? '实际打包文件' : 'Packaged files';
  String get estimatedSize => zh ? '预计包体积' : 'Estimated package size';
  String get unsupportedFiles => zh ? '不支持格式' : 'Unsupported formats';
  String get continueExport => zh ? '继续导出' : 'Continue export';
  String get hotReloaded => zh ? '运行中的房间已热更新' : 'Running room hot-reloaded';
}
