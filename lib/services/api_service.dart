import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String? _cachedBaseUrl;
  static int? userId;
  static String? sessionId;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // ════════════════════════════════
  // Base URL (자동 탐색)
  // ════════════════════════════════

  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    final candidates = ['http://219.248.12.141:8000', 'http://10.0.2.2:8000'];

    final futures = candidates.map((url) async {
      final res = await http
          .get(Uri.parse('$url/docs'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) return url;
      throw Exception('failed');
    });

    try {
      _cachedBaseUrl = await Future.any(futures);
    } catch (_) {
      _cachedBaseUrl = 'http://219.248.12.141:8000';
    }
    return _cachedBaseUrl!;
  }

  // ════════════════════════════════
  // 인증
  // ════════════════════════════════

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String nickname,
    required String password,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/auth/signup'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'nickname': nickname,
        'password': password,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data['id'] != null) userId = data['id'];
    return data;
  }

  static Future<Map<String, dynamic>> changeNickname({
    required int userId,
    required String newNickname,
  }) async {
    final base = await getBaseUrl();
    final res = await http.patch(
      Uri.parse('$base/auth/nickname'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'new_nickname': newNickname}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final base = await getBaseUrl();
    final res = await http.patch(
      Uri.parse('$base/auth/password'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> changeProfileEmoji({
    required int userId,
    required String emoji,
  }) async {
    final base = await getBaseUrl();
    final res = await http.patch(
      Uri.parse('$base/auth/profile-emoji'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'emoji': emoji}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ════════════════════════════════
  // 커뮤니티
  // ════════════════════════════════

  static Future<List<dynamic>> getPosts() async {
    final base = await getBaseUrl();
    final res = await http.get(
      Uri.parse('$base/community/posts'),
      headers: _headers,
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> createPost({
    required String authorNickname,
    required String title,
    required String content,
    int? userId,
    String? sessionId,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/community/posts'),
      headers: _headers,
      body: jsonEncode({
        'author_nickname': authorNickname,
        'title': title,
        'content': content,
        'user_id': userId,
        'session_id': sessionId,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> deletePost({
    required int postId,
    int? userId,
    String? sessionId,
  }) async {
    final base = await getBaseUrl();
    final uri = Uri.parse('$base/community/posts/$postId').replace(
      queryParameters: {'user_id': userId?.toString(), 'session_id': sessionId}
        ..removeWhere((key, value) => value == null),
    );
    final res = await http.delete(uri, headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> createComment({
    required int postId,
    required String authorNickname,
    required String content,
    int? userId,
    String? sessionId,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/community/posts/$postId/comments'),
      headers: _headers,
      body: jsonEncode({
        'author_nickname': authorNickname,
        'content': content,
        'user_id': userId,
        'session_id': sessionId,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> toggleLike({
    required int postId,
    int? userId,
    String? sessionId,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/community/posts/$postId/like'),
      headers: _headers,
      body: jsonEncode({'user_id': userId, 'session_id': sessionId}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> reportPost({
    required int postId,
    required String reporterEmail,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/community/posts/$postId/report'),
      headers: _headers,
      body: jsonEncode({'reporter_email': reporterEmail}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<List<dynamic>> getMyPosts({
    int? userId,
    String? sessionId,
  }) async {
    final base = await getBaseUrl();
    final uri = Uri.parse('$base/community/posts/my').replace(
      queryParameters: {'user_id': userId?.toString(), 'session_id': sessionId}
        ..removeWhere((key, value) => value == null),
    );
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<List<dynamic>> getMyComments({
    int? userId,
    String? sessionId,
  }) async {
    final base = await getBaseUrl();
    final uri = Uri.parse('$base/community/comments/my').replace(
      queryParameters: {'user_id': userId?.toString(), 'session_id': sessionId}
        ..removeWhere((key, value) => value == null),
    );
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ════════════════════════════════
  // 사진 분석
  // ════════════════════════════════

  static Future<Map<String, dynamic>> analyzePhoto(
    List<int> imageBytes,
    String filename,
  ) async {
    final base = await getBaseUrl();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$base/photo/analyze'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
    );
    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ════════════════════════════════
  // 로그
  // ════════════════════════════════

  static Future<void> sendLog(Map<String, dynamic> logData) async {
    try {
      final base = await getBaseUrl();
      await http.post(
        Uri.parse('$base/logs'),
        headers: _headers,
        body: jsonEncode(logData),
      );
    } catch (e) {
      debugPrint('로그 전송 실패: $e');
    }
  }

  // ════════════════════════════════
  // 문의
  // ════════════════════════════════

  static Future<Map<String, dynamic>> submitInquiry({
    required String email,
    required String content,
  }) async {
    final base = await getBaseUrl();
    final res = await http.post(
      Uri.parse('$base/logs'),
      headers: _headers,
      body: jsonEncode({
        'action': 'inquiry',
        'detail': content,
        'user_email': email,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ════════════════════════════════
  // AI 연결 확인
  // ════════════════════════════════

  static Future<bool> checkConnection() async {
    try {
      final base = await getBaseUrl();
      final res = await http
          .get(Uri.parse('$base/docs'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
