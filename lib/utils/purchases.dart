import 'package:shared_preferences/shared_preferences.dart';

const String IS_PURCHASED_KEY = "PREMIUM_IS_PURCHASED_KEY";

class Purchases {
  static Future<bool> isPremiumPurchased() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(IS_PURCHASED_KEY) ?? false;
  }

  static Future<void> setPremiumPurchased() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(IS_PURCHASED_KEY, true);
  }
}
