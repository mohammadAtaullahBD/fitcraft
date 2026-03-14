import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitcraft/core/utils/constants.dart';

/// Manages Hive initialisation and box access.
class HiveService {
  HiveService._();
  static final HiveService _instance = HiveService._();
  static HiveService get instance => _instance;

  late Box _userBox;
  late Box _settingsBox;
  late Box _measurementsBox;

  /// Call once before runApp.
  Future<void> init() async {
    await Hive.initFlutter();

    _userBox = await Hive.openBox(AppConstants.userBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _measurementsBox = await Hive.openBox(AppConstants.measurementsBox);
  }

  Box get userBox => _userBox;
  Box get settingsBox => _settingsBox;
  Box get measurementsBox => _measurementsBox;

  /// Clear all local data (e.g. on logout).
  Future<void> clearAll() async {
    await _userBox.clear();
    await _settingsBox.clear();
    await _measurementsBox.clear();
  }
}
