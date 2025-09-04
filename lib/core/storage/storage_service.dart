import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// 存储服务接口
abstract class StorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> setDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> setObject<T>(
    String key,
    T object,
    T Function(Map<String, dynamic>) fromJson,
  );
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  );
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
  Future<Set<String>> getKeys();
}

/// SharedPreferences 存储实现
class SharedPreferencesStorage implements StorageService {
  SharedPreferencesStorage._();

  static SharedPreferencesStorage? _instance;
  static SharedPreferences? _prefs;

  static Future<SharedPreferencesStorage> getInstance() async {
    _instance ??= SharedPreferencesStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs!.setString(key, value);
      AppLogger.debug('Stored string: $key');
    } catch (e) {
      AppLogger.error('Failed to store string: $key', e);
      rethrow;
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      final value = _prefs!.getString(key);
      AppLogger.debug('Retrieved string: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve string: $key', e);
      return null;
    }
  }

  @override
  Future<void> setInt(String key, int value) async {
    try {
      await _prefs!.setInt(key, value);
      AppLogger.debug('Stored int: $key = $value');
    } catch (e) {
      AppLogger.error('Failed to store int: $key', e);
      rethrow;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      final value = _prefs!.getInt(key);
      AppLogger.debug('Retrieved int: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve int: $key', e);
      return null;
    }
  }

  @override
  Future<void> setDouble(String key, double value) async {
    try {
      await _prefs!.setDouble(key, value);
      AppLogger.debug('Stored double: $key = $value');
    } catch (e) {
      AppLogger.error('Failed to store double: $key', e);
      rethrow;
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      final value = _prefs!.getDouble(key);
      AppLogger.debug('Retrieved double: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve double: $key', e);
      return null;
    }
  }

  @override
  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs!.setBool(key, value);
      AppLogger.debug('Stored bool: $key = $value');
    } catch (e) {
      AppLogger.error('Failed to store bool: $key', e);
      rethrow;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      final value = _prefs!.getBool(key);
      AppLogger.debug('Retrieved bool: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve bool: $key', e);
      return null;
    }
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs!.setStringList(key, value);
      AppLogger.debug('Stored string list: $key = $value');
    } catch (e) {
      AppLogger.error('Failed to store string list: $key', e);
      rethrow;
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      final value = _prefs!.getStringList(key);
      AppLogger.debug('Retrieved string list: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve string list: $key', e);
      return null;
    }
  }

  @override
  Future<void> setObject<T>(
    String key,
    T object,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      // 这里假设对象有toJson方法，实际使用时需要根据具体情况调整
      final jsonString = jsonEncode(object);
      await setString(key, jsonString);
      AppLogger.debug('Stored object: $key');
    } catch (e) {
      AppLogger.error('Failed to store object: $key', e);
      rethrow;
    }
  }

  @override
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final object = fromJson(json);
      AppLogger.debug('Retrieved object: $key');
      return object;
    } catch (e) {
      AppLogger.error('Failed to retrieve object: $key', e);
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs!.remove(key);
      AppLogger.debug('Removed key: $key');
    } catch (e) {
      AppLogger.error('Failed to remove key: $key', e);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs!.clear();
      AppLogger.debug('Cleared all storage');
    } catch (e) {
      AppLogger.error('Failed to clear storage', e);
      rethrow;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      final contains = _prefs!.containsKey(key);
      AppLogger.debug('Contains key: $key = $contains');
      return contains;
    } catch (e) {
      AppLogger.error('Failed to check key: $key', e);
      return false;
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    try {
      final keys = _prefs!.getKeys();
      AppLogger.debug('Retrieved keys: $keys');
      return keys;
    } catch (e) {
      AppLogger.error('Failed to retrieve keys', e);
      return <String>{};
    }
  }
}

/// 存储服务 Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized in main()');
});

/// 初始化存储服务的 Provider
final storageInitProvider = FutureProvider<StorageService>((ref) async {
  return await SharedPreferencesStorage.getInstance();
});
