import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/client/rp-ed/report_request_dto.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  Future<void> reportPost({
    required String postId,
    required ReportRequestDto dto,
  }) async {
    final token = await TokenStorage.getToken(); // ✅ Lấy token
    if (token == null) throw Exception('Không tìm thấy token');

    await _apiClient.post<Map<String, dynamic>>(
      '/api/posts/report/post/$postId',
      body: dto.toJson(),
      token: token, // ✅ Gửi kèm token
      fromJson: (json) => json,
    );
  }

  Future<void> reportComment({
    required String commentId,
    required ReportRequestDto dto,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Không tìm thấy token');

    await _apiClient.post<Map<String, dynamic>>(
      '/api/posts/report/comment/$commentId',
      body: dto.toJson(),
      token: token,
      fromJson: (json) => json,
    );
  }
}
