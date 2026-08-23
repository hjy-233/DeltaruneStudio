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
}
