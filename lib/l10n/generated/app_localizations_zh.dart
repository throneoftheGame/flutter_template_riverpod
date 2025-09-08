// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get login => '登录';

  @override
  String get loginTitle => '登录你的账号';

  @override
  String get loginPage => '登录页面';

  @override
  String get accountEmailLogin => '账号/邮箱登录';

  @override
  String get phoneLogin => '手机号码登录';

  @override
  String get accountEmail => '账号/邮箱';

  @override
  String get phoneNumber => '手机号码';

  @override
  String get password => '密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get noAccount => '没有账号？';

  @override
  String get pleaseRegister => '请注册';

  @override
  String get pleaseEnterAccountOrEmail => '请输入账号或邮箱';

  @override
  String get pleaseEnterValidEmail => '请输入有效的邮箱地址';

  @override
  String get emailNotLinked => '该邮箱未绑定账号，请用账号登录！';

  @override
  String get accountNotRegistered => '该账号未注册，请先注册！';

  @override
  String get pleaseEnterPhoneNumber => '请输入手机号码';

  @override
  String pleaseEnterDigitsPhone(int digits) {
    return '请输入$digits位的手机号码！';
  }

  @override
  String get phoneOnlyDigits => '手机号码只能包含数字';

  @override
  String get phoneNotRegistered => '该手机号码未注册，请前往注册！';

  @override
  String get passwordMustContain => '密码必须包含英文字母及数字';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get loginSuccess => '登录成功！';

  @override
  String get loginFailed => '登录失败';

  @override
  String get incorrectPassword => '密码输入错误，请重新输入！';

  @override
  String loginFailedError(String error) {
    return '登录失败：$error';
  }

  @override
  String get forgotPasswordInDevelopment => '忘记密码功能开发中';

  @override
  String get registerInDevelopment => '注册功能开发中';

  @override
  String get appTitle => 'Flutter 模板';

  @override
  String get loading => '正在加载中...';

  @override
  String get loadingComplete => '加载完成！';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get operationSuccess => '操作成功！';

  @override
  String get confirmOperation => '确认操作';

  @override
  String get confirmDialogMessage => '这是一个示例对话框，您确定要继续吗？';

  @override
  String get youClickedConfirm => '您点击了确定';

  @override
  String get youClickedCancel => '您点击了取消';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String switchedToLanguage(String language) {
    return '已切换到$language';
  }

  @override
  String get welcome => '欢迎使用';

  @override
  String get welcomeMessage =>
      'Flutter Template 是一个基于 Riverpod + Dio + SharedPreferences 的快速开发模板，集成了常用的功能模块和最佳实践，帮助您快速开始新项目的开发。';

  @override
  String get featureDemo => '功能演示';

  @override
  String get loadingDemo => '加载演示';

  @override
  String get dialog => '对话框';

  @override
  String get bottomSheet => '底部弹框';

  @override
  String get quickActions => '快捷操作';

  @override
  String get profile => '个人中心';

  @override
  String get notifications => '通知';

  @override
  String get help => '帮助';

  @override
  String get bottomSheetExample => '底部弹框示例';

  @override
  String get bottomSheetMessage => '这是一个从底部弹出的弹框，可以用来显示更多选项或表单内容。';

  @override
  String get profileFeatureInDevelopment => '个人中心功能开发中';

  @override
  String get notificationFeatureInDevelopment => '通知功能开发中';

  @override
  String get helpFeatureInDevelopment => '帮助功能开发中';

  @override
  String get settings => '设置';

  @override
  String get themeMode => '主题模式';

  @override
  String get languageSettings => '语言设置';

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get accountSettings => '账户设置';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get lightMode => '浅色';

  @override
  String get darkMode => '深色';

  @override
  String get systemMode => '跟随系统';
}
