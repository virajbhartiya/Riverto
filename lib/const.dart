import 'package:shared_preferences/shared_preferences.dart';

class Const {
  static void setValues(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    await prefs.setBool("logIn", true);
  }

  static void logIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logIn", true);
  }
}
