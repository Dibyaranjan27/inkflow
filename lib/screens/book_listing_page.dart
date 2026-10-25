import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inkflow/screens/details_screen.dart';
import 'package:inkflow/services/book_service.dart';
import 'package:inkflow/theme/app_theme.dart';
import 'package:inkflow/widgets/book_card_widget.dart';

class BookListingPage extends StatefulWidget {
  final String? query;

  const BookListingPage({Key? key, this.query}) : super(key: key);

  @override
  _BookListingPageState createState() => _BookListingPageState();
}

class _BookListingPageState extends State<BookListingPage> {
  final BookService _bookService = BookService();
  final TextEditingController searchController = TextEditingController();

  List<String> categories = ['All'];
  String selectedCategory = 'All';
  List<Map<String, dynamic>> books = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();

    final initialQuery = widget.query?.trim();
    if (initialQuery != null && initialQuery.isNotEmpty) {
      // Find matching category if applicable
      for (final cat in categories) {
        if (cat.toLowerCase() == initialQuery.toLowerCase()) {
          selectedCategory = cat;
          break;
        }
      }
      fetchBooks(initialQuery);
    } else {
      fetchBooks('All');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchCategories() {
    const List<String> apiCategories = [
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
      'Politics',
    ];

    setState(() {
      categories = ['All', ...apiCategories];
    });
  }

  /// Fetches books using the resilient [BookService] with multi-tier fallback.
  Future<void> fetchBooks(String query) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final cleanQuery = query == 'All' || query.trim().isEmpty ? 'bestseller' : query.trim();
      final fetched = await _bookService.fetchBooks(cleanQuery, maxResults: 30);

      if (mounted) {
        setState(() {
          books = fetched;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          books = [];
          isLoading = false;
        });
      }
    }
  }

  void handleSearch() {
    final String searchQuery = searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      setState(() {
        selectedCategory = '';
      });
      fetchBooks(searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            selectedCategory.isNotEmpty && selectedCategory != 'All'
                ? selectedCategory
                : (widget.query != null && widget.query!.isNotEmpty ? 'Catalog' : 'All Books'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.bell, color: AppColors.textPrimary, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        body: Column(
          children: [
            // Search Input
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              child: Material(
                elevation: 3,
                shadowColor: AppColors.shadowMedium,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: searchController,
                  onSubmitted: (_) => handleSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search books by title, author, topic...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              searchController.clear();
                              fetchBooks(selectedCategory.isNotEmpty ? selectedCategory : 'All');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Horizontal Categories Carousel
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 6.0,
              ),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                          searchController.clear();
                        });
                        fetchBooks(category);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
                        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                        elevation: isSelected ? 2 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),

            // GridView for Books
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: isLoading
                    ? const Center(
                        child: SpinKitWaveSpinner(
                          color: AppColors.primary,
                          waveColor: AppColors.primaryLight,
                          trackColor: AppColors.cardPlaceholder,
                          size: 55.0,
                        ),
                      )
                    : books.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'No books found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => fetchBooks('All'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text('Reset to All', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenWidth < 600 ? 3 : 4,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 10,
                              childAspectRatio: screenWidth < 300 ? 0.58 : 0.44,
                            ),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> rawBook = books[index];
                              final Map<String, dynamic> book =
                                  rawBook['volumeInfo'] is Map<String, dynamic>
                                      ? rawBook['volumeInfo'] as Map<String, dynamic>
                                      : rawBook;

                              final String cover = book['thumbnail']?.toString() ??
                                  book['imageLinks']?['thumbnail']?.toString() ??
                                  'assets/images/girl-book-reading.png';
                              final String title = book['title']?.toString() ?? 'Untitled Book';
                              final dynamic authorsRaw = book['authors'] ?? book['author'];
                              final String author = authorsRaw is List
                                  ? authorsRaw.join(', ')
                                  : (authorsRaw?.toString() ?? 'Unknown Author');
                              final double rating =
                                  (book['averageRating'] as num?)?.toDouble() ??
                                  (book['rating'] as num?)?.toDouble() ??
                                  4.5;

                              return BookCard(
                                bookCover: cover,
                                rating: rating,
                                bookTitle: title,
                                author: author,
                                press: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(rawBook),
                                    ),
                                  );
                                },
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
