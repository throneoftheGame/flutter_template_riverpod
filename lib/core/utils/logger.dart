import 'package:talker_flutter/talker_flutter.dart';

class AppLogger {
  static late final Talker talker;

  static Future<void> init({bool enableLogging = true}) async {
    talker = TalkerFlutter.init(
      settings: TalkerSettings(
        useConsoleLogs: enableLogging,
        maxHistoryItems: enableLogging ? 1000 : 0,
        enabled: enableLogging,
      ),
    );
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    talker.debug(message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    talker.info(message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    talker.warning(message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    talker.error(message, error, stackTrace);
  }

  static void critical(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    talker.critical(message, error, stackTrace);
  }
}
