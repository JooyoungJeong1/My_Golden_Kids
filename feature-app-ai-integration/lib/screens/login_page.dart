import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';
import 'signup_page.dart';

// ───────────────────────────────────────────
// 로그인 페이지
// ───────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMsg;
  bool _isLoading = false;

  void _login() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = '아이디와 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // 백엔드 로그인 API 호출 (email 필드에 아이디 전달)
      final data = await ApiService.login(email: id, password: password);

      if (data['detail'] != null) {
        setState(() => _errorMsg = data['detail']);
        return;
      }

      // 로그인 성공 - userId도 저장
      UserSession.login(id, data['nickname'], id: data['id']);
      UserSession.profileEmoji = data['profile_emoji'] ?? '🌿';

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() => _errorMsg = '서버 연결에 실패했어요. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            const Text(
              '🌿',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              '버릴래말래에 오신걸 환영해요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: '아이디',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                hintText: '비밀번호',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMsg!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
              ),
            ],
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _isLoading ? null : _login,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF5D4037),
                          strokeWidth: 2,
                        )
                      : const Text(
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
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                );
              },
              child: const Center(
                child: Text(
                  '아직 계정이 없으신가요? 회원가입',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
