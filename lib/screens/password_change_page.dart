import 'package:flutter/material.dart';
import '../models/user_session.dart';

// ───────────────────────────────────────────
// 비밀번호 변경 페이지
// ───────────────────────────────────────────

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});
  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorMsg;
  String? _successMsg;

  // ───────────────────────────────────────────
  // 비밀번호 강도 검증 (영어 + 숫자 + 특수문자 + 8자 이상)
  // ───────────────────────────────────────────
  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Za-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[*^%#$@!]'))) return false;
    return true;
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

  void _submit() {
    final current = _currentController.text.trim();
    final newPw = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      setState(() => _errorMsg = '모든 항목을 입력해주세요.');
      return;
    }

    // 비밀번호 강도 검증
    if (!_isValidPassword(newPw)) {
      setState(
        () => _errorMsg = '비밀번호는 영어, 숫자, 특수문자(*^%#\$@!)를\n포함한 8자 이상이어야 해요.',
      );
      return;
    }

    if (newPw != confirm) {
      setState(() => _errorMsg = '새 비밀번호가 일치하지 않아요.');
      return;
    }
    if (newPw == current) {
      setState(() => _errorMsg = '현재 비밀번호와 동일해요.');
      return;
    }

    final success = UserSession.changePassword(current: current, newPw: newPw);
    if (!success) {
      setState(() => _errorMsg = '현재 비밀번호가 올바르지 않아요.');
      return;
    }

    setState(() {
      _errorMsg = null;
      _successMsg = '비밀번호가 변경되었어요! 😊';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),

            // 현재 비밀번호
            TextField(
              controller: _currentController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '현재 비밀번호',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 새 비밀번호
            TextField(
              controller: _newController,
              obscureText: true,
              onChanged: (_) => setState(() {}), // 강도 표시 실시간 업데이트
              decoration: InputDecoration(
                hintText: '새 비밀번호 (영어+숫자+특수문자 8자 이상)',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // 비밀번호 강도 표시바
            if (_newController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPasswordStrengthBar(_newController.text),
            ],

            const SizedBox(height: 10),

            // 새 비밀번호 확인
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '새 비밀번호 확인',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // 비밀번호 조건 안내
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '비밀번호 조건\n• 8자 이상\n• 영어 포함\n• 숫자 포함\n• 특수문자 포함 (* ^ % # \$ @ !)',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  height: 1.6,
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
            if (_successMsg != null) ...[
              const SizedBox(height: 8),
              Text(
                _successMsg!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
              ),
            ],
            const SizedBox(height: 18),

            // 변경 버튼
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    '변경하기',
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
