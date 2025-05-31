import 'package:flutter/material.dart';
import 'package:kotlin/api/client/rp-ed/report_api.dart';

class ReportDialog extends StatefulWidget {
  final String id;
  final bool isComment;
  final ReportService reportService;

  const ReportDialog({
    super.key,
    required this.id,
    required this.isComment,
    required this.reportService,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập lý do báo cáo")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final msg = widget.isComment
          ? await widget.reportService.reportComment(widget.id, reason)
          : await widget.reportService.reportPost(widget.id, reason);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isComment ? 'Báo cáo bình luận' : 'Báo cáo bài viết'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: "Nhập lý do"),
        maxLines: 3,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Gửi"),
        ),
      ],
    );
  }
}
