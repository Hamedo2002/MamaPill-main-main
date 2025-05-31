import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionUtil {
  static const String _encryptionKeyPrefsKey = 'encryption_key';
  
  /// Get or create encryption key
  static Future<encrypt_lib.Key> _getOrCreateKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString(_encryptionKeyPrefsKey);
    
    if (keyString == null) {
      // Generate a new key if none exists
      final key = encrypt_lib.Key.fromSecureRandom(32); // 256-bit key
      await prefs.setString(_encryptionKeyPrefsKey, key.base64);
      return key;
    } else {
      return encrypt_lib.Key.fromBase64(keyString);
    }
  }

  /// Encrypt a string
  static Future<String> encryptString(String plainText) async {
    try {
      final key = await _getOrCreateKey();
      final iv = encrypt_lib.IV.fromSecureRandom(16); // 128-bit IV
      final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm));
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // Combine IV and encrypted data with a separator
      return '${iv.base64}|${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt a string
  static Future<String> decryptString(String encryptedText) async {
    try {
      final parts = encryptedText.split('|');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted text format');
      }
      
      final key = await _getOrCreateKey();
      final iv = encrypt_lib.IV.fromBase64(parts[0]);
      final encrypted = encrypt_lib.Encrypted.fromBase64(parts[1]);
      
      final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Encrypt a JSON-serializable object
  static Future<String> encryptJson(Map<String, dynamic> json) async {
    final jsonString = json.toString();
    return await encryptString(jsonString);
  }

  /// Decrypt and parse JSON
  static Future<Map<String, dynamic>> decryptJson(String encryptedJson) async {
    final jsonString = await decryptString(encryptedJson);
    // Simple way to convert string to Map, you might want to use jsonDecode with proper error handling
    return Map<String, dynamic>.from(jsonString as Map);
  }
}
