import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/token_storage.dart';
import 'package:kotlin/api/dto/search/post_search_oj.dart';
import 'package:kotlin/api/dto/search/user_search_oj.dart';

class PostApi {
  final _client = ApiClient();

  Future<List<PostSearchResult>> searchPosts(String query) async {
    final token = await TokenStorage.getToken();

    // Gửi yêu cầu tới API với từ khóa tìm kiếm
    final result = await _client.get<Map<String, dynamic>>(
      '/api/search/posts?search=$query',
      token: token,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // In ra cấu trúc của dữ liệu để kiểm tra (Debugging)
    print(result);

    // Kiểm tra trường 'posts' trong phản hồi và chuyển đổi thành List<PostSearchResult>
    final List data = result['posts'] ?? [];

    // Trả về danh sách các bài viết
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
