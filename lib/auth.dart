import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('access_token');
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
