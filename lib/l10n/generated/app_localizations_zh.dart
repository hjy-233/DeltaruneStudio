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
  String get newProject => '新建';

  @override
  String get open => '打开';

  @override
  String get save => '保存';

  @override
  String get saveDirty => '保存 *';

  @override
  String get saveAs => '另存为';

  @override
  String get room => '房间';

  @override
  String get importBackgroundShort => '导入背景';

  @override
  String get audio => '音频';

  @override
  String get actor => '角色';

  @override
  String get doorTrigger => '门触发点';

  @override
  String get mainCanvas => '主画布';

  @override
  String get play => '播放';

  @override
  String get stop => '停止';

  @override
  String get pause => '暂停';

  @override
  String get settings => '设置';

  @override
  String get close => '关闭';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get englishDialogueTypewriterByWord => '英文对话按词出现';

  @override
  String get englishDialogueTypewriterByWordHelp =>
      '当软件语言为英文且对话文本是英文时，打字机效果按词推进。';

  @override
  String get characterLibraryScope => '角色库范围';

  @override
  String get characterLibraryGlobal => '全局角色库';

  @override
  String get characterLibraryGlobalHelp => '角色配置保存在应用全局角色库，所有项目都可以调用。';

  @override
  String get characterLibraryProject => '当前项目';

  @override
  String get characterLibraryProjectHelp => '角色配置只保存在当前 .drs 项目中。';

  @override
  String get canvasObjects => '画布对象';

  @override
  String get trigger => '触发点';

  @override
  String get import => '导入';

  @override
  String get prop => '物品';

  @override
  String get assets => '资源';

  @override
  String get builtInAssets => '内置资源';

  @override
  String get searchBuiltIns => '搜索内置资源';

  @override
  String builtInAssetsCount(int shown, int total) {
    return '显示 $shown / $total';
  }

  @override
  String get addBuiltInAsset => '添加内置资源';

  @override
  String get importAsset => '导入资源';

  @override
  String get importBackground => '导入背景';

  @override
  String get importProp => '导入物品';

  @override
  String get importCharacterAsset => '导入角色素材';

  @override
  String get importAudio => '导入音频';

  @override
  String get noImportedAssets => '还没有导入资源';

  @override
  String get characters => '角色';

  @override
  String expressionsCount(int count) {
    return '$count 个表情';
  }

  @override
  String get character => '角色';

  @override
  String get background => '背景';

  @override
  String get triggerPoint => '触发点';

  @override
  String get missing => '缺失';

  @override
  String get eventChains => '事件链';

  @override
  String get addEventChain => '新增事件链';

  @override
  String eventsCount(int count) {
    return '$count 个事件';
  }

  @override
  String get createOrSelectChain => '创建或选择一个事件链。';

  @override
  String get addEvent => '新增事件';

  @override
  String get addNode => '新增节点';

  @override
  String get characterMove => '角色移动';

  @override
  String get wait => '等待';

  @override
  String get changeExpression => '切换表情';

  @override
  String get dialogue => '对话';

  @override
  String get fadeOut => '淡出';

  @override
  String get cameraFollow => '镜头跟随';

  @override
  String get cameraFocus => '镜头聚焦';

  @override
  String get playSound => '播放音效';

  @override
  String get playBgm => '播放 BGM';

  @override
  String get playVideo => '播放视频';

  @override
  String get startFollow => '开始跟随';

  @override
  String get stopFollow => '停止跟随';

  @override
  String get expression => '表情';

  @override
  String get fade => '淡入淡出';

  @override
  String get canvasJump => '画布跳转';

  @override
  String get noAssetSelected => '未选择资源';

  @override
  String get noEvent => '无事件';

  @override
  String get noActiveEvent => '无活动事件';

  @override
  String get scratchProject => '临时项目';

  @override
  String get inspector => '检查器';

  @override
  String get quickActions => '快捷操作';

  @override
  String get addRoom => '添加房间';

  @override
  String get addActor => '添加角色';

  @override
  String get addDoorTrigger => '添加门触发点';

  @override
  String get createEventChain => '创建事件链';

  @override
  String get addMoveEvent => '添加移动事件';

  @override
  String get selectSomething => '选择画布对象、路径节点、事件、资源或角色。';

  @override
  String get missingObject => '对象缺失。';

  @override
  String get missingTrigger => '触发点缺失。';

  @override
  String get missingEventChain => '事件链缺失。';

  @override
  String get missingEvent => '事件缺失。';

  @override
  String get missingPathNode => '路径节点缺失。';

  @override
  String get missingAsset => '资源缺失。';

  @override
  String get missingCharacter => '角色缺失。';

  @override
  String get characterInstance => '角色实例';

  @override
  String get propObject => '物品对象';

  @override
  String get backgroundObject => '背景对象';

  @override
  String get name => '名称';

  @override
  String get facing => '朝向';

  @override
  String get initialExpression => '初始表情';

  @override
  String get visual => '显示';

  @override
  String get builtInRoom => '内置房间';

  @override
  String get builtIn => '内置';

  @override
  String get locked => '锁定';

  @override
  String get interactable => '可交互';

  @override
  String get advancedPosition => '高级位置';

  @override
  String get back => '后移';

  @override
  String get front => '前移';

  @override
  String get bottom => '置底';

  @override
  String get top => '置顶';

  @override
  String get delete => '删除';

  @override
  String get eventChain => '事件链';

  @override
  String get triggerMode => '触发方式';

  @override
  String get triggerModeTriggerPoint => '触发点触发';

  @override
  String get triggerModeAlways => '始终触发';

  @override
  String get linkedDoor => '链接到 Door';

  @override
  String get triggerPointHelp => '路径节点可以直接链接到这个触发点。角色到达节点后，会执行这里绑定的事件链。';

  @override
  String get pathNode => '路径节点';

  @override
  String get speed => '速度';

  @override
  String get shake => '抖动';

  @override
  String get addPathNode => '新增路径节点';

  @override
  String get duration => '时长';

  @override
  String get speaker => '说话者';

  @override
  String get text => '文本';

  @override
  String get portrait => '头像';

  @override
  String get dialogueStyle => '对话框风格';

  @override
  String get dialogueStyleRegular => '普通白边';

  @override
  String get dialogueStyleDarkWorld => 'Dark World';

  @override
  String get target => '目标';

  @override
  String get mode => '模式';

  @override
  String get canvasMarker => '画布标记';

  @override
  String get deleteEvent => '删除事件';

  @override
  String get waitSeconds => '停留秒数';

  @override
  String get linkedTrigger => '链接触发点';

  @override
  String get none => '无';

  @override
  String get deleteNode => '删除节点';

  @override
  String get asset => '资源';

  @override
  String get missingFile => '文件缺失';

  @override
  String get kind => '类型';

  @override
  String get path => '路径';

  @override
  String get assetInUse => '资源正在使用';

  @override
  String get deleteAsset => '删除资源';

  @override
  String get characterDefinition => '角色定义';

  @override
  String get defaultSpeed => '默认速度';

  @override
  String get defaultShake => '默认抖动';

  @override
  String get expressions => '表情';

  @override
  String get addExpression => '添加表情';

  @override
  String get pointX => '点 X';

  @override
  String get pointY => '点 Y';

  @override
  String get width => '宽';

  @override
  String get height => '高';

  @override
  String get scale => '缩放';

  @override
  String zoomPercent(int percent) {
    return '缩放 $percent%';
  }

  @override
  String get triggerLinkLabel => '-> 触发点';

  @override
  String moveDescription(int count, double speed, double shake) {
    return '$count 个节点，速度 $speed，抖动 $shake';
  }

  @override
  String nodeCoordinates(String x, String y) {
    return 'x $x, y $y';
  }
}
