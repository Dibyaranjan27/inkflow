import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

class BookRating extends StatelessWidget {
  final double score;
  const BookRating({
    Key? key,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            offset: Offset(3, 7),
            blurRadius: 20,
            color: AppColors.shadowLight,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.star,
            color: AppColors.star,
            size: 15,
          ),
          const SizedBox(height: 5),
          Text(
            "$score",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
