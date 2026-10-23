import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Custom widget for "View More" card
class ViewMoreCard extends StatelessWidget {
  final VoidCallback onTap;

  // Constructor to accept the onTap function
  const ViewMoreCard({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call the passed function when the card is tapped
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View More',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              SizedBox(
                height: 20.0,
              ),
              Icon(FontAwesomeIcons.arrowRight),
            ],
          ),
        ),
      ),
    );
  }
}
