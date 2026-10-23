import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';

class ContinueReadingWidget extends StatelessWidget {
  final String bookCover;
  final String bookTitle;
  final int currentPage;
  final int totalPages;
  final void Function() press;

  ContinueReadingWidget({
    required this.bookCover,
    required this.bookTitle,
    required this.currentPage,
    required this.totalPages,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentPage / totalPages;
    int percentage = (progress * 100).toInt(); // Calculate progress percentage

    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
              width: 100,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(bookCover),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            // Book info and progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book title and page info
                  Text(
                    bookTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Page $currentPage of $totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Custom progress bar with percentage
                  Container(
                    height: 30,
                    width: 380.0,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: kScaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Progress bar
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // Progress percentage
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextButton(
                        onPressed: press,
                        child: Text(
                          'Continue Reading',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Continue Reading button at the bottom aligned with the cover
          ],
        ),
      ),
    );
  }
}
