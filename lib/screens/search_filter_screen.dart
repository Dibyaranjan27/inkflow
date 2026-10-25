import 'package:flutter/material.dart';
import 'package:inkflow/screens/details_screen.dart';
import 'package:inkflow/services/book_service.dart';
import 'package:inkflow/theme/app_theme.dart';

/// Screen displaying book search results with query and filtering.
class SearchResultsScreen extends StatelessWidget {
  final String query;
  final BookService _bookService = BookService();

  SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Results for "$query"',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookService.fetchBooks(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load results: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_off, size: 54, color: AppColors.textSecondary),
                  SizedBox(height: 12),
                  Text(
                    'No books found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Try searching with a different title or author.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final books = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1),
            itemBuilder: (context, index) {
              final book = books[index];
              final thumbnail = book['thumbnail'] as String? ?? '';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: thumbnail.isNotEmpty
                      ? Image.network(
                          thumbnail,
                          width: 48,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 72,
                            color: AppColors.border,
                            child: const Icon(Icons.book, color: AppColors.textSecondary),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 72,
                          color: AppColors.border,
                          child: const Icon(Icons.book, color: AppColors.textSecondary),
                        ),
                ),
                title: Text(
                  book['title'] as String? ?? 'Untitled',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    book['authors'] as String? ?? 'Unknown Author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(book),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
