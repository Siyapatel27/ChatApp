import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;

String LoginPref = "LoginPref";

/*
LoginPref - whether user is logged in or not
EmailPref- user email-id
*/

class Preference {
  static String LoginPref = "LoginPref";
  static String EmailPref = "EmailPref";
  static String NamePref = "NamePref";
  static String UserIdPref = "UserIdPref";
  static String UserThemePref = "UserThemePref";
}

Future<int> getIntPrefs(String key) async {
  prefs = await SharedPreferences.getInstance();
  return prefs?.getInt(key) ?? 0;
}

Future<bool> setIntPrefs(String key, int value) async {
  prefs = await SharedPreferences.getInstance();
  return prefs!.setInt(key, value);
}

//bool
Future<bool> getBoolPrefs(String key) async {
  prefs = await SharedPreferences.getInstance();
  return prefs?.getBool(key) ?? false;
}

Future<bool> setBoolPrefs(String key, bool value) async {
  prefs = await SharedPreferences.getInstance();
  return prefs!.setBool(key, value);
}

//String
Future<String> getStringPrefs(String key) async {
  prefs = await SharedPreferences.getInstance();
  return prefs?.getString(key) ?? '';
}

Future<bool> setStringPrefs(String key, String value) async {
  prefs = await SharedPreferences.getInstance();
  return prefs!.setString(key, value);
}

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
}
