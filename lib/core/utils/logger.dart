import 'package:talker_flutter/talker_flutter.dart';

class AppLogger {
  static late final Talker talker;

  static Future<void> init() async {
    talker = TalkerFlutter.init(
      settings: TalkerSettings(useConsoleLogs: true, maxHistoryItems: 1000),
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
