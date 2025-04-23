import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/id_storage.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';

class GetLikedPostApi {
  final ApiClient apiClient;

  GetLikedPostApi({required this.apiClient});

  Future<List<CreatePostObject>> fetchLikedPosts() async {
    final token = await TokenStorage.getToken();
    final userId = await IdStorage.getUserId(); // 👈 lấy id để gắn vào route

    if (token == null || userId == null) {
      throw Exception("Token hoặc User ID không tồn tại");
    }

    final response = await apiClient.get(
      '/api/posts/likes/$userId',
      token: token,
      fromJson: (json) {
        final postsJson = json['posts'] as List;
        return postsJson.map((e) => CreatePostObject.fromJson(e)).toList();
      },
    );

    return response;
  }
}
