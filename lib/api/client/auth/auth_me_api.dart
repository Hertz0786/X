import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/auth/get_me_oj.dart';

class AuthMeApi {
  final ApiClient apiClient;

  AuthMeApi({required this.apiClient});

  Future<GetMeObject> fetchCurrentUser() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("Token không tồn tại");

    final response = await apiClient.post(
      '/api/auth/me',
      token: token,
      body: {},
      fromJson: (json) => GetMeObject.fromJson(json),
    );

    return response;
  }
}
