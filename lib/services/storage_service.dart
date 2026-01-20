import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../types.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  static const String _userBoxName = 'userBox';

  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_profile';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_userBoxName);
  }

  Future<void> saveToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  String? getToken() {
    return _box.get(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _box.put(_userKey, user.toJson());
  }

  User? getUser() {
    final data = _box.get(_userKey);
    if (data != null) {
      try {
        return User.fromJson(Map<String, dynamic>.from(data));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
