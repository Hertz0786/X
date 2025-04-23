import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/token_storage.dart';

class GetAllPostApi {
  final ApiClient apiClient;

  GetAllPostApi({required this.apiClient});

  Future<List<CreatePostObject>> fetchPosts() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("Token không tồn tại.");
    }

    final response = await apiClient.get(
      '/api/posts/all',
      fromJson: (json) {
        final postsJson = json['posts'] as List;
        return postsJson.map((e) => CreatePostObject.fromJson(e)).toList();
      },
      token: token,
    );

    return response;
  }
}
