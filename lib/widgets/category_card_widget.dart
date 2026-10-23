import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final Color backgroundColor;
  final void Function() press;

  CategoryCard(
      {required this.categoryName,
      required this.backgroundColor,
      required this.press});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: press,
        child: Container(
          width: 150, // Adjust the width as per your design
          margin: EdgeInsets.only(right: 16.0), // Adds space between cards
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowMedium,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Center(
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Assuming white text color
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
