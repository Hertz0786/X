import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

class GetMeApi {
  final ApiClient apiClient;

  GetMeApi({required this.apiClient});

  Future<UserObject> getMe() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception("Token không tồn tại. Vui lòng đăng nhập.");
    }

    return await apiClient.get(
      '/api/auth/me',
      fromJson: (json) => UserObject.fromJson(json),
      token: token,
    );
  }
}
