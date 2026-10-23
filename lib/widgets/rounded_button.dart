import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press; // Updated to VoidCallback
  final double verticalPadding;
  final double horizontalPadding;
  final double fontSize;

  const RoundedButton({
    Key? key, // Nullable Key
    required this.text, // Marked as required
    required this.press, // Marked as required
    this.verticalPadding = 16,
    this.horizontalPadding = 30,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press, // Corrected type for the callback
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 16),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 15),
              blurRadius: 30,
              color: AppColors.shadowLight,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
