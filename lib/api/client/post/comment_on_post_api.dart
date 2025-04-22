import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';

class CommentService {
  final ApiClient _apiClient;

  CommentService(this._apiClient);

  Future<void> commentOnPost(CommentOnPostObject comment) async {
    final String path = '/api/posts/${comment.idpost}/comment';

    await _apiClient.post<void>(
      path,
      body: comment.toJson(),
      token: comment.token,
      fromJson: (_) => null, // Không cần decode object trả về
    );
  }
}
