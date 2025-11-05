import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _kName = 'user_display_name';

  static Future<String?> getName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kName);
  }

  static Future<void> setName(String name) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kName, name);
  }

  static String deriveNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'Friend';
    return local[0].toUpperCase() + local.substring(1);
  }
}

