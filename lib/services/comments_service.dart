import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CommentsResponse {
  final bool success;
  final List<String> data;
  final String message;

  const CommentsResponse({
    required this.success,
    required this.data,
    this.message = '',
  });

  bool get isSuccess => success;

  factory CommentsResponse.fromJson(Map<String, dynamic> j) {
    final ok = (j['success'] == true);
    final list = (j['data'] as List? ?? []).map((e) => e.toString()).toList();
    return CommentsResponse(
      success: ok,
      data: list,
      message: (j['message'] ?? '').toString(),
    );
  }
}

class CommentsService {
  CommentsService()
    : _base = (dotenv.env['API_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  final String _base;

  Future<CommentsResponse> fetchComments() async {
    if (_base.isEmpty) {
      throw StateError('Server URL is empty');
    }

    final uri = Uri.parse('$_base/comments.php');
    final res = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final parsed = CommentsResponse.fromJson(json);

    if (!parsed.isSuccess) {
      throw Exception(
        parsed.message.isNotEmpty ? parsed.message : 'Failed to load comments',
      );
    }
    return parsed;
  }

  /// helper: get preset strings.
  Future<List<String>> fetchCommentPresets() async {
    final r = await fetchComments();
    return r.data;
  }
}
