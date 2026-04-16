import 'package:flutter/material.dart';
import 'chat_page.dart';

// ───────────────────────────────────────────
// FAQ 페이지
// ───────────────────────────────────────────

class FaqData {
  final String question;
  final String answer;
  const FaqData({required this.question, required this.answer});
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const List<FaqData> faqs = [
    FaqData(
      question: '플라스틱은 모두 재활용 가능한가요?',
      answer:
          '오염이 심하거나 복합 재질(플라스틱+금속 등)이면 일반쓰레기로 분류됩니다. 용기에 표시된 재질 마크를 확인하고, 깨끗이 씻어 배출하세요.',
    ),
    FaqData(
      question: '음식물이 묻은 종이는?',
      answer:
          '피자 박스처럼 기름이 심하게 밴 종이는 일반쓰레기입니다. 약간 묻은 경우 오염 부분을 제거 후 배출 가능합니다. 신문지·박스·책은 재활용 가능합니다.',
    ),
    FaqData(
      question: '유리병 뚜껑은 어떻게 버려요?',
      answer:
          '금속 뚜껑은 캔류로, 플라스틱 뚜껑은 플라스틱으로 분리해서 배출합니다. 유리병 본체는 유리 수거함에 따로 넣어주세요.',
    ),
    FaqData(
      question: '영수증(감열지)은 어디에 버려요?',
      answer: '영수증, 택배 송장, 코팅지는 일반쓰레기입니다. 재활용 표시가 있어도 감열 처리된 종이는 재활용이 안 됩니다.',
    ),
    FaqData(
      question: '깨진 유리는 어떻게 버려요?',
      answer:
          '깨진 유리는 일반 유리 수거함이 아닌, 신문지나 종이로 단단히 싸서 \'깨진 유리\'라고 표시 후 일반쓰레기 봉투에 넣어 배출하세요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 묻는 질문'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...faqs.map((f) => _FaqItem(data: f)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7), // 박스 배경색
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDD835)), // 박스 테두리색
              ),
              child: Column(
                children: [
                  const Text(
                    '더 궁금한 게 있으신가요?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A6000),
                    ),
                  ), // 텍스트 색
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatQuestionPage(),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDD835),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'AI에게 직접 물어보기 →',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final FaqData data;
  const _FaqItem({required this.data});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isOpen = !_isOpen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.data.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.remove : Icons.add,
                    size: 18,
                    color: const Color(0xFF888888),
                  ),
                ],
              ),
            ),
          ),
          if (_isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.data.answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
