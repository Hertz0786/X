import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';
import 'package:kotlin/api/dto/post/create_post_oj.dart';

class CommentService {
  final ApiClient _apiClient;

  CommentService(this._apiClient);

  Future<CreatePostObject> commentOnPost(CommentOnPostObject comment) async {
    final String path = '/api/posts/comment/${comment.idpost}';

    final updatedPost = await _apiClient.post<CreatePostObject>(
      path,
      body: comment.toJson(),
      token: comment.token,
      fromJson: (json) {
        final postJson = json['post'];
        return CreatePostObject.fromJson(postJson);
      },
    );

    return updatedPost;
  }
}
