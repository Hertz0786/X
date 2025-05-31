import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/id_storage.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService({required this.apiClient});

  Future<String> reportComment(String commentId, String reason) async {
    final token = await TokenStorage.getToken();
    final userId = await IdStorage.getUserId();

    if (token == null || userId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final body = {
      "reason": reason,
    };

    return await apiClient.post<String>(
      '/api/posts/report/comment/$commentId',
      body: body,
      token: token,
      fromJson: (json) => json['message'] ?? 'Báo cáo thành công',
    );
  }

  Future<String> reportPost(String postId, String reason) async {
    final token = await TokenStorage.getToken();
    final userId = await IdStorage.getUserId();

    if (token == null || userId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final body = {
      "reason": reason,
    };

    return await apiClient.post<String>(
      '/api/posts/report/post/$postId',
      body: body,
      token: token,
      fromJson: (json) => json['message'] ?? 'Báo cáo thành công',
    );
  }
}
