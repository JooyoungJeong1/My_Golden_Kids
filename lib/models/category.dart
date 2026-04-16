import 'package:flutter/material.dart';

class CategoryItem {
  final String? icon;
  final String label;
  final String subtitle;
  final Color bgColor;
  final bool isAi;
  final String? imageUrl;

  const CategoryItem({
    this.icon,
    required this.label,
    required this.subtitle,
    required this.bgColor,
    this.isAi = false,
    this.imageUrl,
  });
}

class CategoryDetail {
  final String subtitle;
  final List<CategoryStep> steps;
  final String warning;

  const CategoryDetail({
    required this.subtitle,
    required this.steps,
    required this.warning,
  });
}

class CategoryStep {
  final String title;
  final String description;
  const CategoryStep({required this.title, required this.description});
}
