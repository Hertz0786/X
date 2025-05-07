import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

class GetUser {
  final ApiClient apiClient;

  GetUser({required this.apiClient});

  // Phương thức lấy thông tin người dùng theo userId
  Future<GetMeObject> fetchProfileById(String userId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("Token không tồn tại");

    try {
      // Gọi API để lấy thông tin người dùng từ ID
      final response = await apiClient.get(
        '/api/users/profile/$userId',  // Đường dẫn API của bạn
        token: token,
        fromJson: (json) => GetMeObject.fromJson(json),  // Chuyển đổi JSON thành đối tượng GetMeObject
      );

      return response;
    } catch (e) {
      throw Exception("Lỗi khi lấy thông tin người dùng: $e");
    }
  }
}
