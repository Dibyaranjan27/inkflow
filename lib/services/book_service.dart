import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inkflow/constants.dart';

/// Service for fetching books and metadata from the Google Books API.
/// Preserves critical volume identifiers, official web reader links,
/// preview links, ratings, and sanitizes thumbnails to HTTPS.
class BookService {
  final String _apiKey = kGoogleBooksApiKey;

  /// Fetches books matching [query] with preserved IDs, webReaderLinks, and ratings.
  /// Compatible with existing callers (e.g. `fetchBooks("trending")`).
  Future<List<Map<String, dynamic>>> fetchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = 20,
    String? orderBy,
  }) async {
    String url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&startIndex=$startIndex&maxResults=$maxResults&key=$_apiKey';
    if (orderBy != null && orderBy.isNotEmpty) {
      url += '&orderBy=$orderBy';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List?;
      if (items == null || items.isEmpty) {
        return [];
      }
      return items.map((item) => _formatGoogleBook(item)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }

  /// Fetches details for a single Google Books volume by its unique [volumeId].
  Future<Map<String, dynamic>?> fetchBookById(String volumeId) async {
    final String url =
        'https://www.googleapis.com/books/v1/volumes/$volumeId?key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      return _formatGoogleBook(item);
    }
    return null;
  }

  /// Normalizes and enriches a Google Books API volume item.
  static Map<String, dynamic> _formatGoogleBook(dynamic item) {
    final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};
    final accessInfo = item['accessInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};

    // Ensure thumbnail URLs use HTTPS to prevent Android cleartext blocks
    String thumbnail =
        imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
    if (thumbnail.startsWith('http://')) {
      thumbnail = thumbnail.replaceFirst('http://', 'https://');
    }

    final double avgRating =
        (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0;
    final String previewLink = volumeInfo['previewLink']?.toString() ?? '';
    final String webReaderLink =
        accessInfo['webReaderLink']?.toString() ?? previewLink;

    final String authors =
        (volumeInfo['authors'] as List?)?.join(', ') ?? 'Unknown Author';

    return {
      'id': item['id']?.toString() ?? '',
      'title': volumeInfo['title']?.toString() ?? 'No Title',
      'authors': authors,
      'author': authors,
      'pageCount': volumeInfo['pageCount'] is int
          ? volumeInfo['pageCount']
          : int.tryParse(volumeInfo['pageCount']?.toString() ?? '') ?? 0,
      'description':
          volumeInfo['description']?.toString() ?? 'No Description',
      'thumbnail': thumbnail,
      'imageLinks': imageLinks,
      'averageRating': avgRating,
      'rating': avgRating > 0.0 ? avgRating : 4.0, // Backwards compatibility for HomeScreen
      'ratingsCount': volumeInfo['ratingsCount'] ?? 0,
      'language': volumeInfo['language']?.toString() ?? 'en',
      'categories': (volumeInfo['categories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      'publisher': volumeInfo['publisher']?.toString() ?? '',
      'publishedDate': volumeInfo['publishedDate']?.toString() ?? '',
      'webReaderLink': webReaderLink,
      'previewLink': previewLink,
      'infoLink': volumeInfo['infoLink']?.toString() ?? '',
      'canonicalVolumeLink':
          volumeInfo['canonicalVolumeLink']?.toString() ?? '',
      'isGutenberg': false,
    };
  }
}
