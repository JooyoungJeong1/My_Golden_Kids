import 'package:flutter/material.dart';
import '../models/user_session.dart';
import 'community_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'nickname_change_page.dart';
import 'password_change_page.dart';

// ───────────────────────────────────────────
// 마이페이지
// ───────────────────────────────────────────

class MyPage extends StatefulWidget {
  const MyPage({super.key});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: UserSession.isLoggedIn ? _buildLoggedIn() : _buildLoggedOut(),
      ),
    );
  }

  Widget _buildLoggedIn() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 프로필 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDD835), width: 1.5),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showProfilePicker(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDD835),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      UserSession.profileEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UserSession.nickname ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    UserSession.email ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildMenuTile('✏️', '내가 쓴 글', '작성한 게시글 보기', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CommunityPage(initialTab: 1), // ← 탭 인덱스 전달
            ),
          );
        }),
        const SizedBox(height: 10),
        _buildMenuTile('💬', '내가 쓴 댓글', '작성한 댓글 보기', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CommunityPage(initialTab: 2), // ← 탭 인덱스 전달
            ),
          );
        }),

        const SizedBox(height: 10),
        _buildMenuTile('👤', '닉네임 변경', '7일에 한 번 변경 가능', () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NicknameChangePage()),
          );
          if (changed == true) setState(() {});
        }),
        const SizedBox(height: 10),
        _buildMenuTile('🔒', '비밀번호 변경', '현재 비밀번호 확인 후 변경', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PasswordChangePage()),
          );
        }),

        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            UserSession.logout();
            Navigator.pop(context);
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
            ),
            child: const Center(
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOut() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Text('👤', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text(
                '로그인이 필요해요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '로그인하면 내가 쓴 글과\n댓글을 확인할 수 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
            setState(() {});
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFDD835),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                '로그인',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5D4037),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupPage()),
            );
            setState(() {});
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
            ),
            child: const Center(
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBBBBBB)),
          ],
        ),
      ),
    );
  }

  void _showProfilePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '프로필 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: UserSession.profileEmojis
                  .map(
                    (emoji) => GestureDetector(
                      onTap: () {
                        UserSession.changeProfileEmoji(emoji);
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: UserSession.profileEmoji == emoji
                              ? const Color(0xFFFDD835)
                              : const Color(0xFFF0EEF1),
                          shape: BoxShape.circle,
                          border: UserSession.profileEmoji == emoji
                              ? Border.all(
                                  color: const Color(0xFFF9A825),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
