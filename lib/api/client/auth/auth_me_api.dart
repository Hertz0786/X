import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = "http://10.0.2.2:6969"; // Đảm bảo URL đúng của backend

  ApiClient();

  // Gửi yêu cầu GET với token và nhận thông tin người dùng
  Future<Map<String, dynamic>> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/login_page/me'), // API getMe
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Gửi token ở header Authorization
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Trả về dữ liệu người dùng dưới dạng JSON
    } else {
      throw Exception('Lỗi khi gọi API: ${response.body}');
    }
  }
}
