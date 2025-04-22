import '../api_client.dart';  // Import ApiClient
import 'package:kotlin/api/dto/auth/login_oj.dart'; // Import LoginObject

class AuthApi {
  final ApiClient _apiClient = ApiClient();

  // Hàm đăng nhập sử dụng LoginObject
  Future<Map<String, dynamic>> login(LoginObject loginObject) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      body: loginObject.toJson(),
      fromJson: (json) => json,
    );

    print("📨 Phản hồi login: $response");

    // ✅ Trả lại toàn bộ JSON response (gồm token, id, username, ...)
    if (response != null && (response['accessToken'] != null || response['token'] != null)) {
      return response;
    } else {
      throw Exception('Phản hồi không có token');
    }
  }

}
