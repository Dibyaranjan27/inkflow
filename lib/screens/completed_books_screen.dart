import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';
import 'package:inkflow/screens/details_screen.dart';
import 'package:inkflow/widgets/book_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ensure your BookCard widget is correctly imported

class CompletedBooksScreen extends StatefulWidget {
  @override
  State<CompletedBooksScreen> createState() => _CompletedBooksScreenState();
}

class _CompletedBooksScreenState extends State<CompletedBooksScreen> {
  List<Map<String, dynamic>> _myBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkedBooks();
  }

  Future<void> _loadBookmarkedBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('email');

    // Create a unique key for the user
    String key = '${username}_completedBooks';
    List<String> bookmarkedBooks = prefs.getStringList(key) ?? [];

    // Decode the list of bookmarked books
    setState(() {
      _myBooks = bookmarkedBooks
          .map((book) => json.decode(book) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
            child: Column(
              children: [
                // Back Arrow
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the previous screen
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing

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
                              'Completed Books',
                              style: TextStyle(
                                fontSize: 25, // Responsive font size
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(
                                height:
                                    8), // Space between title and description
                            Text(
                              'Congratulations on finishing your books! Here’s a collection of stories you have completed. Relive your favorites or find new ones to enjoy.',
                              style: TextStyle(
                                fontSize: 16, // Responsive font size
                                fontWeight: FontWeight.normal,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.start,
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

                SizedBox(
                    height: screenHeight *
                        0.02), // Space between the card and divider

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

                SizedBox(height: screenHeight * 0.02), // Space below the card

                // Grid View for Completed Book Cards
                _myBooks.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.all(
                            screenWidth * 0.02), // Responsive padding
                        child: GridView.builder(
                          physics:
                              NeverScrollableScrollPhysics(), // Disable inner scrolling
                          shrinkWrap:
                              true, // Make the grid view fit within the scroll view
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth < 600
                                ? 3
                                : 4, // Responsive cross-axis count
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 10,
                            childAspectRatio: screenWidth < 300
                                ? 0.6
                                : 0.42, // Adjust height to width ratio
                          ),
                          itemCount: _myBooks.isNotEmpty
                              ? _myBooks.length
                              : 0, // Use the length of _myBooks
                          itemBuilder: (context, index) {
                            final book =
                                _myBooks[index]; // Access book data dynamically

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return DetailsScreen(
                                      book); // Pass the book data to the DetailsScreen
                                })).then((_) {
                                  // Reload user data when returning to ProfileScreen
                                  _loadBookmarkedBooks();
                                });
                              },
                              child: BookCard(
                                bookTitle: book['title'] ??
                                    'Unknown Title', // Use book data or fallback
                                author: book['authors'] != null
                                    ? (book['authors'].toString())
                                    : 'Unknown',
                                // Use book author or fallback
                                rating:
                                    4.0, // Assuming rating is fixed for now, replace if dynamic
                                bookCover: book['thumbnail'] ??
                                    book['imageLinks']?['thumbnail'] ??
                                    'assets/images/default_thumbnail.png', // Use dynamic cover or fallback
                                press: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return DetailsScreen(
                                        book); // Use dynamic book data
                                  })).then((_) {
                                    // Reload user data when returning to ProfileScreen
                                    _loadBookmarkedBooks();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'You have no completed books yet.',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
