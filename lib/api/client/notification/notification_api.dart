import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/notification/notification_oj.dart';

class NotificationApi {
  final ApiClient apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final token = await TokenStorage.getToken();

    final List<dynamic> response = await apiClient.get(
      '/api/notifications/',
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );

    return response.map((item) => NotificationModel.fromJson(item)).toList();
  }

  Future<void> deleteAllNotifications() async {
    final token = await TokenStorage.getToken();

    await apiClient.delete(
      '/api/notifications',
      token: token,
    );
  }

  


}
