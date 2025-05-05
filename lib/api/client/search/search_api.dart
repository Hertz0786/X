import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/search/post_search_oj.dart';
import 'package:kotlin/api/dto/search/user_search_oj.dart';

class PostApi {
  final _client = ApiClient();

  Future<List<PostSearchResult>> searchPosts(String query) async {
    final token = await TokenStorage.getToken();
    final result = await _client.get<Map<String, dynamic>>(
      '/api/search/posts?search=$query',
      token: token,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    final List data = result['posts'] ?? [];
    return data.map((e) => PostSearchResult.fromJson(e)).toList();
  }
}
class UserApi {
  final _client = ApiClient();

  Future<List<UserSearchResult>> searchUsers(String query) async {
    final token = await TokenStorage.getToken();

    final result = await _client.get<Map<String, dynamic>>(
      '/api/search/users?search=$query',
      token: token,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    final List data = result['users'] ?? [];
    return data.map((e) => UserSearchResult.fromJson(e)).toList();
  }
}
