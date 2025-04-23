import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
class TokenStorage {
  static const _tokenKey = 'user_token';

  // Lưu token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Lấy token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Xóa token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Kiểm tra token đã được lưu chưa
  static Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null) {
      print('Token đã được lưu: $token');
    } else {
      print('Token chưa được lưu');
    }
  }

  // static Future<String?> getUserIdFromToken() async {
  //   final token = await getToken();
  //   if (token == null) return null;
  //
  //   try {
  //     final parts = token.split('.');
  //     if (parts.length != 3) return null;
  //
  //     final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  //     final Map<String, dynamic> json = jsonDecode(payload);
  //     return json['id'] ?? json['_id']; // tùy backend gán key là gì
  //   } catch (_) {
  //     return null;
  //   }
  // }

}
