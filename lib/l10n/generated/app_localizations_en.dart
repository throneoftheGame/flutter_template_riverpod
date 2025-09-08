// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Login to Your Account';

  @override
  String get loginPage => 'Login Page';

  @override
  String get accountEmailLogin => 'Account/Email Login';

  @override
  String get phoneLogin => 'Phone Login';

  @override
  String get accountEmail => 'Account/Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get noAccount => 'No Account?';

  @override
  String get pleaseRegister => 'Please Register';

  @override
  String get pleaseEnterAccountOrEmail => 'Please enter account or email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get emailNotLinked =>
      'This email is not linked to an account, please use account login!';

  @override
  String get accountNotRegistered =>
      'This account is not registered, please register first!';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String pleaseEnterDigitsPhone(int digits) {
    return 'Please enter $digits-digit phone number!';
  }

  @override
  String get phoneOnlyDigits => 'Phone number can only contain digits';

  @override
  String get phoneNotRegistered =>
      'This phone number is not registered, please register!';

  @override
  String get passwordMustContain => 'Password must contain letters and numbers';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get loginSuccess => 'Login Successful!';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get incorrectPassword => 'Incorrect password, please try again!';

  @override
  String loginFailedError(String error) {
    return 'Login failed: $error';
  }

  @override
  String get forgotPasswordInDevelopment =>
      'Forgot password feature is under development';

  @override
  String get registerInDevelopment =>
      'Registration feature is under development';

  @override
  String get appTitle => 'Flutter Template';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingComplete => 'Loading complete!';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get operationSuccess => 'Operation successful!';

  @override
  String get confirmOperation => 'Confirm Operation';

  @override
  String get confirmDialogMessage =>
      'This is a sample dialog. Are you sure you want to continue?';

  @override
  String get youClickedConfirm => 'You clicked Confirm';

  @override
  String get youClickedCancel => 'You clicked Cancel';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String switchedToLanguage(String language) {
    return 'Switched to $language';
  }

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage =>
      'Flutter Template is a rapid development template based on Riverpod + Dio + SharedPreferences, integrating common functional modules and best practices to help you quickly start new project development.';

  @override
  String get featureDemo => 'Feature Demo';

  @override
  String get loadingDemo => 'Loading Demo';

  @override
  String get dialog => 'Dialog';

  @override
  String get bottomSheet => 'Bottom Sheet';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get help => 'Help';

  @override
  String get bottomSheetExample => 'Bottom Sheet Example';

  @override
  String get bottomSheetMessage =>
      'This is a bottom sheet that pops up from the bottom, which can be used to display more options or form content.';

  @override
  String get profileFeatureInDevelopment => 'Profile feature is in development';

  @override
  String get notificationFeatureInDevelopment =>
      'Notification feature is in development';

  @override
  String get helpFeatureInDevelopment => 'Help feature is in development';

  @override
  String get settings => 'Settings';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get appearanceSettings => 'Appearance Settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';
}
