import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';

class LikeUnlikePostApi {
  final ApiClient apiClient;

  LikeUnlikePostApi({required this.apiClient});

  Future<CreatePostObject> likeOrUnlikePost({
    required String postId,
    required String token,
  }) async {
    final response = await apiClient.post(
      '/api/posts/like/$postId',
      token: token,
      body: {}, // body rỗng, chỉ cần token
      fromJson: (json) => CreatePostObject.fromJson(json['post']),
    );

    return response;
  }
}
