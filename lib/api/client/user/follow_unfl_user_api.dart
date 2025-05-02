import 'package:kotlin/api/client/api_client.dart';

class FollowUnfollowUserApi {
  final ApiClient apiClient;

  FollowUnfollowUserApi({required this.apiClient});

  Future<bool> followOrUnfollow(String userId, String token) async {
    try {
      await apiClient.post<bool>(
        '/api/users/follow/$userId',
        body: {}, // Gửi body rỗng
        fromJson: (_) => true, // Không cần dữ liệu trả về
        token: token,
      );
      return true;
    } catch (e) {
      print("Lỗi follow/unfollow: $e");
      return false;
    }
  }
}
