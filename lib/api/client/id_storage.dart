import 'package:shared_preferences/shared_preferences.dart';

class IdStorage {
  static const _userIdKey = 'user_id';

  // Lưu userId
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Lấy userId
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Xóa userId
  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // Kiểm tra userId có tồn tại không (debug)
  static Future<void> checkUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    if (userId != null) {
      print('User ID đã lưu: $userId');
    } else {
      print('User ID chưa được lưu');
    }
  }
}
