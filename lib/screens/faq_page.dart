import 'package:flutter/material.dart';
import 'chat_page.dart';
import '../data/faq_data.dart';

// ───────────────────────────────────────────
// FAQ 페이지
// ───────────────────────────────────────────

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

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
            ...faqList.map((f) => _FaqItem(question: f['q']!, answer: f['a']!)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDD835)),
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
                  ),
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
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

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
                      widget.question,
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
                widget.answer,
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
