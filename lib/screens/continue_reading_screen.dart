import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';
import 'package:inkflow/screens/reading_screen.dart';
import 'package:inkflow/widgets/continue_reading_widget.dart'; // Make sure to import your widget

class ContinueReadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: SingleChildScrollView(
          // Wrap the entire body in SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),

                // Title and Descriptive Text Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continue Reading',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(
                                height:
                                    8), // Space between title and description
                            Text(
                              'Dive back into your stories and pick up where you left off! Here’s what you’ve been reading:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10), // Space between text and image
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        child: Image.asset(
                          'assets/images/girl-book-reading.png', // Replace with your image path
                          width: 100,
                          height: 100, // Adjust height as needed
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16), // Space between the card and divider

                // Add Divider with Circle in the middle
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.divider, // Line color
                        thickness: 1.5, // Line thickness
                        endIndent: 10, // Space at the end
                      ),
                    ),
                    CircleAvatar(
                      radius: 12, // Circle size
                      backgroundColor: AppColors.divider, // Circle color
                      child: Icon(
                        Icons.bookmark,
                        size: 16, // Icon size
                        color: Colors.white, // Icon color
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.divider, // Line color
                        thickness: 1.5, // Line thickness
                        indent: 10, // Space at the beginning
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16), // Space between the card and the list

                // ListView of ContinueReadingWidgets
                // Changed to a regular ListView instead of an Expanded
                ListView.builder(
                  shrinkWrap: true, // Ensures the ListView sizes to its content
                  physics:
                      NeverScrollableScrollPhysics(), // Disable inner scrolling
                  itemCount: 8, // Number of ContinueReadingWidgets
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ContinueReadingWidget(
                        bookCover:
                            'assets/images/girl-book-reading.png', // Sample book cover
                        bookTitle: 'Book Title $index', // Sample title
                        currentPage: 30 + index, // Sample current page
                        totalPages: 100,
                        press: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ReadingScreen(
                              bookData: {},
                            );
                          }));
                        }, // Sample total pages
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
