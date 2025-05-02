import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

class GetUserProfileApi {
  final ApiClient apiClient;

  GetUserProfileApi({required this.apiClient});

  Future<GetMeObject> fetchProfileByUsername(String username) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("Token không tồn tại");

    final response = await apiClient.post(
      '/api/users/profile/$username',
      token: token,
      body: {}, // 👈 Không cần gửi gì trong body
      fromJson: (json) => GetMeObject.fromJson(json),
    );
    return response;
  }
}
