import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final Color backgroundColor;
  final VoidCallback press;

  const CategoryCard({
    Key? key,
    required this.categoryName,
    required this.backgroundColor,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowMedium,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
