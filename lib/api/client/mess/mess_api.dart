import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/mess/mess_oj.dart';
import 'package:kotlin/api/dto/mess/chat_user.dart';

class MessageApi {
  final _client = ApiClient();

  Future<List<MessageModel>> getMessagesWithUser(String userId) async {
    final token = await TokenStorage.getToken();

    final response = await _client.get<List<dynamic>>(
      '/api/messages/$userId',
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );

    return response.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<List<ChatUser>> getChatPartners() async {
    final token = await TokenStorage.getToken();
    final res = await _client.get<List<dynamic>>(
      '/api/messages/chats',
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
    return res.map((e) => ChatUser.fromJson(e)).toList();
  }


  Future<MessageModel> sendMessage({
    required String receiverId,
    String? text,
    String? imageBase64,
  }) async {
    final token = await TokenStorage.getToken();

    final body = {
      if (text != null) 'text': text,
      if (imageBase64 != null) 'image': 'data:image/jpeg;base64,$imageBase64',
    };

    final result = await _client.post<Map<String, dynamic>>(
      '/api/messages/send/$receiverId',
      token: token,
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return MessageModel.fromJson(result);
  }
}
