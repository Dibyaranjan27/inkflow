import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inkflow/theme/app_theme.dart';

// Custom widget for the simplified book card (no rating, title, or author)
class SimplifiedBookCard extends StatelessWidget {
  final String bookCover;
  final VoidCallback press;

  const SimplifiedBookCard({
    Key? key,
    required this.bookCover,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: press,
        child: Container(
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
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bookCover.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: bookCover,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    placeholder: (context, url) => Container(
                      color: AppColors.cardPlaceholder,
                      child: const Center(
                        child: Icon(Icons.menu_book,
                            color: AppColors.textSecondary, size: 36),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.cardPlaceholder,
                      child: const Center(
                        child: Icon(Icons.menu_book,
                            color: AppColors.primary, size: 36),
                      ),
                    ),
                  )
                : Image.asset(
                    bookCover.isNotEmpty
                        ? bookCover
                        : 'assets/images/girl-book-reading.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cardPlaceholder,
                      child: const Center(
                        child: Icon(Icons.menu_book,
                            color: AppColors.textSecondary, size: 36),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
