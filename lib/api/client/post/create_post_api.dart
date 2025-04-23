import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/token_storage.dart';

class CreatePostApi {
  final ApiClient apiClient;

  CreatePostApi({required this.apiClient});

  // Hàm để tạo bài viết
  Future<CreatePostObject> createPost(CreatePostObject postData) async {
    try {
      // Lấy token từ TokenStorage
      final token = await TokenStorage.getToken();

      if (token == null) {
        throw Exception("Token không có sẵn, vui lòng đăng nhập lại.");
      }

      // Gửi yêu cầu POST đến API với header chứa token
      final response = await apiClient.post(
        '/api/posts/create',  // Endpoint để tạo bài viết
        body: postData.toJson(),
        fromJson: (json) => CreatePostObject.fromJson(json),
        token: token,  // Truyền token vào header
      );
      return response;  // Trả về bài viết đã được tạo
    } catch (error) {
      rethrow;  // Ném lại lỗi nếu có
    }
  }
}
