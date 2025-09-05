// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter 模板';

  @override
  String get welcome => '欢迎使用';

  @override
  String get welcomeMessage =>
      'Flutter Template 是一个基于 Riverpod + Dio + SharedPreferences 的快速开发模板，集成了常用的功能模块和最佳实践，帮助您快速开始新项目的开发。';

  @override
  String get themeMode => '主题模式';

  @override
  String get languageSettings => '语言设置';

  @override
  String get featureDemo => '功能演示';

  @override
  String get loadingDemo => '加载演示';

  @override
  String get dialog => '对话框';

  @override
  String get bottomSheet => '底部弹框';

  @override
  String get loginPage => '登录页面';

  @override
  String get quickActions => '快捷操作';

  @override
  String get profile => '个人中心';

  @override
  String get notifications => '通知';

  @override
  String get help => '帮助';

  @override
  String get loading => '正在加载中...';

  @override
  String get loadingComplete => '加载完成！';

  @override
  String get confirmOperation => '确认操作';

  @override
  String get confirmDialogMessage => '这是一个示例对话框，您确定要继续吗？';

  @override
  String get youClickedConfirm => '您点击了确定';

  @override
  String get youClickedCancel => '您点击了取消';

  @override
  String get bottomSheetExample => '底部弹框示例';

  @override
  String get bottomSheetMessage => '这是一个从底部弹出的弹框，可以用来显示更多选项或表单内容。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get operationSuccess => '操作成功！';

  @override
  String get profileFeatureInDevelopment => '个人中心功能开发中';

  @override
  String get notificationFeatureInDevelopment => '通知功能开发中';

  @override
  String get helpFeatureInDevelopment => '帮助功能开发中';

  @override
  String get lightMode => '浅色';

  @override
  String get darkMode => '深色';

  @override
  String get systemMode => '跟随系统';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get settings => '设置';

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get accountSettings => '账户设置';

  @override
  String get selectLanguage => '选择语言';
}
