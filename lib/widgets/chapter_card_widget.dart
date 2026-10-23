import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

class ChapterCard extends StatelessWidget {
  final int chapterNumber;
  final String chapterName;
  final int currentPage;
  final int totalPages;
  final void Function() press;

  ChapterCard({
    required this.chapterNumber,
    required this.chapterName,
    required this.currentPage,
    required this.totalPages,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress and percentage
    double progress = totalPages > 0 ? currentPage / totalPages : 0.0;
    int percentage = (progress * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border), // Standardized border
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface, // Background color for card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Chapter Name and Right Arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Chapter $chapterNumber - $chapterName',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis, // Truncate long names
                  ),
                ),
              ),
              TextButton(
                onPressed: press,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // Removes padding
                  minimumSize:
                      Size(0, 0), // Optional: Adjust minimum size if needed
                  tapTargetSize: MaterialTapTargetSize
                      .shrinkWrap, // Reduces tap target size
                ),
                child: Icon(Icons.chevron_right,
                    color: AppColors.textSecondary), // Customize the color as needed
              ),
            ],
          ),
          SizedBox(height: 10),
          // Pages and Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentPage out of $totalPages pages',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                '$percentage%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }
}
