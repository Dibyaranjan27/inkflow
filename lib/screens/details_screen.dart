import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:inkflow/screens/reading_screen.dart';
import 'package:inkflow/widgets/chapter_card_widget.dart';
import 'package:inkflow/widgets/custom_info_box.dart';
import 'package:inkflow/widgets/simplified_book_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert'; // Add this import for JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> myBook; // Updated to receive the book details

  DetailsScreen(this.myBook);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Add a boolean to track the bookmark state
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }

  // Check if the book is already bookmarked
  Future<void> _checkIfBookmarked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('email');

    // Create a unique key for the user
    String key = '${username}_bookmarkedBooks';
    List<String> bookmarkedBooks = prefs.getStringList(key) ?? [];

    setState(() {
      isBookmarked = bookmarkedBooks.contains(json.encode(widget.myBook));
    });
  }

  Future<void> _toggleBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('email');
    String key = '${username}_bookmarkedBooks';
    List<String> bookmarkedBooks = prefs.getStringList(key) ?? [];

    if (isBookmarked) {
      bookmarkedBooks.remove(json.encode(widget.myBook));
    } else {
      bookmarkedBooks.add(json.encode(widget.myBook));
    }

    await prefs.setStringList(key, bookmarkedBooks);

    setState(() {
      isBookmarked = !isBookmarked; // Toggle the state
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access book details from the widget's passed data
    final String bookTitle =
        widget.myBook['title'].toString() ?? 'Unknown Title';
    var author = widget.myBook['authors'] ?? 'Unknown Author';
    final String authorName = author.toString();
    final String bookCover = widget.myBook != null
        ? (widget.myBook['thumbnail'] ??
            widget.myBook['imageLinks']?['thumbnail'] ??
            'assets/images/default_thumbnail.png')
        : 'assets/images/default_thumbnail.png';
    var rate = widget.myBook['averageRating'] ?? 0.0;
    final String rating = rate == 0.0 ? 'N/A' : rate.toString();
    final String pages = widget.myBook['pageCount'].toString() ?? 'N/A';
    final String language = widget.myBook['language'] ?? 'N/A';
    final String description =
        widget.myBook['description'] ?? 'No description available.';
    final List<dynamic> chapters = widget.myBook['chapters'] ?? [];

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Container(
                child: Column(
                  children: [
                    // Top half with blurred background image
                    Expanded(
                      child: Stack(
                        children: [
                          // Background image limited to top half
                          FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor:
                                0.6, // Only take half of the screen height
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      bookCover), // Use dynamic cover
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          // Blurring the image
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                color: Colors.white.withOpacity(0),
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.4),
                                    Colors.white
                                  ],
                                  stops: [0.0, 0.5, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // AppBar with back arrow and bookmark icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            // Toggle between outlined and filled bookmark icon based on state
                            icon: Icon(
                              isBookmarked
                                  ? FontAwesomeIcons
                                      .solidBookmark // Filled bookmark
                                  : FontAwesomeIcons
                                      .bookmark, // Outlined bookmark
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Toggle bookmark state
                              _toggleBookmark();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // BookCard scaled up and centered
                    Container(
                      child: SimplifiedBookCard(
                        bookCover: bookCover, // Use dynamic book cover
                        press: () {
                          // Add your press logic here
                        },
                      ),
                    ),
                    // Centered Book Title and Author
                    SizedBox(height: 10),
                    Text(
                      bookTitle, // Use dynamic title
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      authorName, // Use dynamic author name
                      style:
                          TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    // Custom Rating, Pages, Language Info Boxes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: CustomInfoBox(
                                title: 'Rating',
                                content: rating, // Use dynamic rating
                                icon: Icons.star,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: CustomInfoBox(
                                title: 'Pages',
                                content: pages, // Use dynamic page count
                                icon: Icons.pageview,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: CustomInfoBox(
                                title: 'Language',
                                content: language, // Use dynamic language
                                icon: Icons.language,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Chapters List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: List.generate(chapters.length, (index) {
                          final chapter = chapters[index];
                          return ChapterCard(
                            chapterNumber: index + 1,
                            chapterName:
                                'Chapter ${index + 1} - ${chapter['title'] ?? 'Untitled'}', // Dynamic chapter name
                            currentPage: chapter['currentPage'] ??
                                0, // Example pages read
                            totalPages: chapter['totalPages'] ??
                                0, // Example total pages
                            press: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ReadingScreen(
                                  bookData: widget.myBook,
                                );
                              }));
                            },
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Pagination
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: chapters.isEmpty
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PaginationButton(
                                    pageNumber: '1', isCurrent: true),
                                PaginationButton(pageNumber: '2'),
                                PaginationButton(pageNumber: '3'),
                                Text('...'),
                                PaginationButton(pageNumber: 'Next'),
                              ],
                            ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left, // Left align the title
                    ),
                    SizedBox(height: 16),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      child: Text(
                        description, // Use dynamic description
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left, // Left align the description
                      ),
                    ),

                    SizedBox(height: 100), // To leave space for the button
                  ],
                ),
              ),
            ),
            // Start Reading button pinned to the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ReadingScreen(
                          bookData: widget.myBook,
                        );
                      }));
                    },
                    child: Text(
                      'Start Reading',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(double.infinity, 50), // Full width button
                      backgroundColor: Color(0xFFBE7066), // Button color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaginationButton extends StatelessWidget {
  final String pageNumber;
  final bool isCurrent;

  PaginationButton({required this.pageNumber, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        pageNumber,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isCurrent ? Colors.blue : Colors.black,
        ),
      ),
    );
  }
}
