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
  String get propResources => '物品';

  @override
  String get audioResources => '音频';

  @override
  String get videoResources => '视频';

  @override
  String get selectObject => '选择对象以编辑属性。';
}
