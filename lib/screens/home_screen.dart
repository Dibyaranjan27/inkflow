import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart'; // Assuming you have constants defined here
import 'package:inkflow/screens/book_listing_page.dart';
import 'package:inkflow/screens/bookmark_screen.dart';
import 'package:inkflow/screens/continue_reading_screen.dart';
import 'package:inkflow/screens/details_screen.dart';
import 'package:inkflow/screens/profile_screen.dart';
import 'package:inkflow/screens/reading_screen.dart';
import 'package:inkflow/services/book_service.dart';
import 'package:inkflow/services/gutendex_service.dart';
import 'package:inkflow/services/reading_progress_service.dart';
import 'package:inkflow/widgets/category_card_widget.dart';
import 'package:inkflow/widgets/continue_reading_widget.dart';
import 'package:inkflow/widgets/view_more_card.dart';
import 'package:inkflow/widgets/book_card_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected bottom navigation item
  bool _isNotificationsEnabled = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _requestNotificationPermission();
    _checkExactAlarmPermission();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create a notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // ID must match the channel ID in _showNotification method
      'Important Notifications',
      description: 'This channel is for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      bool? granted =
          await androidImplementation.requestNotificationsPermission();
      if (granted == null || !granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permissions not granted'),
          ),
        );
      }
    }
  }

  Future<void> _checkExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      print('Android version: ${androidInfo.version.sdkInt}');

      if (androidInfo.version.sdkInt >= 31) {
        final status = await Permission.ignoreBatteryOptimizations.request();
        print('Permission status: ${status}');

        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('You need to enable USE_EXACT_ALARM permission.')),
          );
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      }
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _showNotification(); // Show the notification after picking a time
    }
  }

  Future<void> _showNotification() async {
    if (_isNotificationsEnabled) {
      final selected = _selectedTime;

      // Calculate delay based on the difference between the selected time and now
      DateTime selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        selected.hour,
        selected.minute,
      );

      if (selectedDateTime.isBefore(DateTime.now())) {
        // If selected time is earlier than now, schedule for the next day
        selectedDateTime = selectedDateTime.add(Duration(days: 1));
      }

      final delay = selectedDateTime.difference(DateTime.now());

      // Wait for the calculated delay before showing the notification
      await Future.delayed(delay);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id', // Channel ID must match the one in main.dart
        'Important Notifications',
        channelDescription: 'This channel is for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Daily Remainder',
        "Your daily reading time is here! Let's explore new worlds together! 🌍",
        platformChannelSpecifics,
      );
    }
  }

  void _toggleNotifications() {
    setState(() {
      _isNotificationsEnabled = !_isNotificationsEnabled;
    });

    if (_isNotificationsEnabled) {
      _pickTime(
          context); // Let the user pick the time when enabling notifications
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Notifications enabled! Pick a time for reminders.')),
      );
    } else {
      flutterLocalNotificationsPlugin.cancel(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications disabled!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: kScaffoldBackgroundColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Image.asset('assets/images/logo.png'), // App logo
          ),
          title: Text(
            'InkFlow',
            style: TextStyle(
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isNotificationsEnabled
                    ? FontAwesomeIcons.bell // Filled bell icon
                    : FontAwesomeIcons.bellSlash, // Empty bell icon
                color: Colors.black,
              ),
              onPressed: _toggleNotifications,
            ),
            SizedBox(
              width: 10.0,
            )
          ],
        ),

        // Conditionally rendering pages based on selected index
        body: _buildPageContent(_selectedIndex),

        bottomNavigationBar: BottomAppBar(
          height: 100,
          color: kScaffoldBackgroundColor, // Background color
          child: SizedBox(
              height: 100, // Set the height for the BottomAppBar
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal:
                          5.0), // Adds padding around the bottom navigation bar
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20.0), // Adds rounded corners
                    child: BottomNavigationBar(
                      backgroundColor:
                          AppColors.surface, // Standardized surface background
                      currentIndex: _selectedIndex,
                      onTap: _onItemTapped,
                      selectedItemColor:
                          AppColors.primary, // Brand primary color
                      unselectedItemColor:
                          AppColors.textSecondary, // Standardized secondary text color
                      type: BottomNavigationBarType
                          .fixed, // Fixed type for smooth transitions
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.house,
                            size: 24, // Increased icon size
                          ),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.solidBookmark,
                            size: 24, // Increased icon size
                          ),
                          label: 'Bookmark',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.bookJournalWhills,
                            size: 24, // Increased icon size
                          ),
                          label: 'Continue',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.solidUser,
                            size: 24, // Increased icon size
                          ),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ))),
        ),
      ),
    );
  }

  // Method to build the content based on the selected index
  Widget _buildPageContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return HomeContent(); // Main Home content
      case 1:
        return BookmarkScreen(); // Bookmark screen placeholder
      case 2:
        return ContinueReadingScreen(); // Continue Reading screen placeholder
      case 3:
        return ProfileScreen(); // Profile screen placeholder
      default:
        return HomeContent(); // Fallback to Home content if index is invalid
    }
  }
}

class HomeContent extends StatefulWidget {
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final BookService _bookService = BookService();
  String searchQuery = '';
  void _navigateToSearchResults(BuildContext context) {
    if (searchQuery.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookListingPage(query: searchQuery),
        ),
      );
    }
  }

  final GutendexService _gutendexService = GutendexService();
  Map<String, dynamic>? _activeReadingBook;
  List<Map<String, dynamic>> _featuredClassics = [];
  List<Map<String, dynamic>> _myBooks = [];
  List<Map<String, dynamic>> _trendingBooks = [];
  List<Map<String, dynamic>> _newArrivals = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final myBooks = await _bookService.fetchBooks(
          "New York Times bestseller&orderBy=relevance"); // Adjust query for "My Books"
      final trendingBooks = await _bookService
          .fetchBooks("trending"); // Adjust query for "Trending"
      final newArrivalsData =
          await _bookService.fetchBooks('subject:general&orderBy=newest');

      final activeBook = await ReadingProgressService.getMostRecentBook();
      final classics = await _gutendexService.getFeaturedClassics();

      if (mounted) {
        setState(() {
          _myBooks = myBooks;
          _trendingBooks = trendingBooks;
          _newArrivals = newArrivalsData;
          _activeReadingBook = activeBook;
          _featuredClassics = classics;
        });
      }
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Search bar
          Material(
            elevation: 5, // Adjust the elevation value as needed
            shadowColor:
                AppColors.shadowMedium, // Standardized shadow elevation
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
              },
              onSubmitted: (value) => _navigateToSearchResults(context),
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 30),

          // My Books Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Books',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BookListingPage(
                        query: 'New York Times bestseller&orderBy=relevance');
                  }));
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Scrollable My Books Section
          SizedBox(
            height: 260,
            child: _myBooks.isEmpty
                ? Center(
                    child: SpinKitWaveSpinner(
                        color: kLogoColor,
                        waveColor: kWaveColor,
                        trackColor: kTrackColor,
                        size: 50.0))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _myBooks.length < 8 ? _myBooks.length : 8,
                    itemBuilder: (context, index) {
                      if (index == 7 || index == _myBooks.length) {
                        return ViewMoreCard(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BookListingPage();
                            }));
                          },
                        );
                      }
                      final book = _myBooks[index];
                      return BookCard(
                        bookCover: book['thumbnail'] ??
                            'assets/images/placeholder.png',
                        rating: book['averageRating'] ?? 4.0,
                        bookTitle: book['title'],
                        author: book['authors'],
                        press: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetailsScreen(_myBooks[index]);
                          }));
                        },
                      );
                    },
                  ),
          ),

          SizedBox(height: 30),

          // My Books Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BookListingPage(query: 'trending');
                  }));
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: _trendingBooks.isEmpty
                ? Center(
                    child: SpinKitWaveSpinner(
                        color: kLogoColor,
                        waveColor: kWaveColor,
                        trackColor: kTrackColor,
                        size: 50.0))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        _trendingBooks.length < 8 ? _trendingBooks.length : 8,
                    itemBuilder: (context, index) {
                      if (index == 7 || index == _trendingBooks.length) {
                        return ViewMoreCard(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BookListingPage();
                            }));
                          },
                        );
                      }
                      final book = _trendingBooks[index];
                      return BookCard(
                        bookCover: book['thumbnail'] ??
                            'assets/images/placeholder.png',
                        rating: book['rating'] ?? 4.0,
                        bookTitle: book['title'],
                        author: book['authors'],
                        press: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetailsScreen(_trendingBooks[index]);
                          }));
                        },
                      );
                    },
                  ),
          ),
          SizedBox(height: 30),

          // Continue Reading Section (Scrollable)
          Text(
            'Continue Reading',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _activeReadingBook != null
              ? ContinueReadingWidget(
                  bookCover: (_activeReadingBook!['bookCover'] as String?)?.isNotEmpty == true
                      ? _activeReadingBook!['bookCover'] as String
                      : 'assets/images/girl-book-reading.png',
                  bookTitle: _activeReadingBook!['bookTitle'] as String? ?? 'Untitled Book',
                  currentPage: (_activeReadingBook!['currentPage'] as int?) ?? 1,
                  totalPages: (_activeReadingBook!['totalPages'] as int?) ?? 100,
                  press: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ReadingScreen(
                        bookData: _activeReadingBook!['bookData'] as Map<String, dynamic>? ?? {},
                      );
                    })).then((_) => _fetchBooks());
                  },
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.primary, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Start Your Reading Journey',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pick any classic or catalog title to track your reading progress here.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 30),

          // New Arrival Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Arrivals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BookListingPage(
                        query: 'subject:general&orderBy=newest');
                  }));
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: _newArrivals.isEmpty
                ? Center(
                    child: SpinKitWaveSpinner(
                        color: kLogoColor,
                        waveColor: kWaveColor,
                        trackColor: kTrackColor,
                        size: 50.0))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        _newArrivals.length < 8 ? _newArrivals.length : 8,
                    itemBuilder: (context, index) {
                      if (index == 7 || index == _newArrivals.length) {
                        return ViewMoreCard(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BookListingPage();
                            }));
                          },
                        );
                      }
                      final book = _newArrivals[index];
                      return BookCard(
                        bookCover: book['thumbnail'] ??
                            'assets/images/placeholder.png',
                        rating: book['rating'] ?? 4.0,
                        bookTitle: book['title'],
                        author: book['authors'],
                        press: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetailsScreen(_newArrivals[index]);
                          }));
                        },
                      );
                    },
                  ),
          ),
          SizedBox(height: 30),

          // Free Classics Section (Full-Text Gutendex Books)
          if (_featuredClassics.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Free Classics (Full Text)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return BookListingPage(query: 'classic literature');
                    }));
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredClassics.length,
                itemBuilder: (context, index) {
                  final classic = _featuredClassics[index];
                  return BookCard(
                    bookCover: classic['thumbnail'] ?? 'assets/images/placeholder.png',
                    rating: classic['averageRating'] ?? 4.5,
                    bookTitle: classic['title'] ?? 'Classic',
                    author: classic['authors'] ?? 'Classic Author',
                    press: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ReadingScreen(bookData: classic);
                      })).then((_) => _fetchBooks());
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],

          // Categories Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BookListingPage();
                  }));
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CategoryCard(
                  categoryName: 'Fiction',
                  backgroundColor: AppColors.categoryFiction,
                  press: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BookListingPage(query: 'fiction');
                    }));
                  },
                ),
                CategoryCard(
                  categoryName: 'Science',
                  backgroundColor: AppColors.categoryScience,
                  press: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BookListingPage(query: 'science');
                    }));
                  },
                ),
                CategoryCard(
                  categoryName: 'History',
                  backgroundColor: AppColors.categoryHistory,
                  press: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BookListingPage(query: 'history');
                    }));
                  },
                ),
                CategoryCard(
                  categoryName: 'Technology',
                  backgroundColor: AppColors.categoryTechnology,
                  press: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BookListingPage(query: 'technology');
                    }));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
