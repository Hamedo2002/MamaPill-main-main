import 'package:mama_pill/core/utils/secure_storage_util.dart';

class SecureStorageService {
  static const String _userTokenKey = 'user_auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Save user authentication token securely
  static Future<void> saveAuthToken(String token) async {
    await SecureStorageUtil.storeString(_userTokenKey, token);
  }

  /// Get user authentication token
  static Future<String?> getAuthToken() async {
    return await SecureStorageUtil.getString(_userTokenKey);
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    await SecureStorageUtil.storeString(_userEmailKey, email);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    return await SecureStorageUtil.getString(_userEmailKey);
  }

  /// Set biometric authentication preference
  static Future<void> setBiometricEnabled(bool enabled) async {
    await SecureStorageUtil.storeBool(_biometricEnabledKey, enabled);
  }

  /// Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    return await SecureStorageUtil.getBool(_biometricEnabledKey, defaultValue: false);
  }

  /// Clear all user data (logout)
  static Future<void> clearUserData() async {
    await SecureStorageUtil.remove(_userTokenKey);
    await SecureStorageUtil.remove(_userEmailKey);
    // Note: We keep biometric preference after logout
  }

  /// Clear all secure storage (for testing or account deletion)
  static Future<void> clearAll() async {
    await SecureStorageUtil.clear();
  }
}
