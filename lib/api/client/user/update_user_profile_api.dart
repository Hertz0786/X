import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/user/update_user_profile_oj.dart';

class UpdateUserProfileApi {
  final ApiClient apiClient;

  UpdateUserProfileApi({required this.apiClient});

  Future<void> updateProfile(UpdateUserProfile profileData) async {
    final token = profileData.token;

    await apiClient.post<void>(
      '/api/users/update', // endpoint backend đang dùng
      body: profileData.toJson(),
      fromJson: (_) => null, // Không cần dữ liệu trả về
      token: token,
    );
  }
}
