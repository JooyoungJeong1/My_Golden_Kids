import '../services/log_service.dart';

class UserSession {
  // ───────────────────────────────────────────
  // 현재 로그인 상태
  // ───────────────────────────────────────────
  static String? nickname;
  static String? email;
  static int? userId;
  static bool get isLoggedIn => nickname != null;

  // ───────────────────────────────────────────
  // 로그인 / 로그아웃
  // ───────────────────────────────────────────
  static void login(String email, String nick, {int? id}) {
    UserSession.email = email;
    UserSession.nickname = nick;
    UserSession.userId = id;
    LogService.log(action: 'login', detail: '로그인: $email');
  }

  static void logout() {
    LogService.log(action: 'logout', detail: '로그아웃: $email');
    email = null;
    nickname = null;
    userId = null;
  }

  // ───────────────────────────────────────────
  // 비로그인 사용자 식별용 임시 ID
  // ───────────────────────────────────────────
  static String? _deviceSessionId;

  static String get deviceSessionId {
    _deviceSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return _deviceSessionId!;
  }

  // ───────────────────────────────────────────
  // 프로필 이모지
  // ───────────────────────────────────────────
  static const List<String> profileEmojis = [
    '🌿',
    '🌱',
    '♻️',
    '🌍',
    '🌊',
    '🍃',
    '🌻',
    '🐢',
    '🦋',
    '🌈',
  ];

  static String profileEmoji = '🌿';

  static void changeProfileEmoji(String emoji) {
    profileEmoji = emoji;
    LogService.log(action: 'profile_change', detail: '프로필 변경: $emoji');
  }
}
