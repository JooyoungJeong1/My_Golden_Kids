import 'package:flutter/material.dart';
import '../models/user_session.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  String? _errorMsg;

  // TODO: 백엔드 연결 시 이메일 인증 관련 변수 활성화
  // bool _isVerified = false;
  // bool _codeSent = false;
  // final TextEditingController _codeController = TextEditingController();

  // ───────────────────────────────────────────
  // 이메일 형식 검증
  // ───────────────────────────────────────────
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$').hasMatch(email);
  }

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

  void _signup() {
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _passwordConfirmController.text.trim();

    if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = '모든 항목을 입력해주세요.');
      return;
    }

    // 이메일 형식 검증
    if (!_isValidEmail(email)) {
      setState(() => _errorMsg = '올바른 이메일 형식이 아니에요.\n예) abc@gmail.com');
      return;
    }

    // 비밀번호 강도 검증
    if (!_isValidPassword(password)) {
      setState(
        () => _errorMsg = '비밀번호는 영어, 숫자, 특수문자(*^%#\$@!)를\n포함한 8자 이상이어야 해요.',
      );
      return;
    }

    if (password != confirm) {
      setState(() => _errorMsg = '비밀번호가 일치하지 않아요.');
      return;
    }
    if (UserSession.accounts.containsKey(email)) {
      setState(() => _errorMsg = '이미 사용 중인 이메일이에요.');
      return;
    }

    // TODO: 백엔드 연결 시 이메일 인증 확인 추가
    // if (!_isVerified) {
    //   setState(() => _errorMsg = '이메일 인증을 완료해주세요.');
    //   return;
    // }

    // 계정 저장
    UserSession.accounts[email] = {'nickname': nickname, 'password': password};
    // 회원가입 전 같은 닉네임으로 쓴 글 연동
    UserSession.guestNicknames.add(nickname);
    // 자동 로그인
    UserSession.login(email, nickname);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
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

            // 이메일
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: '이메일 (예: abc@gmail.com)',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // TODO: 백엔드 연결 시 이메일 인증 UI 활성화
            // const SizedBox(height: 8),
            // Row(children: [
            //   Expanded(
            //     child: TextField(
            //       controller: _codeController,
            //       keyboardType: TextInputType.number,
            //       decoration: InputDecoration(hintText: '인증 코드 6자리', ...),
            //     ),
            //   ),
            //   const SizedBox(width: 8),
            //   GestureDetector(
            //     onTap: () async {
            //       await ApiService.sendVerificationCode(_emailController.text);
            //       setState(() => _codeSent = true);
            //     },
            //     child: Container(/* 인증코드 발송 버튼 */),
            //   ),
            // ]),
            const SizedBox(height: 10),

            // 비밀번호
            TextField(
              controller: _passwordController,
              obscureText: true,
              onChanged: (_) => setState(() {}), // 강도 표시 실시간 업데이트
              decoration: InputDecoration(
                hintText: '비밀번호 (영어+숫자+특수문자 8자 이상)',
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
