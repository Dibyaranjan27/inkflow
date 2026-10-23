import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Custom widget for the book card
class BookCard extends StatelessWidget {
  final String bookCover;
  final double rating;
  final String bookTitle;
  final String author;
  final void Function() press;

  BookCard(
      {required this.bookCover,
      required this.rating,
      required this.bookTitle,
      required this.author,
      required this.press});

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(bookCover),
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Book title
            SizedBox(
              width: 150, // Adjust width to prevent overflow
              child: Text(
                bookTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1, // Ensure only 1 line is displayed
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
              ),
            ),
            SizedBox(height: 5),
            // Author name
            SizedBox(
              width: 150, // Adjust width to prevent overflow
              child: Text(
                author,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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
