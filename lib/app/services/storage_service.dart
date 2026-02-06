import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService extends GetxService {
  late Box _prefsBox;
  late Box _cacheBox;

  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  Future<StorageService> init() async {
    await Hive.initFlutter('day_task_storage');

    _prefsBox = await Hive.openBox('preferences');
    _cacheBox = await Hive.openBox('cache');

    _isInitialized.value = true;
    return this;
  }

  bool get isFirstTime => _prefsBox.get('first_time', defaultValue: true);

  void setNotFirstTime() {
    _prefsBox.put('first_time', false);
  }

  // storage methods
  Future<void> write(String key, dynamic value) async {
    await _prefsBox.put(key, value);
  }

  T? read<T>(String key) {
    return _prefsBox.get(key);
  }

  Future<void> remove(String key) async {
    await _prefsBox.delete(key);
  }

  Future<void> clear() async {
    await _prefsBox.clear();
  }

  // offline support
  Future<void> cache(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  T? getCached<T>(String key) {
    return _cacheBox.get(key);
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }
}
