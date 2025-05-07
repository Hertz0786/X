import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';

class GetFollowingPostsApi {
  final ApiClient apiClient;

  GetFollowingPostsApi({required this.apiClient});

  Future<List<CreatePostObject>> fetchFollowingPosts(String token) async {
    return await apiClient.get<List<CreatePostObject>>(
      '/api/posts/following',
      token: token,
      fromJson: (json) {
        final postsJson = json['posts'] as List;
        return postsJson.map((e) => CreatePostObject.fromJson(e)).toList();
      },
    );
  }
}
