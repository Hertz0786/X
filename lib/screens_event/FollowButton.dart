import 'package:flutter/material.dart';
import 'package:kotlin/api/client/api_client.dart';
import 'package:kotlin/api/client/user/follow_unfl_user_api.dart';
import 'package:kotlin/api/client/token_storage.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final bool isInitiallyFollowing;
  final void Function(bool isNowFollowing)? onChanged;

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.isInitiallyFollowing,
    this.onChanged,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isInitiallyFollowing;
  }

  Future<void> _toggleFollow() async {
    final token = await TokenStorage.getToken();
    if (token == null) return;

    final success = await FollowUnfollowUserApi(apiClient: ApiClient())
        .followOrUnfollow(widget.targetUserId, token);

    if (success) {
      setState(() {
        isFollowing = !isFollowing;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(isFollowing);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _toggleFollow,
      child: Text(
        isFollowing ? "Đang theo dõi" : "Theo dõi",
        style: TextStyle(
          color: isFollowing ? Colors.grey : Colors.blueAccent,
        ),
      ),
    );
  }
}
