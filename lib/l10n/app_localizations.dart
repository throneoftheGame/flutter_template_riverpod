import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Flutter Template'**
  String get appTitle;

  /// Welcome greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Welcome message description
  ///
  /// In en, this message translates to:
  /// **'Flutter Template is a rapid development template based on Riverpod + Dio + SharedPreferences, integrating common functional modules and best practices to help you quickly start new project development.'**
  String get welcomeMessage;

  /// Theme mode setting
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Language settings
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Feature demonstration
  ///
  /// In en, this message translates to:
  /// **'Feature Demo'**
  String get featureDemo;

  /// Loading demonstration
  ///
  /// In en, this message translates to:
  /// **'Loading Demo'**
  String get loadingDemo;

  /// Dialog
  ///
  /// In en, this message translates to:
  /// **'Dialog'**
  String get dialog;

  /// Bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Bottom Sheet'**
  String get bottomSheet;

  /// Login page
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  String get loginPage;

  /// Quick actions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Personal profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Help
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Loading complete message
  ///
  /// In en, this message translates to:
  /// **'Loading complete!'**
  String get loadingComplete;

  /// Confirm operation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Operation'**
  String get confirmOperation;

  /// Confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'This is a sample dialog. Are you sure you want to continue?'**
  String get confirmDialogMessage;

  /// Confirm button clicked message
  ///
  /// In en, this message translates to:
  /// **'You clicked Confirm'**
  String get youClickedConfirm;

  /// Cancel button clicked message
  ///
  /// In en, this message translates to:
  /// **'You clicked Cancel'**
  String get youClickedCancel;

  /// Bottom sheet example title
  ///
  /// In en, this message translates to:
  /// **'Bottom Sheet Example'**
  String get bottomSheetExample;

  /// Bottom sheet example message
  ///
  /// In en, this message translates to:
  /// **'This is a bottom sheet that pops up from the bottom, which can be used to display more options or form content.'**
  String get bottomSheetMessage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Operation success message
  ///
  /// In en, this message translates to:
  /// **'Operation successful!'**
  String get operationSuccess;

  /// Profile feature development message
  ///
  /// In en, this message translates to:
  /// **'Profile feature is in development'**
  String get profileFeatureInDevelopment;

  /// Notification feature development message
  ///
  /// In en, this message translates to:
  /// **'Notification feature is in development'**
  String get notificationFeatureInDevelopment;

  /// Help feature development message
  ///
  /// In en, this message translates to:
  /// **'Help feature is in development'**
  String get helpFeatureInDevelopment;

  /// Light theme mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// Dark theme mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// System theme mode
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Chinese language
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance Settings'**
  String get appearanceSettings;

  /// Account settings section
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
