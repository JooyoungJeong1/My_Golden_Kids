import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';

// ───────────────────────────────────────────
// 닉네임 변경 페이지
// ───────────────────────────────────────────

class NicknameChangePage extends StatefulWidget {
  const NicknameChangePage({super.key});
  @override
  State<NicknameChangePage> createState() => _NicknameChangePageState();
}

class _NicknameChangePageState extends State<NicknameChangePage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMsg;
  String? _successMsg;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = UserSession.nickname ?? '';
  }

  void _submit() async {
    final newNickname = _controller.text.trim();

    if (newNickname.isEmpty) {
      setState(() => _errorMsg = '닉네임을 입력해주세요.');
      return;
    }
    if (newNickname == UserSession.nickname) {
      setState(() => _errorMsg = '현재 닉네임과 동일해요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final result = await ApiService.changeNickname(
        userId: UserSession.userId!,
        newNickname: newNickname,
      );

      if (result['detail'] != null) {
        setState(() => _errorMsg = result['detail']);
        return;
      }

      UserSession.nickname = newNickname;
      setState(() => _successMsg = '닉네임이 변경되었어요! 😊');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      setState(() => _errorMsg = '서버 연결에 실패했어요. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('닉네임 변경'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '⏳ 닉네임은 7일에 한 번만 변경 가능해요.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2E7D32),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '새 닉네임',
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
}
