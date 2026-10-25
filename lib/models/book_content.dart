/// Represents a single parsed chapter in a book, containing its raw text
/// and paginated pages.
class BookChapter {
  /// Zero-based index of this chapter in the book.
  final int chapterIndex;

  /// Display title of the chapter (e.g., "Chapter 1: Down the Rabbit-Hole", "Letter 1", "Section 1").
  final String title;

  /// Full text content of the chapter.
  final String content;

  /// Paginated text segments of the chapter, sized for comfortable e-reading (~250-350 words).
  final List<String> pages;

  BookChapter({
    required this.chapterIndex,
    required this.title,
    required this.content,
    required this.pages,
  });

  /// Total number of pages in this chapter (guaranteed >= 1).
  int get pageCount => pages.isEmpty ? 1 : pages.length;

  /// Safe accessor for a page by index.
  String getPage(int index) {
    if (pages.isEmpty) return content;
    if (index < 0) return pages.first;
    if (index >= pages.length) return pages.last;
    return pages[index];
  }

  /// Serialization to Map
  Map<String, dynamic> toJson() {
    return {
      'chapterIndex': chapterIndex,
      'title': title,
      'content': content,
      'pages': pages,
    };
  }

  /// Deserialization from Map
  factory BookChapter.fromJson(Map<String, dynamic> json) {
    return BookChapter(
      chapterIndex: json['chapterIndex'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Chapter',
      content: json['content'] as String? ?? '',
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// Represents the complete parsed content of a book, including its metadata
/// and all structured chapters with pagination helpers.
class BookContent {
  /// Identifier of the book (Gutenberg ID or volume ID).
  final String bookId;

  /// Book title.
  final String title;

  /// Author name(s).
  final String author;

  /// List of chapters in reading order.
  final List<BookChapter> chapters;

  /// Optional book cover image URL.
  final String? coverUrl;

  BookContent({
    required this.bookId,
    required this.title,
    required this.author,
    required this.chapters,
    this.coverUrl,
  });

  /// Total number of chapters.
  int get totalChapters => chapters.length;

  /// Total number of pages across all chapters combined.
  int get totalPages {
    if (chapters.isEmpty) return 1;
    return chapters.fold<int>(0, (sum, ch) => sum + ch.pageCount);
  }

  /// Whether the book content contains any chapters.
  bool get isEmpty => chapters.isEmpty;
  bool get isNotEmpty => chapters.isNotEmpty;

  /// Safe accessor for a chapter by index.
  BookChapter? getChapter(int index) {
    if (index < 0 || index >= chapters.length) return null;
    return chapters[index];
  }

  /// Calculates the 1-based overall page number across the entire book
  /// given a [chapterIndex] and [pageInChapter] (both 0-based).
  ///
  /// For example, if Chapter 0 has 5 pages (pages 1-5 overall),
  /// Chapter 1, page 0 will return 6 (page 6 overall).
  int calculateOverallPage(int chapterIndex, int pageInChapter) {
    if (chapters.isEmpty) return 1;
    int page = 0;
    for (int i = 0; i < chapterIndex && i < chapters.length; i++) {
      page += chapters[i].pageCount;
    }
    return page + pageInChapter + 1;
  }

  /// Reverse lookup: Given a 1-based [overallPage] (from 1 to [totalPages]),
  /// finds the corresponding [chapterIndex] and [pageInChapter] (both 0-based).
  ///
  /// Returns a map with keys `'chapterIndex'` and `'pageInChapter'`.
  /// If [overallPage] <= 1, returns `{'chapterIndex': 0, 'pageInChapter': 0}`.
  /// If [overallPage] exceeds [totalPages], returns the last page of the last chapter.
  Map<String, int> findChapterAndPage(int overallPage) {
    if (chapters.isEmpty) {
      return {'chapterIndex': 0, 'pageInChapter': 0};
    }

    if (overallPage <= 1) {
      return {'chapterIndex': 0, 'pageInChapter': 0};
    }

    int remaining = overallPage - 1; // Convert to 0-based running count
    for (int i = 0; i < chapters.length; i++) {
      final ch = chapters[i];
      if (remaining < ch.pageCount) {
        return {'chapterIndex': i, 'pageInChapter': remaining};
      }
      remaining -= ch.pageCount;
    }

    // If overallPage exceeds totalPages, clamp to last page of last chapter
    final lastChapterIndex = chapters.length - 1;
    final lastPageInChapter = chapters[lastChapterIndex].pageCount - 1;
    return {
      'chapterIndex': lastChapterIndex,
      'pageInChapter': lastPageInChapter < 0 ? 0 : lastPageInChapter,
    };
  }

  /// Calculates overall reading progress percentage (0.0 to 1.0).
  double calculateProgress(int chapterIndex, int pageInChapter) {
    final total = totalPages;
    if (total <= 0) return 0.0;
    final current = calculateOverallPage(chapterIndex, pageInChapter);
    return (current / total).clamp(0.0, 1.0);
  }

  /// Serialization to Map
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }

  /// Deserialization from Map
  factory BookContent.fromJson(Map<String, dynamic> json) {
    return BookContent(
      bookId: json['bookId'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      author: json['author'] as String? ?? 'Unknown Author',
      coverUrl: json['coverUrl'] as String?,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((c) => BookChapter.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
