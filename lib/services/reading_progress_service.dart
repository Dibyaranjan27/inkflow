import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage reading progress and reading history persisted in [SharedPreferences].
class ReadingProgressService {
  ReadingProgressService._();

  static const String _defaultUserKey = 'guest';

  static String _getUserKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null && user.email!.isNotEmpty) {
      return user.email!;
    }
    return _defaultUserKey;
  }

  static String _storageKey() => '${_getUserKey()}_reading_history';

  /// Save or update reading progress for a book.
  static Future<void> saveProgress({
    required String bookId,
    required String bookTitle,
    required String bookCover,
    required String authors,
    required int currentPage,
    required int totalPages,
    required Map<String, dynamic> bookData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey();
      final existingJson = prefs.getString(key);
      Map<String, dynamic> history = {};

      if (existingJson != null && existingJson.isNotEmpty) {
        try {
          history = json.decode(existingJson) as Map<String, dynamic>;
        } catch (_) {
          history = {};
        }
      }

      final safeTotalPages = totalPages > 0 ? totalPages : 1;
      final safeCurrentPage = currentPage.clamp(1, safeTotalPages);
      final percent = ((safeCurrentPage / safeTotalPages) * 100).round();

      history[bookId] = {
        'bookId': bookId,
        'bookTitle': bookTitle.isNotEmpty ? bookTitle : 'Untitled Book',
        'bookCover': bookCover,
        'authors': authors.isNotEmpty ? authors : 'Unknown Author',
        'currentPage': safeCurrentPage,
        'totalPages': safeTotalPages,
        'percent': percent,
        'lastReadTimestamp': DateTime.now().millisecondsSinceEpoch,
        'bookData': bookData,
      };

      await prefs.setString(key, json.encode(history));
    } catch (e) {
      // Graceful error logging
    }
  }

  /// Retrieve all continue reading items sorted by most recently read.
  static Future<List<Map<String, dynamic>>> getContinueReadingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey();
      final existingJson = prefs.getString(key);

      if (existingJson == null || existingJson.isEmpty) {
        return [];
      }

      final Map<String, dynamic> history =
          json.decode(existingJson) as Map<String, dynamic>;

      final list = history.values.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      // Sort descending by lastReadTimestamp
      list.sort((a, b) {
        final int timeA = (a['lastReadTimestamp'] as int?) ?? 0;
        final int timeB = (b['lastReadTimestamp'] as int?) ?? 0;
        return timeB.compareTo(timeA);
      });

      return list;
    } catch (_) {
      return [];
    }
  }

  /// Retrieve the most recently read book for the home screen continue reading widget.
  static Future<Map<String, dynamic>?> getMostRecentBook() async {
    final list = await getContinueReadingList();
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  /// Remove a book from continue reading.
  static Future<void> removeProgress(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey();
      final existingJson = prefs.getString(key);

      if (existingJson != null && existingJson.isNotEmpty) {
        final Map<String, dynamic> history =
            json.decode(existingJson) as Map<String, dynamic>;
        history.remove(bookId);
        await prefs.setString(key, json.encode(history));
      }
    } catch (_) {}
  }
}
