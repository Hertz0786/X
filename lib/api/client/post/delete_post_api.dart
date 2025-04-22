import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';

class DeletePostApi {
  final ApiClient apiClient;

  DeletePostApi({required this.apiClient});

  Future<void> deletePost(String postId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception("Không tìm thấy token");
    }

    await apiClient.delete(
      '/api/posts/$postId',
      token: token,
    );
  }
}
