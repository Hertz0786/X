import 'package:kotlin/api/dto/post/create_post_oj.dart';
import 'package:kotlin/api/client/api_client.dart';

class PostService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CreatePostObject>> getUserPosts(String username, {String? token}) async {
    return await _apiClient.get<List<CreatePostObject>>(
      '/api/posts/user/$username',
      token: token,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => CreatePostObject.fromJson(e)).toList();
        } else {
          throw Exception('Dữ liệu không đúng định dạng danh sách.');
        }
      },
    );
  }
}
