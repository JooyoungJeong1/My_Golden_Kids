import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';

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
  bool _isLoading = false;

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

  void _submit() async {
    final current = _currentController.text.trim();
    final newPw = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      setState(() => _errorMsg = '모든 항목을 입력해주세요.');
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
    if (newPw.length < 4) {
      setState(() => _errorMsg = '비밀번호는 4자 이상이어야 해요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final result = await ApiService.changePassword(
        userId: UserSession.userId!,
        currentPassword: current,
        newPassword: newPw,
      );

      if (result['detail'] != null) {
        setState(() => _errorMsg = result['detail']);
        return;
      }

      setState(() => _successMsg = '비밀번호가 변경되었어요! 😊');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() => _errorMsg = '서버 연결에 실패했어요. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            TextField(
              controller: _newController,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '새 비밀번호 (4자 이상)',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_newController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPasswordStrengthBar(_newController.text),
            ],
            const SizedBox(height: 10),
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
            GestureDetector(
              onTap: _isLoading ? null : _submit,
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

  Widget _buildPasswordStrengthBar(String pw) {
    final strength = _passwordStrength(pw);
    final colors = [
      Colors.transparent,
      const Color(0xFFE53935),
      const Color(0xFFFF9800),
      const Color(0xFFFDD835),
      const Color(0xFF4CAF50),
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
