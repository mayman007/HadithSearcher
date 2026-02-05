import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service for handling in-app updates.
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  /// Check for available updates and return update info.
  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        return updateInfo;
      }
      return null;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  /// Perform immediate update.
  Future<void> performImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      debugPrint('Error performing update: $e');
    }
  }
}
