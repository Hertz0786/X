import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/user/u.dart';

class SuggestedUsersApi {
  final ApiClient _apiClient;

  SuggestedUsersApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<UserModel>> getSuggestedUsers({String? token}) async {
    print("🌐 Đang gọi API gợi ý người dùng...");

    return await _apiClient.get<List<UserModel>>(
      '/api/users/suggested', // ✅ Sửa đường dẫn đúng như backend
      token: token,
      fromJson: (json) {
        print("✅ Phản hồi từ API gợi ý: $json"); // 🔍 Xem dữ liệu trả về

        final list = json as List;
        final users = list.map((item) => UserModel.fromJson(item)).toList();

        print("👥 Đã parse được ${users.length} người dùng được gợi ý");
        return users;
      },
    );
  }
}
