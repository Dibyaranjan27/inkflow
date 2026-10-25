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
            image: DecorationImage(
              image: imageProvider,
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
