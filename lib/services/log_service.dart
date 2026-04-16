import 'package:flutter/foundation.dart';

// ───────────────────────────────────────────
// 로그 서비스 (백엔드 연결 시 API 호출로 교체)
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
  // 로컬 로그 저장 (백엔드 연결 전 임시)
  static final List<LogEntry> _logs = [];
  static List<LogEntry> get logs => List.unmodifiable(_logs);

  static void log({
    required String action,
    required String detail,
    String? userEmail,
  }) {
    final entry = LogEntry(
      action: action,
      detail: detail,
      timestamp: DateTime.now(),
      userEmail: userEmail,
    );

    // 로컬 저장
    _logs.add(entry);

    // TODO: 백엔드 연결 시 아래 주석 해제
    // await ApiService.sendLog(entry.toJson());

    // 디버그용 출력
    debugPrint('[LOG] ${entry.timestamp} | ${entry.action} | ${entry.detail}');
  }
}
