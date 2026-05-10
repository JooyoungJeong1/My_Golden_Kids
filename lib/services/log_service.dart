import 'package:flutter/foundation.dart';
import 'api_service.dart';

// ───────────────────────────────────────────
// 로그 서비스 (백엔드 연결)
// ───────────────────────────────────────────

class LogEntry {
  final String action;
  final String detail;
  final DateTime timestamp;
  final String? userEmail;

  LogEntry({
    required this.action,
    required this.detail,
    required this.timestamp,
    this.userEmail,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'detail': detail,
    'timestamp': timestamp.toIso8601String(),
    'userEmail': userEmail,
  };
}

class LogService {
  static Future<void> log({
    required String action,
    required String detail,
    String? userEmail,
  }) async {
    final entry = LogEntry(
      action: action,
      detail: detail,
      timestamp: DateTime.now(),
      userEmail: userEmail,
    );

    // 백엔드로 로그 전송
    await ApiService.sendLog(entry.toJson());

    // 디버그용 출력
    debugPrint('[LOG] ${entry.timestamp} | ${entry.action} | ${entry.detail}');
  }
}
