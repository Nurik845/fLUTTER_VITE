import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _kName = 'user_display_name';
  static const _kFamily = 'family_members';
  static const _kPlan = 'subscription_plan'; // basic | vip | premium

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

  // Family members (names only)
  static Future<List<String>> getFamily() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_kFamily) ?? <String>[];
  }

  static Future<void> setFamily(List<String> members) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kFamily, members);
  }

  // Subscription plan
  static Future<String> getPlan() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPlan) ?? 'basic';
  }

  static Future<void> setPlan(String plan) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPlan, plan);
  }
}
