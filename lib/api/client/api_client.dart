import 'dart:convert';
import 'package:http/http.dart' as http;

/// Định nghĩa kiểu hàm để chuyển đổi JSON thành đối tượng Dart.
/// Có thể là Map hoặc List tùy thuộc vào phản hồi từ API.
typedef FromJson<T> = T Function(dynamic json);

class ApiClient {
  final String baseUrl = "http://10.0.2.2:5000";

  ApiClient();

  /// Phương thức GET chung cho tất cả các API.
  Future<T> get<T>(
      String path, {
        required FromJson<T> fromJson,
        String? token,
      }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception('GET thất bại: ${response.statusCode} - ${response.body}');
    }
  }

  /// Phương thức POST chung cho tất cả các API.
  Future<T> post<T>(
      String path, {
        required dynamic body,
        required FromJson<T> fromJson,
        String? token,
      }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception('POST thất bại: ${response.statusCode} - ${response.body}');
    }
  }

  /// Phương thức DELETE chung cho tất cả các API.
  Future<void> delete(String path, {String? token}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('DELETE thất bại: ${response.statusCode} - ${response.body}');
    }
  }
}
