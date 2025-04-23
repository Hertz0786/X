import 'dart:convert';
import 'package:http/http.dart' as http;

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class ApiClient {
  final String baseUrl = "http://10.0.2.2:5000";

  ApiClient();

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
      throw Exception('GET thất bại: ${response.body}');
    }
  }

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
      throw Exception('POST thất bại: ${response.body}');
    }
  }

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
      throw Exception('DELETE thất bại: ${response.body}');
    }
  }

}
