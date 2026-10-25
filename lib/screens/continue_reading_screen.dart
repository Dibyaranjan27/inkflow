import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';
import 'package:inkflow/screens/reading_screen.dart';
import 'package:inkflow/services/reading_progress_service.dart';
import 'package:inkflow/widgets/continue_reading_widget.dart';

class ContinueReadingScreen extends StatefulWidget {
  const ContinueReadingScreen({Key? key}) : super(key: key);

  @override
  State<ContinueReadingScreen> createState() => _ContinueReadingScreenState();
}

class _ContinueReadingScreenState extends State<ContinueReadingScreen> {
  List<Map<String, dynamic>> _readingList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadingHistory();
  }

  Future<void> _loadReadingHistory() async {
    setState(() => _isLoading = true);
    final list = await ReadingProgressService.getContinueReadingList();
    if (!mounted) return;
    setState(() {
      _readingList = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _loadReadingHistory,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Title and Descriptive Text Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Continue Reading',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Dive back into your stories and pick up where you left off! Here’s what you’ve been reading:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/girl-book-reading.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Divider with icon
                Row(
                  children: const [
                    Expanded(
                      child: Divider(
                        color: AppColors.divider,
                        thickness: 1.5,
                        endIndent: 10,
                      ),
                    ),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.divider,
                      child: Icon(
                        Icons.bookmark,
                        size: 16,
                        color: AppColors.surface,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.divider,
                        thickness: 1.5,
                        indent: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Dynamic Reading List or Empty State
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (_readingList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 36,
                      horizontal: 20,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'No books in progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pick any classic or catalog title from the Home tab to begin reading. Your reading position and progress will be tracked here!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _readingList.length,
                    itemBuilder: (context, index) {
                      final item = _readingList[index];
                      final bookData = item['bookData'] as Map<String, dynamic>? ?? {};

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ContinueReadingWidget(
                          bookCover: (item['bookCover'] as String?)?.isNotEmpty == true
                              ? item['bookCover'] as String
                              : 'assets/images/placeholder.png',
                          bookTitle: item['bookTitle'] as String? ?? 'Untitled Book',
                          currentPage: (item['currentPage'] as int?) ?? 1,
                          totalPages: (item['totalPages'] as int?) ?? 100,
                          press: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadingScreen(
                                  bookData: bookData,
                                ),
                              ),
                            ).then((_) => _loadReadingHistory());
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
