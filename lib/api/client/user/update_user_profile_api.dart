import 'package:kotlin/api/client/api_client.dart';
import  'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/user/update_user_profile_oj.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> updateUserProfile(
      UserProfileUpdateRequest request, {
        required String? token,
      }) async {
    try {
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/api/users/update',
        body: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
        token: token,
      );
      print("✅ API call succeeded: $result");
      return result;
    } catch (e) {
      print("❌ API call failed in UserRepository: $e");
      rethrow;
    }
  }
}