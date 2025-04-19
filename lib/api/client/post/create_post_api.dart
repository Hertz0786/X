// create_post_api.dart

import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';

class CreatePostApi {
  final ApiClient apiClient;

  CreatePostApi({required this.apiClient});

  // Hàm để tạo bài viết
  Future<CreatePostObject> createPost(CreatePostObject postData) async {
    try {
      final response = await apiClient.post(
        '/posts',  // Endpoint để tạo bài viết
        body: postData.toJson(),
        fromJson: (json) => CreatePostObject.fromJson(json),
      );
      return response;  // Trả về bài viết đã được tạo
    } catch (error) {
      rethrow;  // Ném lại lỗi nếu có
    }
  }
}
