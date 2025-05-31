import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';

class PostService {
  final ApiClient apiClient;

  PostService(this.apiClient);

  Future<List<CreatePostObject>> getUserPosts(String username, {required String token}) async {
    return await apiClient.get<List<CreatePostObject>>(
      "/api/posts/user/$username",
      token: token,
      fromJson: (json) {
        final posts = (json['posts'] as List)
            .map((e) => CreatePostObject.fromJson(e as Map<String, dynamic>))
            .toList();
        return posts;
      },
    );
  }
}
