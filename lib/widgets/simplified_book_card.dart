import 'package:flutter/material.dart';

// Custom widget for the simplified book card (no rating, title, or author)
class SimplifiedBookCard extends StatelessWidget {
  final String bookCover;
  final void Function() press;

  SimplifiedBookCard({
    required this.bookCover,
    required this.press,
  });

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
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(bookCover),
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
