import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _keyName = 'profile_name';
  static const String _keyStoreName = 'profile_store_name';
  static const String _keyEmail = 'profile_email';
  static const String _keyPhone = 'profile_phone';
  static const String _keyImagePath = 'profile_image_path';

  // Default values
  static const String _defaultName = 'Budi Setiawan';
  static const String _defaultStoreName = 'Warung Madura Cabang Pusat';
  static const String _defaultEmail = 'budi.warung@example.com';
  static const String _defaultPhone = '+62 812 3456 7890';

  static Future<void> saveProfile({
    required String name,
    required String storeName,
    required String email,
    required String phone,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyStoreName, storeName);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
    if (imagePath != null) {
      await prefs.setString(_keyImagePath, imagePath);
    }
  }

  static Future<Map<String, String?>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? _defaultName,
      'storeName': prefs.getString(_keyStoreName) ?? _defaultStoreName,
      'email': prefs.getString(_keyEmail) ?? _defaultEmail,
      'phone': prefs.getString(_keyPhone) ?? _defaultPhone,
      'imagePath': prefs.getString(_keyImagePath),
    };
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? _defaultName;
  }

  static Future<String> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStoreName) ?? _defaultStoreName;
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? _defaultEmail;
  }

  static Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyImagePath);
  }
}