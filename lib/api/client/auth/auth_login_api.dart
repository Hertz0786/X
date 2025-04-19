import '../api_client.dart';  // Import ApiClient
import 'package:kotlin/api/dto/auth/login_oj.dart'; // Import LoginObject

class AuthApi {
  final ApiClient _apiClient = ApiClient();

  // Hàm đăng nhập sử dụng LoginObject
  Future<Map<String, dynamic>> login(LoginObject loginObject) async {
    final response = await _apiClient.post(
      '/api/auth/login',  // Địa chỉ API đăng nhập
      body: loginObject.toJson(),  // Chuyển đổi LoginObject thành JSON
      fromJson: (json) => json,  // Dữ liệu trả về từ API (có thể là token, thông tin người dùng...)
    );
    print("$response");

    // Kiểm tra phản hồi và lấy accessToken từ response
    if (response != null && response['accessToken'] != null) {
      return {'token': response['accessToken']};  // Trả về accessToken nếu có
    } else {
      throw Exception('accessToken không tồn tại trong phản hồi');
    }
  }
}
