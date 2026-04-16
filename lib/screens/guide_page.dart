import 'package:flutter/material.dart';

// ───────────────────────────────────────────
// 분리배출 가이드 페이지
// ───────────────────────────────────────────

class GuideStep {
  final String number;
  final String title;
  final String description;
  const GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });
}

class DisposalGuidePage extends StatelessWidget {
  const DisposalGuidePage({super.key});

  static const List<GuideStep> steps = [
    GuideStep(
      number: '1',
      title: '비우기',
      description: '용기 안의 내용물을 완전히 비워주세요. 음료, 음식물 등이 남아있으면 재활용이 불가능해집니다.',
    ),
    GuideStep(
      number: '2',
      title: '헹구기',
      description: '물로 한 번 헹궈 이물질을 제거하세요. 완벽히 깨끗하지 않아도 되지만, 심한 오염은 제거해야 합니다.',
    ),
    GuideStep(
      number: '3',
      title: '분리하기',
      description: '라벨, 뚜껑, 부속품 등 재질이 다른 부분은 분리해서 각각 맞는 수거함에 넣어주세요.',
    ),
    GuideStep(
      number: '4',
      title: '섞지 않기',
      description: '종류별로 구분해서 배출하세요. 여러 재질을 섞어 버리면 선별 과정에서 재활용이 어려워집니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4단계 분리배출 가이드'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(16),
              ), // '올바른 분리배출의 4가지 원칙' 배경색
              child: const Center(
                child: Text(
                  '올바른 분리배출의 4가지 원칙',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4527A0),
                  ),
                ),
              ), // 텍스트 색
            ),
            const SizedBox(height: 14),
            ...steps.map((s) => _GuideStepCard(step: s)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ), // 잘못 배출 시 박스 배경색
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📌 잘못 배출 시',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ), // '잘못 배출 시' 제목 색
                  SizedBox(height: 6),
                  Text(
                    '분리배출이 잘못되면 재활용품이 일반 쓰레기로 처리됩니다. 헷갈리는 품목은 AI에게 바로 물어보세요!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0D47A1),
                      height: 1.5,
                    ),
                  ), // 잘못 배출 시 본문 색
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStepCard extends StatelessWidget {
  final GuideStep step;
  const _GuideStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3B0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.number,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7A6000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
