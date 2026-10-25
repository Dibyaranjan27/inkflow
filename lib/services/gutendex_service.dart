import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:inkflow/models/book_content.dart';
import 'package:inkflow/services/gutenberg_parser.dart';

/// Service responsible for querying Gutendex API, fetching Project Gutenberg
/// full-text classic literature, caching texts to local disk, and resolving
/// public domain titles for the Inkflow e-reader.
class GutendexService {
  static const String baseUrl = 'https://gutendex.com/books';

  /// Critical: Custom User-Agent to bypass Project Gutenberg 403 Forbidden bot blocks.
  static const String userAgent = 'InkflowReader/1.0 (Flutter; Mobile)';

  static const Map<String, String> _headers = {
    'User-Agent': userAgent,
    'Accept': 'text/plain, text/html, application/json, */*',
  };

  /// Gutenberg IDs of 12 popular, curated classic titles.
  static const List<int> featuredGutenbergIds = [
    84, // Frankenstein - Mary Shelley
    1342, // Pride and Prejudice - Jane Austen
    11, // Alice's Adventures in Wonderland - Lewis Carroll
    1661, // The Adventures of Sherlock Holmes - Arthur Conan Doyle
    345, // Dracula - Bram Stoker
    98, // A Tale of Two Cities - Charles Dickens
    174, // The Picture of Dorian Gray - Oscar Wilde
    2701, // Moby Dick - Herman Melville
    5200, // Metamorphosis - Franz Kafka
    35, // The Time Machine - H.G. Wells
    43, // The Strange Case of Dr. Jekyll and Mr. Hyde - R.L. Stevenson
    64317, // The Great Gatsby - F. Scott Fitzgerald
  ];

  /// Comprehensive offline fallback metadata for the 12 curated classics.
  /// Ensures the Free Classics shelf is always populated even on airplane mode.
  static const List<Map<String, dynamic>> _curatedClassics = [
    {
      'id': '84',
      'gutenbergId': 84,
      'title': 'Frankenstein; Or, The Modern Prometheus',
      'authors': 'Mary Wollstonecraft Shelley',
      'author': 'Mary Wollstonecraft Shelley',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/84/pg84.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/84.txt.utf-8',
      'rating': 4.6,
      'averageRating': 4.6,
      'description':
          'Victor Frankenstein succeeds in creating a sentient creature in an unorthodox scientific experiment, exploring the consequences of playing God.',
      'pageCount': 280,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 65000,
    },
    {
      'id': '1342',
      'gutenbergId': 1342,
      'title': 'Pride and Prejudice',
      'authors': 'Jane Austen',
      'author': 'Jane Austen',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1342/pg1342.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/1342.txt.utf-8',
      'rating': 4.8,
      'averageRating': 4.8,
      'description':
          'The romantic clash between the opinionated Elizabeth Bennet and her proud beau, Mr. Darcy, in 19th-century England.',
      'pageCount': 432,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 52000,
    },
    {
      'id': '11',
      'gutenbergId': 11,
      'title': "Alice's Adventures in Wonderland",
      'authors': 'Lewis Carroll',
      'author': 'Lewis Carroll',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/11/pg11.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/11.txt.utf-8',
      'rating': 4.5,
      'averageRating': 4.5,
      'description':
          'Alice falls through a rabbit hole into a subterranean fantasy world of anthropomorphic creatures and whimsical logic.',
      'pageCount': 192,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 38000,
    },
    {
      'id': '1661',
      'gutenbergId': 1661,
      'title': 'The Adventures of Sherlock Holmes',
      'authors': 'Arthur Conan Doyle',
      'author': 'Arthur Conan Doyle',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1661/pg1661.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/1661.txt.utf-8',
      'rating': 4.7,
      'averageRating': 4.7,
      'description':
          'A treasury of brilliant detective cases investigated by Sherlock Holmes and Dr. John H. Watson in Victorian London.',
      'pageCount': 307,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 45000,
    },
    {
      'id': '345',
      'gutenbergId': 345,
      'title': 'Dracula',
      'authors': 'Bram Stoker',
      'author': 'Bram Stoker',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/345/pg345.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/345.txt.utf-8',
      'rating': 4.6,
      'averageRating': 4.6,
      'description':
          'The sinister Transylvanian Count Dracula journeys to Victorian England, countered by Professor Abraham Van Helsing.',
      'pageCount': 418,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 34000,
    },
    {
      'id': '98',
      'gutenbergId': 98,
      'title': 'A Tale of Two Cities',
      'authors': 'Charles Dickens',
      'author': 'Charles Dickens',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/98/pg98.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/98.txt.utf-8',
      'rating': 4.6,
      'averageRating': 4.6,
      'description':
          'A sweeping historical saga of sacrifice and resurrection set in London and Paris during the turmoil of the French Revolution.',
      'pageCount': 341,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 29000,
    },
    {
      'id': '174',
      'gutenbergId': 174,
      'title': 'The Picture of Dorian Gray',
      'authors': 'Oscar Wilde',
      'author': 'Oscar Wilde',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/174/pg174.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/174.txt.utf-8',
      'rating': 4.7,
      'averageRating': 4.7,
      'description':
          'A young hedonist trades his soul for eternal youth while an enchanted portrait in his attic bears the marks of his sins.',
      'pageCount': 250,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 31000,
    },
    {
      'id': '2701',
      'gutenbergId': 2701,
      'title': 'Moby Dick; Or, The Whale',
      'authors': 'Herman Melville',
      'author': 'Herman Melville',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/2701/pg2701.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/2701.txt.utf-8',
      'rating': 4.4,
      'averageRating': 4.4,
      'description':
          'Captain Ahab leads the Pequod on an obsessive, doomed pursuit of the elusive white whale that took his leg.',
      'pageCount': 635,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 27000,
    },
    {
      'id': '5200',
      'gutenbergId': 5200,
      'title': 'Metamorphosis',
      'authors': 'Franz Kafka',
      'author': 'Franz Kafka',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/5200/pg5200.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/5200.txt.utf-8',
      'rating': 4.5,
      'averageRating': 4.5,
      'description':
          'Traveling salesman Gregor Samsa awakens to find himself inexplicably transformed into a giant, grotesque insect.',
      'pageCount': 90,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 26000,
    },
    {
      'id': '35',
      'gutenbergId': 35,
      'title': 'The Time Machine',
      'authors': 'H.G. Wells',
      'author': 'H.G. Wells',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/35/pg35.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/35.txt.utf-8',
      'rating': 4.5,
      'averageRating': 4.5,
      'description':
          'An English scientist invents a device that transports him to AD 802,701, uncovering the fractured destiny of mankind.',
      'pageCount': 118,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 24000,
    },
    {
      'id': '43',
      'gutenbergId': 43,
      'title': 'The Strange Case of Dr. Jekyll and Mr. Hyde',
      'authors': 'Robert Louis Stevenson',
      'author': 'Robert Louis Stevenson',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/43/pg43.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/43.txt.utf-8',
      'rating': 4.6,
      'averageRating': 4.6,
      'description':
          'Dr. Henry Jekyll experiments with a chemical concoction that liberates his dark, malevolent alter ego, Edward Hyde.',
      'pageCount': 144,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 25000,
    },
    {
      'id': '64317',
      'gutenbergId': 64317,
      'title': 'The Great Gatsby',
      'authors': 'F. Scott Fitzgerald',
      'author': 'F. Scott Fitzgerald',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/64317/pg64317.cover.medium.jpg',
      'textUrl': 'https://www.gutenberg.org/ebooks/64317/pg64317.txt.utf-8',
      'rating': 4.7,
      'averageRating': 4.7,
      'description':
          'In 1922 Long Island, Jay Gatsby hosts extravagant parties in desperate yearning for the lost love of Daisy Buchanan.',
      'pageCount': 180,
      'language': 'en',
      'isGutenberg': true,
      'downloadCount': 33000,
    },
  ];

  /// Fetches featured classic books. First attempts Gutendex API; on error
  /// or timeout, falls back to the curated classics list.
  Future<List<Map<String, dynamic>>> getFeaturedClassics() async {
    try {
      final idsParam = featuredGutenbergIds.join(',');
      final uri = Uri.parse('$baseUrl?ids=$idsParam');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data['results'] as List?) ?? [];
        if (results.isNotEmpty) {
          return results.map((b) => _formatGutenbergBook(b)).toList();
        }
      }
    } catch (e) {
      debugPrint('GutendexService.getFeaturedClassics network fallback: $e');
    }
    // Return offline fallback curated list
    return List<Map<String, dynamic>>.from(_curatedClassics);
  }

  /// Searches Gutendex for public domain classic books.
  Future<List<Map<String, dynamic>>> searchClassics(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return getFeaturedClassics();
    }

    try {
      final uri = Uri.parse('$baseUrl/?search=${Uri.encodeComponent(cleanQuery)}&languages=en');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data['results'] as List?) ?? [];
        if (results.isNotEmpty) {
          return results.map((b) => _formatGutenbergBook(b)).toList();
        }
      }
    } catch (e) {
      debugPrint('GutendexService.searchClassics network error: $e');
    }

    // Fallback: match query against local curated classics
    final q = cleanQuery.toLowerCase();
    final localMatches = _curatedClassics.where((b) {
      final t = b['title'].toString().toLowerCase();
      final a = b['authors'].toString().toLowerCase();
      return t.contains(q) || a.contains(q);
    }).toList();

    return localMatches;
  }

  /// Fetches the genuine full text of a Gutenberg book with disk caching.
  /// 1. Checks local file cache (${documentsDir}/gutenberg_cache/book_${gutenbergId}.txt).
  /// 2. If missing, downloads with custom User-Agent to avoid 403 Forbidden.
  /// 3. Saves to cache file asynchronously.
  /// 4. Parses via GutenbergParser and returns structured BookContent.
  Future<BookContent> fetchBookContent({
    required int gutenbergId,
    String? textUrl,
    required String title,
    String? author,
    String? coverUrl,
  }) async {
    // 1. Check local disk cache
    final cachedText = await getCachedText(gutenbergId);
    if (cachedText != null && cachedText.trim().isNotEmpty) {
      return GutenbergParser.parseBook(
        bookId: gutenbergId.toString(),
        title: title,
        author: author ?? 'Unknown Author',
        rawText: cachedText,
        coverUrl: coverUrl,
      );
    }

    // 2. Build candidate URLs in order of preference
    final urlsToTry = <String>[];
    if (textUrl != null && textUrl.trim().isNotEmpty) {
      urlsToTry.add(textUrl.trim());
    }
    urlsToTry.add('https://www.gutenberg.org/ebooks/$gutenbergId.txt.utf-8');
    urlsToTry.add('https://www.gutenberg.org/files/$gutenbergId/$gutenbergId-0.txt');
    urlsToTry.add('https://www.gutenberg.org/cache/epub/$gutenbergId/pg$gutenbergId.txt');

    String? downloadedText;
    Exception? lastException;

    for (final url in urlsToTry) {
      try {
        final uri = Uri.parse(url);
        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 && response.body.trim().length > 200) {
          final prefix = response.body
              .substring(0, 100.clamp(0, response.body.length))
              .toLowerCase();
          // Verify body is actual plain text and not an HTML error/block page
          if (!prefix.contains('<!doctype html') && !prefix.contains('<html')) {
            downloadedText = response.body;
            break;
          }
        }
      } catch (e) {
        lastException = Exception('Failed to download from $url: $e');
      }
    }

    if (downloadedText != null && downloadedText.trim().isNotEmpty) {
      // Save to local cache asynchronously
      unawaited(saveCachedText(gutenbergId, downloadedText));

      return GutenbergParser.parseBook(
        bookId: gutenbergId.toString(),
        title: title,
        author: author ?? 'Unknown Author',
        rawText: downloadedText,
        coverUrl: coverUrl,
      );
    }

    throw lastException ??
        Exception(
            'Unable to download book text for "$title" (Gutenberg ID $gutenbergId). Please verify your internet connection and retry.');
  }

  /// Searches Gutendex for a title and, if found, fetches and returns its BookContent.
  /// If not found or on error, returns null (enabling callers to fall back to Google Books).
  Future<BookContent?> findAndFetchByTitle(String title, {String? author}) async {
    final cleanTitle = title
        .split(':')
        .first
        .split('-')
        .first
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .trim();

    if (cleanTitle.isEmpty) return null;

    try {
      final matches = await searchClassics(cleanTitle);
      if (matches.isEmpty) return null;

      // Select the best match
      Map<String, dynamic> selected = matches.first;
      if (author != null && author.isNotEmpty) {
        final authorLower = author.toLowerCase();
        final matchWithAuthor = matches.firstWhere(
          (m) => m['authors'].toString().toLowerCase().contains(authorLower),
          orElse: () => matches.first,
        );
        selected = matchWithAuthor;
      }

      final gutenbergId = selected['gutenbergId'] as int;
      final textUrl = selected['textUrl'] as String?;
      final bookTitle = selected['title'] as String;
      final bookAuthor = selected['authors'] as String?;
      final cover = selected['thumbnail'] as String?;

      return await fetchBookContent(
        gutenbergId: gutenbergId,
        textUrl: textUrl,
        title: bookTitle,
        author: bookAuthor,
        coverUrl: cover,
      );
    } catch (e) {
      debugPrint('GutendexService.findAndFetchByTitle failed: $e');
      return null;
    }
  }

  // --- Local Disk Caching Helpers ---

  Future<File> getCacheFile(int gutenbergId) async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/gutenberg_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return File('${cacheDir.path}/book_$gutenbergId.txt');
  }

  Future<bool> isBookCached(int gutenbergId) async {
    try {
      final file = await getCacheFile(gutenbergId);
      return await file.exists() && (await file.length()) > 0;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getCachedText(int gutenbergId) async {
    try {
      final file = await getCacheFile(gutenbergId);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          return content;
        }
      }
    } catch (e) {
      debugPrint('GutendexService cache read error: $e');
    }
    return null;
  }

  Future<void> saveCachedText(int gutenbergId, String text) async {
    try {
      final file = await getCacheFile(gutenbergId);
      await file.writeAsString(text);
    } catch (e) {
      debugPrint('GutendexService cache write error: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/gutenberg_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  Future<int> getCachedBooksCount() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/gutenberg_cache');
      if (await cacheDir.exists()) {
        final files = cacheDir.listSync();
        return files.whereType<File>().length;
      }
    } catch (_) {}
    return 0;
  }

  // --- Normalization Helpers ---

  /// Formats raw Gutenberg author strings like "Austen, Jane" into "Jane Austen".
  static String formatAuthorName(String rawName) {
    if (rawName.contains(',')) {
      final parts = rawName.split(',').map((p) => p.trim()).toList();
      if (parts.length >= 2) {
        return '${parts[1]} ${parts[0]}';
      }
    }
    return rawName.trim();
  }

  /// Maps raw Gutendex API book object into standardized Inkflow book format.
  static Map<String, dynamic> _formatGutenbergBook(dynamic raw) {
    final book = raw as Map<String, dynamic>? ?? {};
    final id = book['id'] is int
        ? book['id'] as int
        : int.tryParse(book['id']?.toString() ?? '') ?? 0;

    final title = book['title']?.toString() ?? 'Untitled Classic';

    final authorsList = book['authors'] as List? ?? [];
    String authors = 'Unknown Author';
    if (authorsList.isNotEmpty) {
      authors = authorsList
          .map((a) => formatAuthorName(a['name']?.toString() ?? ''))
          .where((n) => n.isNotEmpty)
          .join(', ');
    }

    final formats = book['formats'] as Map<String, dynamic>? ?? {};
    final thumbnail = formats['image/jpeg']?.toString() ??
        'https://www.gutenberg.org/cache/epub/$id/pg$id.cover.medium.jpg';

    final textUrl = formats['text/plain; charset=utf-8']?.toString() ??
        formats['text/plain; charset=us-ascii']?.toString() ??
        formats['text/plain']?.toString() ??
        'https://www.gutenberg.org/ebooks/$id.txt.utf-8';

    final subjects = (book['subjects'] as List?)?.join(', ') ?? '';
    final description = subjects.isNotEmpty
        ? subjects
        : 'A timeless public domain classic from Project Gutenberg.';

    return {
      'id': id.toString(),
      'gutenbergId': id,
      'title': title,
      'authors': authors,
      'author': authors,
      'thumbnail': thumbnail,
      'textUrl': textUrl,
      'rating': 4.6,
      'averageRating': 4.6,
      'description': description,
      'pageCount': 250,
      'language': (book['languages'] as List?)?.firstOrNull?.toString() ?? 'en',
      'isGutenberg': true,
      'downloadCount': book['download_count'] ?? 0,
    };
  }
}
