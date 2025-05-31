import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_utils.dart';

class SecureStorageUtil {
  static const String _prefix = 'secure_';
  
  /// Store an encrypted string
  static Future<void> storeString(String key, String value) async {
    try {
      final encrypted = await EncryptionUtil.encryptString(value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', encrypted);
    } catch (e) {
      throw Exception('Failed to securely store data: $e');
    }
  }

  /// Retrieve and decrypt a string
  static Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = prefs.getString('$_prefix$key');
      if (encrypted == null) return null;
      
      return await EncryptionUtil.decryptString(encrypted);
    } catch (e) {
      throw Exception('Failed to retrieve secure data: $e');
    }
  }

  /// Store an encrypted boolean
  static Future<void> storeBool(String key, bool value) async {
    await storeString(key, value.toString());
  }

  /// Retrieve and decrypt a boolean
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await getString(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Remove a secure value
  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove('$_prefix$key');
  }

  /// Clear all secure values
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
