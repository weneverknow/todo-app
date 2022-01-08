import 'package:shared_preferences/shared_preferences.dart';

class SaveUserCache {
  static SharedPreferences? _preferences;

  static Future initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveUser(String user) async {
    await initPreferences();
    final result = await _preferences!.setString('user', user);
    if (!result) {
      return false;
    }
    return true;
  }

  static Future<String?> getUser() async {
    await initPreferences();
    String? user = _preferences!.getString('user');
    return user;
  }

  static Future<bool> signOut() async {
    await initPreferences();
    final result = await _preferences!.remove('user');
    return result;
  }
}
