import 'dart:math';
import 'package:inkflow/models/book_content.dart';

/// Service responsible for parsing raw Project Gutenberg text into structured
/// chapters, cleaning boilerplate, rejecting Table of Contents false-positives,
/// and paginating reading text without cutting sentences.
class GutenbergParser {
  /// Strips Project Gutenberg boilerplate headers and footers.
  static String stripBoilerplate(String raw) {
    if (raw.isEmpty) return '';

    // Standardize newline formatting
    String text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Regex for START marker (handles casing and minor wording variations)
    final startRegex = RegExp(
      r'\*\*\*\s*START OF (?:THE|THIS) PROJECT GUTENBERG EBOOK[\s\S]*?\*\*\*',
      caseSensitive: false,
    );

    // Regex for END marker
    final endRegex = RegExp(
      r'\*\*\*\s*END OF (?:THE|THIS) PROJECT GUTENBERG EBOOK',
      caseSensitive: false,
    );

    int startIndex = 0;
    final startMatch = startRegex.firstMatch(text);
    if (startMatch != null) {
      startIndex = startMatch.end;
    }

    int endIndex = text.length;
    final endMatch = endRegex.firstMatch(text);
    if (endMatch != null) {
      endIndex = endMatch.start;
    }

    // Safety check: ensure valid range
    if (startIndex < endIndex) {
      return text.substring(startIndex, endIndex).trim();
    }
    return text.trim();
  }

  /// Primary multi-pattern regex for chapter headings across Project Gutenberg classics.
  static final RegExp _primaryChapterRegex = RegExp(
    r'^[ \t]*(?:'
    r'(?:CHAPTER|Chapter|Chap\.)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:LETTER|Letter)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:BOOK|Book)\s+(?:THE\s+[A-Za-z]+|[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:PART|Part)\s+(?:THE\s+[A-Za-z]+|[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:STAVE|Stave)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:ACT|Act)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:SCENE|Scene)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:ADVENTURE|Adventure)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|(?:CANTO|Canto)\s+(?:[IVXLCDM\d]+|[A-Za-z]+)(?:[:.\s-].*)?'
    r'|PREFACE|INTRODUCTION|PROLOGUE|EPILOGUE|CONCLUSION'
    r')[ \t]*$',
    multiLine: true,
  );

  /// Secondary regex for isolated Roman numeral headers (e.g. "I.", "II", "III.")
  static final RegExp _romanNumeralRegex = RegExp(
    r'^[ \t]*(?:[IVXLCDM]{1,8}|[\d]{1,3})\.?[ \t]*$',
    multiLine: true,
  );

  /// Minimum character distance between chapter headings to reject TOC entries.
  static const int minChapterDistanceChars = 200;

  /// Fallback word threshold per section when no chapters are detected.
  static const int fallbackWordsPerSection = 2000;

  /// Target pagination words per page.
  static const int defaultTargetWordsPerPage = 280;
  static const int minWordsPerPage = 200;
  static const int maxWordsPerPage = 360;

  /// Main parsing entry point: converts raw Gutenberg text into a structured [BookContent].
  static BookContent parse({
    required String rawText,
    required String bookId,
    required String title,
    required String author,
    String? coverUrl,
  }) {
    final cleanText = stripBoilerplate(rawText);
    if (cleanText.isEmpty) {
      return BookContent(
        bookId: bookId,
        title: title,
        author: author,
        coverUrl: coverUrl,
        chapters: [
          BookChapter(
            chapterIndex: 0,
            title: 'Full Story',
            content: 'No readable content available.',
            pages: ['No readable content available.'],
          ),
        ],
      );
    }

    // Step 1: Detect chapters using primary regex
    List<_ChapterMatch> matches = _findValidMatches(cleanText, _primaryChapterRegex);

    // Step 2: If primary regex detected fewer than 2 chapters, try secondary Roman numerals
    if (matches.length < 2) {
      final romanMatches = _findValidMatches(cleanText, _romanNumeralRegex);
      if (romanMatches.length >= 2) {
        matches = romanMatches;
      }
    }

    // Step 3: If still fewer than 2 chapters, use paragraph chunker fallback
    List<BookChapter> chapters;
    if (matches.length < 2) {
      chapters = _fallbackParagraphChunker(cleanText);
    } else {
      chapters = _buildChaptersFromMatches(cleanText, matches);
    }

    // Step 4: Ensure at least one chapter exists
    if (chapters.isEmpty) {
      chapters = _fallbackParagraphChunker(cleanText);
    }

    return BookContent(
      bookId: bookId,
      title: title,
      author: author,
      coverUrl: coverUrl,
      chapters: chapters,
    );
  }

  /// Alias for [parse] to support alternative invocation styles.
  static BookContent parseBook({
    required String rawText,
    required String bookId,
    required String title,
    required String author,
    String? coverUrl,
  }) =>
      parse(
        rawText: rawText,
        bookId: bookId,
        title: title,
        author: author,
        coverUrl: coverUrl,
      );

  /// Locates matches of [regex] in [text] and rejects Table of Contents (TOC) entries.
  static List<_ChapterMatch> _findValidMatches(String text, RegExp regex) {
    final allMatches = regex.allMatches(text).toList();
    if (allMatches.isEmpty) return [];

    List<_ChapterMatch> valid = [];
    for (int i = 0; i < allMatches.length; i++) {
      final current = allMatches[i];
      final nextStart = (i + 1 < allMatches.length)
          ? allMatches[i + 1].start
          : text.length;

      // Distance between consecutive chapter headings
      final distance = nextStart - current.end;

      // If distance between headings is too small, this is a TOC entry or listing, NOT a chapter
      if (distance >= minChapterDistanceChars) {
        // Also verify content has at least 25 words
        final preview = text.substring(current.end, min(nextStart, current.end + 500));
        final wordCount = preview.trim().split(RegExp(r'\s+')).length;
        if (wordCount >= 25 || (i == allMatches.length - 1 && distance >= 100)) {
          valid.add(_ChapterMatch(
            start: current.start,
            end: current.end,
            headerText: current.group(0)!.trim(),
          ));
        }
      }
    }

    return valid;
  }

  /// Builds chapters from verified matches, extracting subtitles and paginating.
  static List<BookChapter> _buildChaptersFromMatches(
    String text,
    List<_ChapterMatch> matches,
  ) {
    List<BookChapter> chapters = [];

    for (int i = 0; i < matches.length; i++) {
      final current = matches[i];
      final chapterContentEnd = (i + 1 < matches.length)
          ? matches[i + 1].start
          : text.length;

      String header = current.headerText;
      int contentStart = current.end;

      // Check if the next line is a short chapter subtitle (e.g., "Down the Rabbit-Hole")
      final remaining = text.substring(contentStart, chapterContentEnd);
      final lines = remaining.split('\n');
      if (lines.length > 1) {
        final firstNonEmpty = lines.indexWhere((l) => l.trim().isNotEmpty);
        if (firstNonEmpty != -1 && firstNonEmpty <= 2) {
          final subtitleLine = lines[firstNonEmpty].trim();
          // Subtitles are short (< 60 chars), don't end with a period, and aren't sentences
          if (subtitleLine.isNotEmpty &&
              subtitleLine.length <= 60 &&
              !subtitleLine.endsWith('.') &&
              !subtitleLine.contains('. ') &&
              !header.contains(':') &&
              !header.contains(' - ')) {
            header = '$header: $subtitleLine';
            // Advance contentStart past this subtitle line
            final subtitleOffset = remaining.indexOf(lines[firstNonEmpty]) + lines[firstNonEmpty].length;
            contentStart += subtitleOffset;
          }
        }
      }

      final chapterBody = text.substring(contentStart, chapterContentEnd).trim();
      final pages = paginate(chapterBody);

      chapters.add(BookChapter(
        chapterIndex: i,
        title: _cleanChapterTitle(header, i),
        content: chapterBody,
        pages: pages,
      ));
    }

    return chapters;
  }

  /// Cleans up raw chapter title strings.
  static String _cleanChapterTitle(String raw, int index) {
    var title = raw.trim();
    // Normalize excessive spaces
    title = title.replaceAll(RegExp(r'[ \t]+'), ' ');
    // Remove trailing colons, dashes, or punctuation
    title = title.replaceAll(RegExp(r'[:\-–—\s]+$'), '').trim();
    if (title.isEmpty) {
      return 'Chapter ${index + 1}';
    }
    return title;
  }

  /// Fallback chunker when no chapter headers exist.
  /// Divides text along paragraph boundaries into ~2,000 word sections.
  static List<BookChapter> _fallbackParagraphChunker(String text) {
    final paragraphs = text
        .split(RegExp(r'\n\s*\n+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      return [
        BookChapter(
          chapterIndex: 0,
          title: 'Section 1',
          content: text.trim(),
          pages: paginate(text.trim()),
        ),
      ];
    }

    List<BookChapter> sections = [];
    StringBuffer currentSection = StringBuffer();
    int currentWords = 0;
    int sectionIndex = 0;

    for (final para in paragraphs) {
      final paraWords = _countWords(para);

      if (currentWords + paraWords > fallbackWordsPerSection && currentWords >= 1500) {
        final content = currentSection.toString().trim();
        sections.add(BookChapter(
          chapterIndex: sectionIndex,
          title: 'Section ${sectionIndex + 1}',
          content: content,
          pages: paginate(content),
        ));
        sectionIndex++;
        currentSection.clear();
        currentWords = 0;
      }

      if (currentSection.isNotEmpty) {
        currentSection.write('\n\n');
      }
      currentSection.write(para);
      currentWords += paraWords;
    }

    if (currentSection.isNotEmpty) {
      final content = currentSection.toString().trim();
      // If there's only 1 section total, label it "Full Story"
      final title = sectionIndex == 0 ? 'Full Story' : 'Section ${sectionIndex + 1}';
      sections.add(BookChapter(
        chapterIndex: sectionIndex,
        title: title,
        content: content,
        pages: paginate(content),
      ));
    }

    return sections;
  }

  /// Paragraph-preserving paginator (~250-350 words or ~1,400 chars per page).
  /// Guarantees zero sentence cuts.
  static List<String> paginate(String chapterText) {
    final text = chapterText.trim();
    if (text.isEmpty) return [''];

    final totalWords = _countWords(text);
    if (totalWords <= maxWordsPerPage && text.length <= 1600) {
      return [text];
    }

    // Split into paragraphs
    final rawParagraphs = text.split(RegExp(r'\n\s*\n+'));
    List<String> blocks = [];

    // Process paragraphs: if an individual paragraph exceeds maxWordsPerPage,
    // break it down by sentence boundaries so sentences are never cut!
    for (final rawPara in rawParagraphs) {
      final para = rawPara.trim();
      if (para.isEmpty) continue;

      if (_countWords(para) > maxWordsPerPage) {
        // Split long paragraph into sentence chunks
        blocks.addAll(_splitParagraphBySentences(para, maxWordsPerPage));
      } else {
        blocks.add(para);
      }
    }

    if (blocks.isEmpty) return [text];

    // Assemble blocks into pages
    List<String> pages = [];
    StringBuffer currentPage = StringBuffer();
    int currentWordCount = 0;

    for (final block in blocks) {
      final blockWords = _countWords(block);

      if (currentPage.isNotEmpty) {
        // Check if adding this block exceeds target limits
        final wouldExceed = currentWordCount + blockWords > maxWordsPerPage;
        final hasSufficientWords = currentWordCount >= minWordsPerPage;

        if (wouldExceed && hasSufficientWords) {
          pages.add(currentPage.toString().trim());
          currentPage.clear();
          currentWordCount = 0;
        } else if (currentWordCount + blockWords > (maxWordsPerPage * 1.35).round()) {
          // Hard cap overflow protection
          pages.add(currentPage.toString().trim());
          currentPage.clear();
          currentWordCount = 0;
        }
      }

      if (currentPage.isNotEmpty) {
        currentPage.write('\n\n');
      }
      currentPage.write(block);
      currentWordCount += blockWords;
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage.toString().trim());
    }

    return pages.isEmpty ? [text] : pages;
  }

  /// Splits a massive paragraph into sentence chunks of ~200-300 words without cutting sentences.
  static List<String> _splitParagraphBySentences(String paragraph, int maxWords) {
    // Regex matching sentence endings: . ! ? followed by quote/closing char and space
    final sentenceEndings = RegExp(r'''(?<=[.!?]["”']?)\s+''');
    final sentences = paragraph.split(sentenceEndings);

    if (sentences.length <= 1) {
      // Unsplittable sentence (very rare)
      return [paragraph];
    }

    List<String> chunks = [];
    StringBuffer currentChunk = StringBuffer();
    int currentWords = 0;

    for (final sentence in sentences) {
      final s = sentence.trim();
      if (s.isEmpty) continue;
      final sWords = _countWords(s);

      if (currentWords + sWords > maxWords && currentWords >= minWordsPerPage) {
        chunks.add(currentChunk.toString().trim());
        currentChunk.clear();
        currentWords = 0;
      }

      if (currentChunk.isNotEmpty) {
        currentChunk.write(' ');
      }
      currentChunk.write(s);
      currentWords += sWords;
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.toString().trim());
    }

    return chunks;
  }

  /// Helper to count words in a string.
  static int _countWords(String str) {
    final trimmed = str.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}

class _ChapterMatch {
  final int start;
  final int end;
  final String headerText;

  _ChapterMatch({
    required this.start,
    required this.end,
    required this.headerText,
  });
}
