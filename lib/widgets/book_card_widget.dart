import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

// Custom widget for the book card
class BookCard extends StatelessWidget {
  final String bookCover;
  final double rating;
  final String bookTitle;
  final String author;
  final void Function() press;

  const BookCard({
    Key? key,
    required this.bookCover,
    required this.rating,
    required this.bookTitle,
    required this.author,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = bookCover.startsWith('http')
        ? CachedNetworkImageProvider(bookCover)
        : AssetImage(
            bookCover.isNotEmpty
                ? bookCover
                : 'assets/images/girl-book-reading.png',
          ) as ImageProvider;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: press,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover with rating
            Stack(
              children: [
                Container(
                  width: 150,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.cardPlaceholder,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: imageProvider,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Book title
            SizedBox(
              width: 150, // Adjust width to prevent overflow
              child: Text(
                bookTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1, // Ensure only 1 line is displayed
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
              ),
            ),
            const SizedBox(height: 4),
            // Author name
            SizedBox(
              width: 150, // Adjust width to prevent overflow
              child: Text(
                author,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1, // Ensure only 1 line is displayed
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
