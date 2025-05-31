import 'package:kotlin/api/client/api_client.dart';
import 'report_request_dto.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  Future<void> reportPost({
    required String postId,
    required ReportRequestDto dto,
  }) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/api/posts/$postId/report',
        body: dto.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportComment({
    required String commentId,
    required ReportRequestDto dto,
  }) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/api/comments/$commentId/report',
        body: dto.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
