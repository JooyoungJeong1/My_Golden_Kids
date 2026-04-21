import 'package:flutter/material.dart';
import '../models/category.dart';

// ───────────────────────────────────────────
// 카테고리 카드
// ───────────────────────────────────────────

class CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isAi
                  ? const Color(0xFFFDD835)
                  : const Color(0xFFEAEAEA), // AI 카드 테두리색, 일반 카드 테두리색
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    item.imageUrl != null
                        ? Image.asset(
                            item.imageUrl!,
                            width: 35,
                            height: 35,
                            fit: BoxFit.contain,
                          ) //카테고리 아이콘 사이즈
                        : Text(
                            item.icon ?? '',
                            style: const TextStyle(fontSize: 26),
                          ), //플라스틱, 기타처리 아이콘 사이즈
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isAi)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDD835),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A6000),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
