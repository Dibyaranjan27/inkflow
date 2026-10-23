import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';
import 'package:inkflow/screens/details_screen.dart';
import 'package:inkflow/widgets/book_card_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class BookListingPage extends StatefulWidget {
  final String? query; // Accepting a query string

  BookListingPage({this.query}); // Constructor to receive query

  @override
  _BookListingPageState createState() => _BookListingPageState();
}

class _BookListingPageState extends State<BookListingPage> {
  List<String> categories = ['All']; // Default to 'All'
  String? selectedCategory = 'All'; // Track the selected category
  List<dynamic> books = []; // To store fetched books
  TextEditingController searchController =
      TextEditingController(); // Controller for search bar
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories when the page loads
    if (widget.query != null && widget.query!.isNotEmpty) {
      fetchBooks(widget.query!); // Fetch books based on query if provided
    } else {
      fetchBooks('All'); // Fetch all books initially
    }
  }

  // Function to fetch categories from Google Books API
  Future<void> fetchCategories() async {
    List<String> apiCategories = [
      'Fiction',
      'Science',
      'History',
      'Technology',
      'Art',
      'Biography',
      'Mystery',
      'Fantasy',
      'Romance',
      'Self-Help',
      'Health',
      'Travel',
      'Cookbooks',
      'Children\'s',
      'Poetry',
      'Horror',
      'Graphic Novels',
      'Comics',
      'Religion',
      'Philosophy',
      'Politics'
    ];

    setState(() {
      categories.addAll(apiCategories);
    });
  }

  // Function to fetch books from Google Books API based on selected category or search query
  Future<void> fetchBooks(String query) async {
    setState(() {
      isLoading = true; // Set loading to true when fetching books
    });

    String apiQuery = query == 'All' ? '' : query; // Adjust query for all books
    int totalResults = 45; // Target number of results
    int maxResultsPerPage = 10; // Number of results per request
    List<dynamic> allBooks = []; // Store all fetched books
    int startIndex = 0; // Starting index for pagination

    while (allBooks.length < totalResults) {
      final url = Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=$apiQuery&maxResults=$maxResultsPerPage&startIndex=$startIndex&key=AIzaSyDJN3_7ORDyMtHvDClxxAAQtsH2TlAlSxc');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> books = data['items'] ?? [];
        allBooks.addAll(books); // Add fetched books to the list

        // If there are fewer results than requested, stop fetching
        if (books.length < maxResultsPerPage) {
          break;
        }

        startIndex += maxResultsPerPage; // Move to the next page
      } else {
        throw Exception('Failed to load books');
      }
    }

    setState(() {
      // Update the state with the fetched books, limited to the total desired results
      this.books = allBooks.take(totalResults).toList();
      isLoading = false; // Set loading to false when fetching is complete
    });
  }

  // Function to handle search when the user submits their query
  void handleSearch() {
    String searchQuery = searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      fetchBooks(searchQuery); // Fetch books based on the search query
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: kScaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(FontAwesomeIcons.bell, color: Colors.black),
              onPressed: () {
                // Notification logic
              },
            ),
            SizedBox(width: 10.0),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              child: Material(
                elevation: 5,
                shadowColor: AppColors.shadowMedium,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller:
                      searchController, // Use the controller for the input
                  onSubmitted: (value) {
                    handleSearch(); // Call handleSearch on submit
                  },
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Categories Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = category;
                            fetchBooks(category); // Fetch books for category
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: selectedCategory == category
                              ? Colors.grey[300]
                              : Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedCategory == category
                                ? Colors.black
                                : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // GridView for Books
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading // Show loader if loading
                    ? Center(
                        child: SpinKitWaveSpinner(
                            color: kLogoColor,
                            waveColor: kWaveColor,
                            trackColor: kTrackColor,
                            size: 50.0))
                    : books.isEmpty
                        ? Center(child: Text("No books found"))
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenWidth < 600 ? 3 : 4,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 10,
                              childAspectRatio: screenWidth < 300 ? 0.6 : 0.43,
                            ),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final dynamic book = books[index]['volumeInfo'];
                              return BookCard(
                                bookCover: book['imageLinks'] != null
                                    ? book['imageLinks']['thumbnail']
                                    : 'assets/images/girl-book-reading.png',
                                press: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return DetailsScreen(book);
                                  }));
                                },
                                rating: book['averageRating']?.toDouble() ?? 0,
                                bookTitle: book['title'] ?? 'No title',
                                author: book['authors'] != null
                                    ? book['authors'].join(', ')
                                    : 'Unknown',
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
