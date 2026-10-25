import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:inkflow/models/book_content.dart';
import 'package:inkflow/screens/bookmark_screen.dart';
import 'package:inkflow/screens/home_screen.dart';
import 'package:inkflow/services/gutendex_service.dart';
import 'package:inkflow/services/reading_progress_service.dart';
import 'package:inkflow/theme/app_theme.dart';

/// Available visual reading themes
enum ReaderThemeMode { light, sepia, dark }

/// Palette specifications for each reader theme
class ReaderThemeData {
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color appBarColor;
  final Color bottomBarColor;
  final Color cardColor;
  final Color accentColor;
  final Color dividerColor;

  const ReaderThemeData({
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.appBarColor,
    required this.bottomBarColor,
    required this.cardColor,
    required this.accentColor,
    required this.dividerColor,
  });

  static const light = ReaderThemeData(
    backgroundColor: Color(0xFFFBF9F5), // Warm parchment white
    textColor: Color(0xFF2C2C2C),
    secondaryTextColor: Color(0xFF757575),
    appBarColor: Colors.white,
    bottomBarColor: Colors.white,
    cardColor: Color(0xFFF1F4ED),
    accentColor: AppColors.primary,
    dividerColor: Color(0xFFE0DCD3),
  );

  static const sepia = ReaderThemeData(
    backgroundColor: Color(0xFFF4ECD8), // Classic book paper
    textColor: Color(0xFF5B4636),
    secondaryTextColor: Color(0xFF8D7B68),
    appBarColor: Color(0xFFEFE5CD),
    bottomBarColor: Color(0xFFEFE5CD),
    cardColor: Color(0xFFFAF3E3),
    accentColor: Color(0xFF8B5E3C),
    dividerColor: Color(0xFFDCCFBA),
  );

  static const dark = ReaderThemeData(
    backgroundColor: Color(0xFF141414), // Dark canvas
    textColor: Color(0xFFE8E8E8),
    secondaryTextColor: Color(0xFF9E9E9E),
    appBarColor: Color(0xFF1E1E1E),
    bottomBarColor: Color(0xFF1E1E1E),
    cardColor: Color(0xFF242424),
    accentColor: Color(0xFFFFD5CA),
    dividerColor: Color(0xFF333333),
  );
}

class ReadingScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const ReadingScreen({super.key, required this.bookData});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  // Service instance
  final GutendexService _gutendexService = GutendexService();

  // Book & Content State
  BookContent? _bookContent;
  int _currentChapterIndex = 0;
  int _currentPageInChapter = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Metadata extracted from bookData
  String _bookTitle = '';
  String _bookAuthors = '';
  String _bookCover = '';
  String _bookDescription = '';
  String _webReaderLink = '';

  // E-Reader Preferences
  ReaderThemeMode _themeMode = ReaderThemeMode.light;
  double _fontSize = 17.0;
  bool _isBookmarked = false;

  ReaderThemeData get _currentThemeData {
    switch (_themeMode) {
      case ReaderThemeMode.sepia:
        return ReaderThemeData.sepia;
      case ReaderThemeMode.dark:
        return ReaderThemeData.dark;
      case ReaderThemeMode.light:
        return ReaderThemeData.light;
    }
  }

  @override
  void initState() {
    super.initState();
    _extractInitialMetadata();
    _loadPreferences();
    _loadBook();
    _checkBookmarkStatus();
  }

  void _extractInitialMetadata() {
    _bookTitle = (widget.bookData['title'] ?? 'Untitled Book').toString().trim();
    _bookAuthors = (widget.bookData['authors'] ??
            widget.bookData['author'] ??
            'Unknown Author')
        .toString()
        .trim();
    _bookCover = (widget.bookData['thumbnail'] ??
            widget.bookData['coverUrl'] ??
            widget.bookData['imageLinks']?['thumbnail'] ??
            '')
        .toString()
        .trim();
    _bookDescription =
        (widget.bookData['description'] ?? 'No description available')
            .toString()
            .trim();
    _webReaderLink = (widget.bookData['webReaderLink'] ??
            widget.bookData['previewLink'] ??
            '')
        .toString()
        .trim();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('reader_theme') ?? 'light';
    final savedSize = prefs.getDouble('reader_font_size') ?? 17.0;

    if (!mounted) return;
    setState(() {
      if (savedTheme == 'sepia') {
        _themeMode = ReaderThemeMode.sepia;
      } else if (savedTheme == 'dark') {
        _themeMode = ReaderThemeMode.dark;
      } else {
        _themeMode = ReaderThemeMode.light;
      }
      _fontSize = savedSize.clamp(14.0, 26.0);
    });
  }

  Future<void> _saveThemePreference(ReaderThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reader_theme', mode.name);
  }

  Future<void> _saveFontSizePreference(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('reader_font_size', size);
  }

  Future<void> _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('email') ?? 'guest';
    final key = '${username}_bookmarkedBooks';
    final bookmarkedList = prefs.getStringList(key) ?? [];

    final bookId = _getBookIdentifier();
    final isMarked = bookmarkedList.any((item) {
      try {
        final decoded = json.decode(item) as Map<String, dynamic>;
        final id = (decoded['id'] ?? decoded['bookId'] ?? decoded['title'])?.toString();
        return id == bookId;
      } catch (_) {
        return false;
      }
    });

    if (mounted) {
      setState(() => _isBookmarked = isMarked);
    }
  }

  String _getBookIdentifier() {
    return (widget.bookData['id'] ??
            widget.bookData['gutenbergId'] ??
            widget.bookData['bookId'] ??
            _bookTitle)
        .toString();
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('email') ?? 'guest';
    final key = '${username}_bookmarkedBooks';
    final bookmarkedList = prefs.getStringList(key) ?? [];

    final bookId = _getBookIdentifier();
    final cleanBookMap = {
      'id': bookId,
      'title': _bookTitle,
      'authors': _bookAuthors,
      'thumbnail': _bookCover,
      'webReaderLink': _webReaderLink,
      'description': _bookDescription,
    };

    final encoded = json.encode(cleanBookMap);

    if (_isBookmarked) {
      bookmarkedList.removeWhere((item) {
        try {
          final decoded = json.decode(item) as Map<String, dynamic>;
          final id = (decoded['id'] ?? decoded['bookId'] ?? decoded['title'])?.toString();
          return id == bookId;
        } catch (_) {
          return false;
        }
      });
      await prefs.setStringList(key, bookmarkedList);
      if (!mounted) return;
      setState(() => _isBookmarked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from bookmarks')),
      );
    } else {
      bookmarkedList.add(encoded);
      await prefs.setStringList(key, bookmarkedList);
      if (!mounted) return;
      setState(() => _isBookmarked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to bookmarks')),
      );
    }
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dynamic rawGutenbergId =
          widget.bookData['gutenbergId'] ?? widget.bookData['id'];
      final textUrl = widget.bookData['textUrl']?.toString();

      int? gutenbergId;
      if (rawGutenbergId is int) {
        gutenbergId = rawGutenbergId;
      } else if (rawGutenbergId is String) {
        gutenbergId = int.tryParse(rawGutenbergId);
      }

      BookContent? content;

      // Strategy 1: Explicit Gutenberg ID or text URL
      if (gutenbergId != null && gutenbergId > 0) {
        content = await _gutendexService.fetchBookContent(
          gutenbergId: gutenbergId,
          textUrl: textUrl,
          title: _bookTitle,
          author: _bookAuthors,
          coverUrl: _bookCover.isNotEmpty ? _bookCover : null,
        );
      }
      // Strategy 2: If title is present without Gutenberg ID, query Gutendex search
      else if (_bookTitle.isNotEmpty) {
        content = await _gutendexService.findAndFetchByTitle(
          _bookTitle,
          author: _bookAuthors,
        );
      }

      if (!mounted) return;

      if (content != null && content.chapters.isNotEmpty) {
        int restoredChapter = 0;
        int restoredPage = 0;

        if (widget.bookData['chapterIndex'] is int) {
          restoredChapter = (widget.bookData['chapterIndex'] as int)
              .clamp(0, content.chapters.length - 1);
        }
        if (widget.bookData['currentPageInChapter'] is int) {
          restoredPage = (widget.bookData['currentPageInChapter'] as int)
              .clamp(0, content.chapters[restoredChapter].pageCount - 1);
        }

        setState(() {
          _bookContent = content;
          _currentChapterIndex = restoredChapter;
          _currentPageInChapter = restoredPage;
          _isLoading = false;
        });
        _saveProgress();
      } else if (_webReaderLink.isNotEmpty) {
        // Strategy 3: Modern in-copyright volume with Google Books Web Reader
        setState(() {
          _bookContent = null;
          _isLoading = false;
        });
      } else {
        // Strategy 4: Neither Gutenberg classic nor WebReader
        setState(() {
          _bookContent = null;
          _isLoading = false;
          _errorMessage = _bookTitle.isEmpty
              ? 'No book selected'
              : 'Full text is not available in the public domain for "$_bookTitle".';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load reading content: $e';
      });
    }
  }

  void _saveProgress() {
    if (_bookContent == null || _bookContent!.chapters.isEmpty) return;

    final overallPage = _bookContent!.calculateOverallPage(
      _currentChapterIndex,
      _currentPageInChapter,
    );
    final totalPages = _bookContent!.totalPages;
    final currentChapter = _bookContent!.chapters[_currentChapterIndex];

    ReadingProgressService.saveProgress(
      bookId: _getBookIdentifier(),
      bookTitle: _bookTitle,
      bookCover: _bookCover,
      authors: _bookAuthors,
      currentPage: overallPage,
      totalPages: totalPages,
      bookData: widget.bookData,
    );

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_read_book_id', _getBookIdentifier());
      prefs.setString('last_read_book_title', _bookTitle);
      prefs.setString('last_read_book_authors', _bookAuthors);
      prefs.setString('last_read_book_cover', _bookCover);
      prefs.setInt('last_read_current_page', overallPage);
      prefs.setInt('last_read_total_pages', totalPages);
      prefs.setInt('last_read_chapter_index', _currentChapterIndex);
      prefs.setString('last_read_chapter_title', currentChapter.title);
      prefs.setInt('last_read_page_in_chapter', _currentPageInChapter);
      prefs.setString('last_read_timestamp', DateTime.now().toIso8601String());
    });
  }

  void _goToNextPage() {
    if (_bookContent == null) return;
    final chapter = _bookContent!.chapters[_currentChapterIndex];

    if (_currentPageInChapter < chapter.pageCount - 1) {
      setState(() => _currentPageInChapter++);
      _saveProgress();
    } else if (_currentChapterIndex < _bookContent!.chapters.length - 1) {
      setState(() {
        _currentChapterIndex++;
        _currentPageInChapter = 0;
      });
      _saveProgress();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You've reached the end of the book!")),
      );
    }
  }

  void _goToPreviousPage() {
    if (_bookContent == null) return;

    if (_currentPageInChapter > 0) {
      setState(() => _currentPageInChapter--);
      _saveProgress();
    } else if (_currentChapterIndex > 0) {
      setState(() {
        _currentChapterIndex--;
        _currentPageInChapter =
            _bookContent!.chapters[_currentChapterIndex].pageCount - 1;
      });
      _saveProgress();
    }
  }

  void _navigateToChapter(int index) {
    if (_bookContent == null || index < 0 || index >= _bookContent!.chapters.length) {
      return;
    }
    setState(() {
      _currentChapterIndex = index;
      _currentPageInChapter = 0;
    });
    _saveProgress();
  }

  Future<void> _openWebReader() async {
    if (_webReaderLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Web Reader link is unavailable')),
      );
      return;
    }

    final uri = Uri.tryParse(_webReaderLink);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView, // In-App Custom Tabs
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open Google Books Web Reader')),
      );
    }
  }

  void _showTableOfContents() {
    if (_bookContent == null || _bookContent!.chapters.isEmpty) return;
    final themeData = _currentThemeData;

    showModalBottomSheet(
      context: context,
      backgroundColor: themeData.appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table of Contents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeData.textColor,
                          ),
                        ),
                        Text(
                          '${_bookContent!.chapters.length} Chapters',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeData.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: themeData.textColor),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: themeData.dividerColor),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _bookContent!.chapters.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: themeData.dividerColor,
                    indent: 20,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) {
                    final chapter = _bookContent!.chapters[index];
                    final isCurrent = index == _currentChapterIndex;
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isCurrent
                            ? themeData.accentColor
                            : themeData.cardColor,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : themeData.textColor,
                          ),
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? themeData.accentColor
                              : themeData.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${chapter.pageCount} ${chapter.pageCount == 1 ? "page" : "pages"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeData.secondaryTextColor,
                        ),
                      ),
                      trailing: isCurrent
                          ? Icon(Icons.check_circle,
                              color: themeData.accentColor, size: 20)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _navigateToChapter(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppearanceSettings() {
    final themeData = _currentThemeData;

    showModalBottomSheet(
      context: context,
      backgroundColor: themeData.appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reading Appearance',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: themeData.textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: themeData.textColor),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeData.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildThemePill(
                          label: 'Light',
                          bg: const Color(0xFFFBF9F5),
                          text: const Color(0xFF2C2C2C),
                          isSelected: _themeMode == ReaderThemeMode.light,
                          onSelect: () {
                            setState(() => _themeMode = ReaderThemeMode.light);
                            _saveThemePreference(ReaderThemeMode.light);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildThemePill(
                          label: 'Sepia',
                          bg: const Color(0xFFF4ECD8),
                          text: const Color(0xFF5B4636),
                          isSelected: _themeMode == ReaderThemeMode.sepia,
                          onSelect: () {
                            setState(() => _themeMode = ReaderThemeMode.sepia);
                            _saveThemePreference(ReaderThemeMode.sepia);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildThemePill(
                          label: 'Dark',
                          bg: const Color(0xFF1E1E1E),
                          text: const Color(0xFFE8E8E8),
                          isSelected: _themeMode == ReaderThemeMode.dark,
                          onSelect: () {
                            setState(() => _themeMode = ReaderThemeMode.dark);
                            _saveThemePreference(ReaderThemeMode.dark);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Text Size',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: themeData.secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${_fontSize.toInt()} sp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeData.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.text_fields, size: 18),
                          color: themeData.textColor,
                          onPressed: _fontSize > 14.0
                              ? () {
                                  final newSize = (_fontSize - 1.5).clamp(14.0, 26.0);
                                  setState(() => _fontSize = newSize);
                                  _saveFontSizePreference(newSize);
                                  setModalState(() {});
                                }
                              : null,
                        ),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 14.0,
                            max: 26.0,
                            divisions: 8,
                            activeColor: themeData.accentColor,
                            inactiveColor: themeData.dividerColor,
                            onChanged: (val) {
                              setState(() => _fontSize = val);
                              _saveFontSizePreference(val);
                              setModalState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.text_fields, size: 26),
                          color: themeData.textColor,
                          onPressed: _fontSize < 26.0
                              ? () {
                                  final newSize = (_fontSize + 1.5).clamp(14.0, 26.0);
                                  setState(() => _fontSize = newSize);
                                  _saveFontSizePreference(newSize);
                                  setModalState(() {});
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemePill({
    required String label,
    required Color bg,
    required Color text,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              width: isSelected ? 2.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: text,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _currentThemeData;

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeData.appBarColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeData.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bookTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_bookContent != null && _bookContent!.chapters.isNotEmpty)
              Text(
                _bookContent!.chapters[_currentChapterIndex].title,
                style: TextStyle(
                  fontSize: 12,
                  color: themeData.secondaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (_bookContent != null && _bookContent!.chapters.isNotEmpty)
            IconButton(
              icon: Icon(Icons.list_alt, color: themeData.textColor),
              tooltip: 'Table of Contents',
              onPressed: _showTableOfContents,
            ),
          IconButton(
            icon: Icon(Icons.tune, color: themeData.textColor),
            tooltip: 'Reading Settings',
            onPressed: _showAppearanceSettings,
          ),
        ],
      ),
      body: _buildBody(themeData),
      bottomNavigationBar: _buildBottomBar(themeData),
    );
  }

  Widget _buildBody(ReaderThemeData themeData) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: themeData.accentColor),
            const SizedBox(height: 16),
            Text(
              'Loading book content...',
              style: TextStyle(fontSize: 15, color: themeData.secondaryTextColor),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _webReaderLink.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 64, color: themeData.secondaryTextColor),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: themeData.textColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeData.accentColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Google Books Web Reader Mode
    if (_bookContent == null && _webReaderLink.isNotEmpty) {
      return _buildWebReaderPreview(themeData);
    }

    // Dynamic Gutenberg Reader Mode
    final currentChapter = _bookContent!.chapters[_currentChapterIndex];
    final currentPageText = currentChapter.pages.isNotEmpty
        ? currentChapter.pages[_currentPageInChapter]
        : currentChapter.content;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            _goToNextPage();
          } else if (details.primaryVelocity! > 200) {
            _goToPreviousPage();
          }
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                currentPageText,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.65,
                  color: themeData.textColor,
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebReaderPreview(ReaderThemeData themeData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          if (_bookCover.isNotEmpty)
            Container(
              height: 220,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _bookCover,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.cardPlaceholder,
                    child: const Icon(Icons.book, size: 40),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.cardPlaceholder,
                    child: const Icon(Icons.book, size: 40),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            _bookTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeData.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _bookAuthors,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: themeData.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openWebReader,
            icon: const FaIcon(FontAwesomeIcons.googlePlay, size: 16),
            label: const Text(
              'Read Google Books Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Opens the official Google Books preview in an in-app browser view.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: themeData.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: themeData.dividerColor),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Synopsis',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: themeData.textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _bookDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: themeData.textColor,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ReaderThemeData themeData) {
    final hasContent = _bookContent != null && _bookContent!.chapters.isNotEmpty;

    final overallPage = hasContent
        ? _bookContent!.calculateOverallPage(
            _currentChapterIndex,
            _currentPageInChapter,
          )
        : 1;
    final totalPages = hasContent ? _bookContent!.totalPages : 1;
    final currentChapter = hasContent
        ? _bookContent!.chapters[_currentChapterIndex]
        : null;

    final canGoPrev = hasContent &&
        (_currentChapterIndex > 0 || _currentPageInChapter > 0);
    final canGoNext = hasContent &&
        (_currentChapterIndex < _bookContent!.chapters.length - 1 ||
            _currentPageInChapter < (currentChapter?.pageCount ?? 1) - 1);

    return BottomAppBar(
      color: themeData.bottomBarColor,
      elevation: 4.0,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            // Left Actions: Home & Bookmark
            IconButton(
              icon: Icon(Icons.home_outlined, color: themeData.textColor),
              tooltip: 'Home',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked
                    ? themeData.accentColor
                    : themeData.textColor,
              ),
              tooltip: 'Bookmark',
              onPressed: _toggleBookmark,
            ),
            IconButton(
              icon: Icon(Icons.bookmarks_outlined, color: themeData.textColor),
              tooltip: 'View Bookmarks',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookmarkScreen(fromReadingScreen: true),
                  ),
                );
              },
            ),
            const Spacer(),
            // Center Pagination Info
            if (hasContent)
              Text(
                'Ch ${_currentChapterIndex + 1}/${_bookContent!.totalChapters} • Pg $overallPage of $totalPages',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeData.textColor,
                ),
              ),
            const Spacer(),
            // Right Actions: Previous & Next Page
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: canGoPrev
                    ? themeData.textColor
                    : themeData.dividerColor,
              ),
              tooltip: 'Previous Page',
              onPressed: canGoPrev ? _goToPreviousPage : null,
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: canGoNext
                    ? themeData.textColor
                    : themeData.dividerColor,
              ),
              tooltip: 'Next Page',
              onPressed: canGoNext ? _goToNextPage : null,
            ),
          ],
        ),
      ),
    );
  }
}
