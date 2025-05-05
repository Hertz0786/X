import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/mess//user_model.dart';

class UserApi {
  final _client = ApiClient();

  Future<List<UserModel>> getUsersForSidebar() async {
    final token = await TokenStorage.getToken();

    final response = await _client.get<List<dynamic>>(
      '/api/messages/users',
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );

    return response.map((e) => UserModel.fromJson(e)).toList();
  }
}
