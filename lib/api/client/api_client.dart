import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kotlin/api/client/id_storage.dart';  // Thêm IdStorage

typedef FromJson<T> = T Function(dynamic json);

class ApiClient {
  final String baseUrl = "http://10.0.2.2:5000";  // URL của API server

  ApiClient();

  // Lấy userId từ IdStorage
  Future<String?> _getUserId() async {
    return await IdStorage.getUserId();
  }

  // GET request
  Future<T> get<T>(String path, {required FromJson<T> fromJson, String? token}) async {
    final userId = await _getUserId();  // Lấy userId từ IdStorage
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (userId != null) 'userId': userId,  // Thêm userId vào header nếu có
    };

    try {
      final response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Dữ liệu trả về từ API: $data");
        return fromJson(data);
      } else {
        throw Exception('GET thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Lỗi khi thực hiện GET yêu cầu: $e");
      throw Exception('Lỗi khi thực hiện GET yêu cầu: $e');
    }
  }

  // POST request
  Future<T> post<T>(String path, {required dynamic body, required FromJson<T> fromJson, String? token}) async {
    final userId = await _getUserId();  // Lấy userId từ IdStorage
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (userId != null) 'userId': userId,  // Thêm userId vào header nếu có
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        print("Response body: ${response.body}");
        throw Exception('POST thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Lỗi khi thực hiện POST yêu cầu: $e");
      throw Exception('Lỗi khi thực hiện POST yêu cầu: $e');
    }
  }

  // DELETE request
  Future<void> delete(String path, {String? token}) async {
    final userId = await _getUserId();  // Lấy userId từ IdStorage
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (userId != null) 'userId': userId,  // Thêm userId vào header nếu có
    };

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print("Response body: ${response.body}");
        throw Exception('DELETE thất bại: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Lỗi khi thực hiện DELETE yêu cầu: $e");
      throw Exception('Lỗi khi thực hiện DELETE yêu cầu: $e');
    }
  }
}
