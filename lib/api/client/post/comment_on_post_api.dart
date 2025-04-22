import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';


class CommentOnPostApi {
  final ApiClient apiClient;

  CommentOnPostApi({required this.apiClient});

  Future<void> commentOnPost({
    required String postId,
    required String text,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception("Không có token, vui lòng đăng nhập lại.");
    }

    final commentData = await CommentOnPostObject.fromLocalStorage(
      id: postId,
      text: text,
      token: token,
    );

    await apiClient.post(
      '/api/comment/${commentData.id}', // ✅ route chuẩn
      body: commentData.toJson(),       // ✅ chứa text + user
      fromJson: (json) => null,
      token: token,
    );
  }
}
