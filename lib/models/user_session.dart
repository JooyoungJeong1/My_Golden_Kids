import 'community.dart';
import '../services/log_service.dart';

class UserSession {
  static String? nickname;
  static String? email;
  static bool get isLoggedIn => nickname != null;
  static final List<String> guestNicknames = [];
  static final Map<String, Map<String, String>> accounts = {};

  // 닉네임 마지막 변경 시각 (이메일별로 관리)
  static final Map<String, DateTime> _lastNicknameChange = {};

  // 닉네임 변경 가능 여부
  static bool get canChangeNickname {
    if (email == null) return false;
    final last = _lastNicknameChange[email!];
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
  }

  // 닉네임 변경까지 남은 일수
  static int get daysUntilNicknameChange {
    if (email == null) return 0;
    final last = _lastNicknameChange[email!];
    if (last == null) return 0;
    final diff = DateTime.now().difference(last).inDays;
    return (7 - diff).clamp(0, 7);
  }

  // 닉네임 변경
  static void changeNickname(String newNickname) {
    if (!canChangeNickname) return;
    if (email == null) return;
    accounts[email!]!['nickname'] = newNickname;
    nickname = newNickname;
    _lastNicknameChange[email!] = DateTime.now();
    LogService.log(action: 'nickname_change', detail: '닉네임 변경: $newNickname');
  }

  // 비밀번호 변경
  static bool changePassword({required String current, required String newPw}) {
    if (email == null) return false;
    if (accounts[email!]!['password'] != current) return false;
    accounts[email!]!['password'] = newPw;
    LogService.log(action: 'password_change', detail: '비밀번호 변경');
    return true;
  }

  static bool isMyPost(CommunityPost post) {
    if (isLoggedIn) {
      return post.author == nickname || post.sessionId == deviceSessionId;
    }
    return post.sessionId == deviceSessionId;
  }

  static void login(String email, String nick) {
    UserSession.email = email;
    UserSession.nickname = nick;
    LogService.log(action: 'login', detail: '로그인: $email');
  }

  static void logout() {
    LogService.log(action: 'logout', detail: '로그아웃: $email');
    email = null;
    nickname = null;
  }

  static final List<CommunityPost> globalPosts = [];
  static String? _deviceSessionId;

  static String get deviceSessionId {
    _deviceSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return _deviceSessionId!;
  }

  // 선택 가능한 프로필 이미지 목록
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

  static String profileEmoji = '🌿'; // 현재 선택된 이미지

  static void changeProfileEmoji(String emoji) {
    profileEmoji = emoji;
    LogService.log(action: 'profile_change', detail: '프로필 변경: $emoji');
  }
}
