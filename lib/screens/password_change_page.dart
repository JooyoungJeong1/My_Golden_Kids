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

  void _submit() {
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
    if (newPw.length < 6) {
      setState(() => _errorMsg = '비밀번호는 6자 이상이어야 해요.');
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
              decoration: InputDecoration(
                hintText: '새 비밀번호 (6자 이상)',
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
                style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
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
}
