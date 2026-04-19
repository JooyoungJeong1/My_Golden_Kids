import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data/category_data.dart';

// ───────────────────────────────────────────
// 카테고리 상세 페이지
// ───────────────────────────────────────────

class CategoryDetailPage extends StatelessWidget {
  final CategoryItem item;
  const CategoryDetailPage({super.key, required this.item});

  static const Map<String, Color> heroBgColors = {
    '종이류': Color(0xFFE3F2FD), // 상단 배경 색
    '캔류': Color(0xFFFFF8E1),
    '유리': Color(0xFFE8EAF6),
    '플라스틱': Color(0xFFE8F5E9),
    '비닐': Color(0xFFFCE4EC),
    '기타·처치곤란': Color(0xFFF3E5F5),
  };

  @override
  Widget build(BuildContext context) {
    final detail = categoryDetails[item.label]!;
    final heroBg =
        heroBgColors[item.label] ?? const Color(0xFFF5F5F5); // 카테고리 기본 배경색상

    return Scaffold(
      appBar: AppBar(
        title: Text(item.label),
        backgroundColor: const Color(0xFFF6F1F6), // 앱바 배경 색상
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222), // 뒤로가기 버튼, 제목 색상
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: heroBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    item.imageUrl != null
                        ? Image.asset(
                            item.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ) //카테고리 박스 아이콘 사이즈
                        : Text(
                            item.icon ?? '',
                            style: const TextStyle(fontSize: 48),
                          ),
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ), // 카테고리 상세 서브타이틀 색
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...detail.steps.asMap().entries.map((e) {
                final idx = e.key;
                final step = e.value;
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
                        ), // 단계 번호 원 배경
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7A6000),
                            ),
                          ),
                        ), // 단계 번호 텍스트 색
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 3),
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
              }),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4), // 주의사항 배경색
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFDD835),
                  ), // 주의사항 테두리
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ 주의사항',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A6000),
                      ),
                    ), // 제목 색
                    const SizedBox(height: 6),
                    Text(
                      detail.warning,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5D4037),
                        height: 1.5,
                      ),
                    ), // 본문 색
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
