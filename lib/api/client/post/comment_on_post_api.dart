import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/post/comment_on_post_oj.dart';

class CommentOnPostApi {
  final ApiClient apiClient;

  CommentOnPostApi({required this.apiClient});

  Future<void> commentOnPost(CommentOnPostObject data) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("Không có token, vui lòng đăng nhập lại.");
    }

    await apiClient.post(
      '/api/comment/${data.id}',
      body: {'text': data.text},
      fromJson: (json) => null,
      token: token,
    );
  }
}
