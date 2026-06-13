import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';

// ───────────────────────────────────────────
// 회원가입 페이지
// ───────────────────────────────────────────

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  String? _errorMsg;

  // ───────────────────────────────────────────
  // 아이디 형식 검증 (영문+숫자, 4~20자)
  // ───────────────────────────────────────────
  bool _isValidId(String id) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(id) && id.isNotEmpty;
  }

  // ───────────────────────────────────────────
  // 비밀번호 강도 검증 (4자 이상)
  // ───────────────────────────────────────────
  bool _isValidPassword(String password) {
    return password.length >= 4;
  }

  // ───────────────────────────────────────────
  // 비밀번호 강도 점수 (0~4)
  // ───────────────────────────────────────────
  int _passwordStrength(String pw) {
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Za-z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[*^%#$@!]'))) score++;
    return score;
  }

  void _signup() async {
    final nickname = _nicknameController.text.trim();
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _passwordConfirmController.text.trim();

    if (nickname.isEmpty || id.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = '모든 항목을 입력해주세요.');
      return;
    }

    if (!_isValidId(id)) {
      setState(() => _errorMsg = '아이디는 영문 또는 숫자만 입력해주세요.');
      return;
    }

    if (!_isValidPassword(password)) {
      setState(() => _errorMsg = '비밀번호는 4자리 이상이어야 해요.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMsg = '비밀번호가 일치하지 않아요.');
      return;
    }

    try {
      // 백엔드 회원가입 API 호출
      final result = await ApiService.signup(
        email: id,
        password: password,
        nickname: nickname,
      );

      if (result['error'] != null) {
        setState(() => _errorMsg = result['error']);
        return;
      }

      // 자동 로그인
      UserSession.login(id, nickname);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMsg = '회원가입 중 오류가 발생했어요. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),

            // 닉네임
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '닉네임',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 아이디
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: '아이디 (영문 또는 숫자)',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 비밀번호
            TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: (_) => setState(() {}), // 강도 표시 실시간 업데이트
              decoration: InputDecoration(
                hintText: '비밀번호 (4자리 이상)',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // 비밀번호 강도 표시바
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPasswordStrengthBar(_passwordController.text),
            ],

            const SizedBox(height: 10),

            // 비밀번호 확인
            TextField(
              controller: _passwordConfirmController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE53935),
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 18),

            // 가입 버튼
            GestureDetector(
              onTap: _signup,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // 비밀번호 강도 표시바 위젯
  // ───────────────────────────────────────────
  Widget _buildPasswordStrengthBar(String pw) {
    final strength = _passwordStrength(pw);
    final colors = [
      Colors.transparent,
      const Color(0xFFE53935), // 1 - 빨강
      const Color(0xFFFF9800), // 2 - 주황
      const Color(0xFFFDD835), // 3 - 노랑
      const Color(0xFF4CAF50), // 4 - 초록
    ];
    final labels = ['', '너무 약해요', '약해요', '보통이에요', '강해요!'];
    final color = strength > 0 ? colors[strength] : colors[1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < strength ? color : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          labels[strength],
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
