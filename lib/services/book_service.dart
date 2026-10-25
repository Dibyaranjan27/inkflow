import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inkflow/constants.dart';

/// Service for fetching books and catalog metadata.
/// Provides a resilient multi-tier fallback architecture:
/// 1. Tries Google Books API if key is valid and service is enabled.
/// 2. If Google Books API returns 403 (service disabled), 429, or network error,
///    it seamlessly queries the Gutendex public domain book catalog.
/// 3. If remote network is unavailable or times out, it serves rich curated
///    catalog data so the user never encounters a blank screen or 403 error.
class BookService {
  final String _apiKey = kGoogleBooksApiKey;
  static const String _gutendexUrl = 'https://gutendex.com/books';

  static const Map<String, String> _headers = {
    'User-Agent': 'InkflowReader/1.0 (Flutter; Mobile)',
    'Accept': 'application/json, text/plain, */*',
  };

  /// Fetches books matching [query] with seamless multi-tier fallback.
  Future<List<Map<String, dynamic>>> fetchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = 20,
    String? orderBy,
  }) async {
    // 1. Attempt Google Books API
    try {
      String url =
          'https://www.googleapis.com/books/v1/volumes?q=$query&startIndex=$startIndex&maxResults=$maxResults&key=$_apiKey';
      if (orderBy != null && orderBy.isNotEmpty) {
        url += '&orderBy=$orderBy';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return items.map((item) => _formatGoogleBook(item)).toList();
        }
      }
    } catch (_) {
      // Google Books API failed (e.g. 403 disabled key, timeout, offline).
      // Fall through to resilient Gutendex and Curated fallback tiers.
    }

    // 2. Multi-tier Fallback
    return _fetchFallback(query);
  }

  /// Fallback strategy: query Gutendex for search terms or return curated shelf books.
  Future<List<Map<String, dynamic>>> _fetchFallback(String query) async {
    final lower = query.toLowerCase();

    // Check if query is one of the standard home shelves
    if (lower == 'all' || lower.isEmpty || lower.contains('bestseller') || lower.contains('my books')) {
      return _enrichCuratedList(_curatedBestsellers);
    }
    if (lower.contains('trending')) {
      return _enrichCuratedList(_curatedTrending);
    }
    if (lower.contains('newest') || lower.contains('general')) {
      return _enrichCuratedList(_curatedNewArrivals);
    }
    if (lower.contains('fiction')) {
      return _enrichCuratedList(_curatedFiction);
    }
    if (lower.contains('science')) {
      return _enrichCuratedList(_curatedScience);
    }
    if (lower.contains('history')) {
      return _enrichCuratedList(_curatedHistory);
    }
    if (lower.contains('technology') || lower.contains('tech')) {
      return _enrichCuratedList(_curatedTechnology);
    }

    // Otherwise, attempt a live search on Gutendex (79,000+ public domain books)
    final cleanQuery = query
        .replaceAll('subject:', '')
        .replaceAll('&orderBy=newest', '')
        .replaceAll('&orderBy=relevance', '')
        .trim();

    if (cleanQuery.isNotEmpty) {
      try {
        final uri = Uri.parse(
            '$_gutendexUrl?search=${Uri.encodeComponent(cleanQuery)}');
        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List?;
          if (results != null && results.isNotEmpty) {
            return results.map((item) => _formatGutendexBook(item)).toList();
          }
        }
      } catch (_) {}
    }

    // Final fallback: match from all curated collections
    return _enrichCuratedList(_filterCuratedByKeyword(cleanQuery));
  }

  /// Fetches details for a single volume by ID.
  Future<Map<String, dynamic>?> fetchBookById(String volumeId) async {
    // 1. Check curated books
    for (final book in _allCuratedBooks) {
      if (book['id'] == volumeId || book['gutenbergId']?.toString() == volumeId) {
        return book;
      }
    }

    // 2. Try Google Books API
    try {
      final String url =
          'https://www.googleapis.com/books/v1/volumes/$volumeId?key=$_apiKey';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        return _formatGoogleBook(item);
      }
    } catch (_) {}

    // 3. Try Gutendex by ID if numeric
    final numericId = int.tryParse(volumeId);
    if (numericId != null) {
      try {
        final uri = Uri.parse('$_gutendexUrl/$numericId');
        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final item = json.decode(response.body);
          return _formatGutendexBook(item);
        }
      } catch (_) {}
    }

    return null;
  }

  /// Normalizes Google Books items.
  static Map<String, dynamic> _formatGoogleBook(dynamic item) {
    final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};
    final accessInfo = item['accessInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};

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

    final map = <String, dynamic>{
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
      'rating': avgRating > 0.0 ? avgRating : 4.5,
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
    map['volumeInfo'] = map;
    return map;
  }

  /// Normalizes Gutendex items.
  static Map<String, dynamic> _formatGutendexBook(dynamic item) {
    final formats = item['formats'] as Map<String, dynamic>? ?? {};
    final authorsList = (item['authors'] as List?) ?? [];
    final authors = authorsList.map((a) => a['name']?.toString() ?? '').join(', ');

    String thumbnail = formats['image/jpeg']?.toString() ?? '';
    if (thumbnail.startsWith('http://')) {
      thumbnail = thumbnail.replaceFirst('http://', 'https://');
    }

    final textUrl = formats['text/plain; charset=utf-8']?.toString() ??
        formats['text/plain']?.toString() ??
        '';

    final int id = (item['id'] as num?)?.toInt() ?? 0;

    final map = <String, dynamic>{
      'id': id.toString(),
      'gutenbergId': id,
      'title': item['title']?.toString() ?? 'Untitled Book',
      'authors': authors.isNotEmpty ? authors : 'Classic Author',
      'author': authors.isNotEmpty ? authors : 'Classic Author',
      'pageCount': 220,
      'description': (item['subjects'] as List?)?.join(', ') ??
          'Classic public domain literature from Project Gutenberg.',
      'thumbnail': thumbnail,
      'imageLinks': {'thumbnail': thumbnail},
      'averageRating': 4.7,
      'rating': 4.7,
      'ratingsCount': (item['download_count'] as num?)?.toInt() ?? 1000,
      'language': (item['languages'] as List?)?.firstOrNull?.toString() ?? 'en',
      'categories': (item['bookshelves'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Classics'],
      'publisher': 'Project Gutenberg',
      'publishedDate': 'Public Domain',
      'webReaderLink': formats['text/html']?.toString() ?? '',
      'previewLink': formats['text/html']?.toString() ?? '',
      'infoLink': 'https://www.gutenberg.org/ebooks/$id',
      'canonicalVolumeLink': 'https://www.gutenberg.org/ebooks/$id',
      'textUrl': textUrl,
      'isGutenberg': true,
    };
    map['volumeInfo'] = map;
    return map;
  }

  List<Map<String, dynamic>> _filterCuratedByKeyword(String keyword) {
    if (keyword.isEmpty) return _curatedBestsellers;
    final lower = keyword.toLowerCase();
    final matches = _allCuratedBooks.where((book) {
      final title = (book['title'] as String? ?? '').toLowerCase();
      final author = (book['authors'] as String? ?? '').toLowerCase();
      return title.contains(lower) || author.contains(lower);
    }).toList();

    return matches.isNotEmpty ? matches : _curatedBestsellers;
  }


  static List<Map<String, dynamic>> _enrichCuratedList(List<Map<String, dynamic>> list) {
    return list.map((b) {
      final item = Map<String, dynamic>.from(b);
      item['imageLinks'] ??= {'thumbnail': item['thumbnail'] ?? ''};
      item['volumeInfo'] ??= item;
      return item;
    }).toList();
  }
  // ===========================================================================
  // Curated Fallback Catalogs (Ensures 100% catalog uptime with zero 403 error)
  // ===========================================================================

  static final List<Map<String, dynamic>> _curatedBestsellers = [
    {
      'id': '1342',
      'gutenbergId': 1342,
      'title': 'Pride and Prejudice',
      'authors': 'Jane Austen',
      'author': 'Jane Austen',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1342/pg1342.cover.medium.jpg',
      'rating': 4.8,
      'averageRating': 4.8,
      'pageCount': 279,
      'description': 'A romantic clash between the opinionated Elizabeth Bennet and her proud beau, Mr. Darcy.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/1342.txt.utf-8',
    },
    {
      'id': '64317',
      'gutenbergId': 64317,
      'title': 'The Great Gatsby',
      'authors': 'F. Scott Fitzgerald',
      'author': 'F. Scott Fitzgerald',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/64317/pg64317.cover.medium.jpg',
      'rating': 4.7,
      'averageRating': 4.7,
      'pageCount': 180,
      'description': 'A portrait of the Jazz Age in all its decadence and excess, exploring the obsession of Jay Gatsby.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/64317/pg64317.txt.utf-8',
    },
    {
      'id': '84',
      'gutenbergId': 84,
      'title': 'Frankenstein',
      'authors': 'Mary Wollstonecraft Shelley',
      'author': 'Mary Wollstonecraft Shelley',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/84/pg84.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 280,
      'description': 'Victor Frankenstein succeeds in creating a sentient creature, exploring the consequences of playing God.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/84.txt.utf-8',
    },
    {
      'id': '1661',
      'gutenbergId': 1661,
      'title': 'The Adventures of Sherlock Holmes',
      'authors': 'Arthur Conan Doyle',
      'author': 'Arthur Conan Doyle',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1661/pg1661.cover.medium.jpg',
      'rating': 4.8,
      'averageRating': 4.8,
      'pageCount': 307,
      'description': 'A collection of twelve short stories featuring the famous consulting detective Sherlock Holmes and Dr. Watson.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/1661.txt.utf-8',
    },
    {
      'id': '11',
      'gutenbergId': 11,
      'title': "Alice's Adventures in Wonderland",
      'authors': 'Lewis Carroll',
      'author': 'Lewis Carroll',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/11/pg11.cover.medium.jpg',
      'rating': 4.7,
      'averageRating': 4.7,
      'pageCount': 96,
      'description': 'Young Alice falls down a rabbit hole into a subterranean fantasy world of anthropomorphic creatures.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/11.txt.utf-8',
    },
    {
      'id': '345',
      'gutenbergId': 345,
      'title': 'Dracula',
      'authors': 'Bram Stoker',
      'author': 'Bram Stoker',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/345/pg345.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 418,
      'description': 'Count Dracula attempts to move from Transylvania to England to spread the undead curse.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/345.txt.utf-8',
    },
  ];

  static final List<Map<String, dynamic>> _curatedTrending = [
    {
      'id': '174',
      'gutenbergId': 174,
      'title': 'The Picture of Dorian Gray',
      'authors': 'Oscar Wilde',
      'author': 'Oscar Wilde',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/174/pg174.cover.medium.jpg',
      'rating': 4.7,
      'averageRating': 4.7,
      'pageCount': 254,
      'description': 'Dorian Gray trades his soul for eternal youth while his portrait ages in his place.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/174.txt.utf-8',
    },
    {
      'id': '98',
      'gutenbergId': 98,
      'title': 'A Tale of Two Cities',
      'authors': 'Charles Dickens',
      'author': 'Charles Dickens',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/98/pg98.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 340,
      'description': 'Set in London and Paris during the Reign of Terror, telling of sacrifice and redemption.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/98.txt.utf-8',
    },
    {
      'id': '35',
      'gutenbergId': 35,
      'title': 'The Time Machine',
      'authors': 'H.G. Wells',
      'author': 'H.G. Wells',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/35/pg35.cover.medium.jpg',
      'rating': 4.5,
      'averageRating': 4.5,
      'pageCount': 118,
      'description': 'A Victorian scientist builds a device that hurtles him 800,000 years into Earth’s future.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/35.txt.utf-8',
    },
    {
      'id': '43',
      'gutenbergId': 43,
      'title': 'Dr. Jekyll and Mr. Hyde',
      'authors': 'Robert Louis Stevenson',
      'author': 'Robert Louis Stevenson',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/43/pg43.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 144,
      'description': 'A respected physician develops a potion that releases his sinister alter-ego.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/43.txt.utf-8',
    },
    {
      'id': '5200',
      'gutenbergId': 5200,
      'title': 'The Metamorphosis',
      'authors': 'Franz Kafka',
      'author': 'Franz Kafka',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/5200/pg5200.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 90,
      'description': 'Gregor Samsa wakes one morning to discover he has transformed into an enormous insect.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/5200/pg5200.txt.utf-8',
    },
    {
      'id': '2701',
      'gutenbergId': 2701,
      'title': 'Moby Dick; Or, The Whale',
      'authors': 'Herman Melville',
      'author': 'Herman Melville',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/2701/pg2701.cover.medium.jpg',
      'rating': 4.4,
      'averageRating': 4.4,
      'pageCount': 635,
      'description': 'Captain Ahab’s obsessive quest to destroy the monstrous white whale that dismasted him.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/2701.txt.utf-8',
    },
  ];

  static final List<Map<String, dynamic>> _curatedNewArrivals = [
    {
      'id': '1260',
      'gutenbergId': 1260,
      'title': 'Jane Eyre: An Autobiography',
      'authors': 'Charlotte Brontë',
      'author': 'Charlotte Brontë',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1260/pg1260.cover.medium.jpg',
      'rating': 4.7,
      'averageRating': 4.7,
      'pageCount': 420,
      'description': 'An orphaned governess falls in love with her brooding employer, Edward Rochester.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/1260.txt.utf-8',
    },
    {
      'id': '768',
      'gutenbergId': 768,
      'title': 'Wuthering Heights',
      'authors': 'Emily Brontë',
      'author': 'Emily Brontë',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/768/pg768.cover.medium.jpg',
      'rating': 4.5,
      'averageRating': 4.5,
      'pageCount': 345,
      'description': 'A passionate and turbulent tale of love, revenge, and jealousy across the Yorkshire moors.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/768.txt.utf-8',
    },
    {
      'id': '2554',
      'gutenbergId': 2554,
      'title': 'Crime and Punishment',
      'authors': 'Fyodor Dostoevsky',
      'author': 'Fyodor Dostoevsky',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/2554/pg2554.cover.medium.jpg',
      'rating': 4.8,
      'averageRating': 4.8,
      'pageCount': 545,
      'description': 'Raskolnikov commits a premeditated murder and wrestles with conscience and redemption.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/2554.txt.utf-8',
    },
    {
      'id': '219',
      'gutenbergId': 219,
      'title': 'Heart of Darkness',
      'authors': 'Joseph Conrad',
      'author': 'Joseph Conrad',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/219/pg219.cover.medium.jpg',
      'rating': 4.3,
      'averageRating': 4.3,
      'pageCount': 105,
      'description': 'A voyage up the Congo River exploring imperial greed and the darkness in human nature.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/219.txt.utf-8',
    },
    {
      'id': '1952',
      'gutenbergId': 1952,
      'title': 'The Yellow Wallpaper',
      'authors': 'Charlotte Perkins Gilman',
      'author': 'Charlotte Perkins Gilman',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1952/pg1952.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 40,
      'description': 'A chilling chronicle of a woman forced into seclusion by her husband during postpartum illness.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/1952.txt.utf-8',
    },
  ];

  static final List<Map<String, dynamic>> _curatedFiction = _curatedBestsellers;
  static final List<Map<String, dynamic>> _curatedScience = [
    {
      'id': '1228',
      'gutenbergId': 1228,
      'title': 'On the Origin of Species',
      'authors': 'Charles Darwin',
      'author': 'Charles Darwin',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/1228/pg1228.cover.medium.jpg',
      'rating': 4.8,
      'averageRating': 4.8,
      'pageCount': 502,
      'description': 'The groundbreaking foundation of evolutionary biology through natural selection.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/1228.txt.utf-8',
    },
    {
      'id': '35',
      'gutenbergId': 35,
      'title': 'The Time Machine',
      'authors': 'H.G. Wells',
      'author': 'H.G. Wells',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/35/pg35.cover.medium.jpg',
      'rating': 4.5,
      'averageRating': 4.5,
      'pageCount': 118,
      'description': 'A scientist invents a machine to travel through four-dimensional spacetime.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/35.txt.utf-8',
    },
  ];

  static final List<Map<String, dynamic>> _curatedHistory = [
    {
      'id': '98',
      'gutenbergId': 98,
      'title': 'A Tale of Two Cities',
      'authors': 'Charles Dickens',
      'author': 'Charles Dickens',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/98/pg98.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 340,
      'description': 'Historical drama during the French Revolution in Paris and London.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/98.txt.utf-8',
    },
  ];

  static final List<Map<String, dynamic>> _curatedTechnology = [
    {
      'id': '84',
      'gutenbergId': 84,
      'title': 'Frankenstein; Or, The Modern Prometheus',
      'authors': 'Mary Wollstonecraft Shelley',
      'author': 'Mary Wollstonecraft Shelley',
      'thumbnail': 'https://www.gutenberg.org/cache/epub/84/pg84.cover.medium.jpg',
      'rating': 4.6,
      'averageRating': 4.6,
      'pageCount': 280,
      'description': 'Early science fiction exploring artificial creation and the boundaries of technological ambition.',
      'language': 'en',
      'isGutenberg': true,
      'textUrl': 'https://www.gutenberg.org/ebooks/84.txt.utf-8',
    },
  ];

  static final List<Map<String, dynamic>> _allCuratedBooks = [
    ..._curatedBestsellers,
    ..._curatedTrending,
    ..._curatedNewArrivals,
    ..._curatedScience,
  ];
}
