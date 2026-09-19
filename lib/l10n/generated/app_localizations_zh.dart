// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Deltarune Studio';

  @override
  String get newProject => '新建项目';

  @override
  String get openProject => '打开项目';

  @override
  String get saveProject => '保存项目';

  @override
  String get projectName => '项目名称';

  @override
  String get create => '创建';

  @override
  String get cancel => '取消';

  @override
  String get noProject => '当前没有打开项目。';

  @override
  String projectCreated(Object path) {
    return '项目已创建：$path';
  }

  @override
  String projectOpened(Object name) {
    return '已打开项目：$name';
  }

  @override
  String get projectSaved => '项目已保存。';

  @override
  String get projectStructure => '项目结构';

  @override
  String get buildAndRun => '构建并在 Godot 中运行';

  @override
  String get godotStarted => 'Godot 运行时已启动。';

  @override
  String get newRoom => '新建房间';

  @override
  String roomCreated(Object name) {
    return '已创建房间：$name。';
  }

  @override
  String get projectTab => '项目';

  @override
  String get resourcesTab => '资源';

  @override
  String get charactersTab => '角色';

  @override
  String get roomsTab => '房间';

  @override
  String get projectPath => '项目路径';

  @override
  String get sceneFolder => '主房间';

  @override
  String get resourceBrowserNextStep => '资源浏览器将在这里接入。';

  @override
  String get noResources => '此分类暂无资源。';

  @override
  String get searchResources => '搜索资源';

  @override
  String get importResource => '导入资源';

  @override
  String get selectResourceType => '选择资源类型';

  @override
  String resourceImported(Object name) {
    return '已导入：$name。';
  }

  @override
  String get backgroundResources => '背景';

  @override
  String get characterResources => '角色';

  @override
  String get portraitResources => '头像';

  @override
  String get propResources => '物品';

  @override
  String get audioResources => '音频';

  @override
  String get videoResources => '视频';

  @override
  String get selectObject => '选择对象以编辑属性。';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get importHere => '导入到这里';

  @override
  String get renameFolder => '重命名文件夹';

  @override
  String get renameResource => '重命名资源';

  @override
  String get renameRoom => '重命名房间';

  @override
  String get resourceRenamed => '资源已重命名。';

  @override
  String get resourceDeleted => '资源已删除。';

  @override
  String get folderCreated => '文件夹已创建。';

  @override
  String get folderRenamed => '文件夹已重命名。';

  @override
  String get folderDeleted => '文件夹已删除。';

  @override
  String get roomRenamed => '房间已重命名。';

  @override
  String get roomDeleted => '房间已删除。';

  @override
  String deleteQuestion(Object name) {
    return '确定删除$name吗？';
  }

  @override
  String get resourceProperties => '资源属性';

  @override
  String get roomProperties => '房间属性';

  @override
  String get name => '名称';

  @override
  String get type => '类型';

  @override
  String get path => '路径';

  @override
  String get none => '无';

  @override
  String get objectCount => '对象数量';

  @override
  String get newCharacter => '新建角色';

  @override
  String get noCharacters => '还没有角色。';

  @override
  String characterCreated(Object name) {
    return '已创建角色：$name。';
  }

  @override
  String get characterSaved => '角色已保存。';

  @override
  String get characterDeleted => '角色已删除。';

  @override
  String get characterProperties => '角色属性';

  @override
  String get characterId => '角色 ID';

  @override
  String get defaultSize => '默认尺寸';

  @override
  String get width => '宽度';

  @override
  String get height => '高度';

  @override
  String get moveSpeed => '移动速度';

  @override
  String get collisionBox => '碰撞箱';

  @override
  String get animations => '动画';

  @override
  String get addAnimation => '添加动画';

  @override
  String get deleteAnimation => '删除动画';

  @override
  String get direction => '方向';

  @override
  String get directionUp => '上';

  @override
  String get directionDown => '下';

  @override
  String get directionLeft => '左';

  @override
  String get directionRight => '右';

  @override
  String get framesPerSecond => '每秒帧数';

  @override
  String get loop => '循环播放';

  @override
  String get addFrame => '添加帧';

  @override
  String get characterDefinition => '角色定义';

  @override
  String get characterDefaultName => '角色';

  @override
  String get ok => '确定';
}
