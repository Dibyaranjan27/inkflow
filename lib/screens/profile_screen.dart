import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inkflow/constants.dart';
import 'package:inkflow/screens/change_password_screen.dart';
import 'package:inkflow/screens/completed_books_screen.dart';
import 'package:inkflow/screens/edit_profile_screen.dart';
import 'package:inkflow/screens/login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  File? _imageFile; // To store the profile image URL
  bool _isDarkMode = false; // Toggle for dark mode

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen is initialized
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username') ?? 'Guest';
      email = FirebaseAuth.instance.currentUser?.email ?? 'No Email';
      String? user = prefs.getString('email');
      String key = '${user}_profileImagePath';
      String? imagePath = prefs.getString(key) ?? '';
      if (imagePath.isNotEmpty) {
        setState(() {
          _imageFile = File(imagePath); // Load the profile image from file path
        });
      }
      _isDarkMode =
          prefs.getBool('isDarkMode') ?? false; // Load dark mode preference
    });
  }

  Future<void> _toggleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode; // Toggle dark mode
      prefs.setBool('isDarkMode', _isDarkMode); // Save the preference
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),

                // Profile Picture Section
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 3),
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 2),
                        ),
                        child: ClipOval(
                          child: _imageFile != null
                              ? Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  )
                              : Icon(Icons.person, size: 70),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // User Name and Email
                Center(
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Options Card
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    children: [
                      _buildOptionCard(
                          FontAwesomeIcons.penToSquare, 'Edit Profile', () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EditProfileScreen();
                        })).then((_) {
                          // Reload user data when returning to ProfileScreen
                          _loadUserData();
                        });
                      }),
                      SizedBox(height: 10),
                      _buildOptionCard(FontAwesomeIcons.lock, 'Change Password',
                          () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChangePasswordScreen();
                        }));
                      }),
                      SizedBox(height: 10),
                      _buildOptionCard(FontAwesomeIcons.book, 'Completed Books',
                          () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return CompletedBooksScreen();
                        }));
                      }),
                      SizedBox(height: 10),
                      _buildDarkModeToggle(),
                      SizedBox(height: 10),
                      _buildOptionCard(
                        FontAwesomeIcons.arrowRightFromBracket,
                        'Logout',
                        () async {
                          await FirebaseAuth.instance.signOut();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', false);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: TextStyle(color: AppColors.textPrimary),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(Icons.dark_mode, color: Colors.white),
          ),
          title: Text('Dark Mode', style: TextStyle(color: AppColors.textPrimary)),
          trailing: GestureDetector(
            onTap: _toggleDarkMode,
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: _isDarkMode ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: _isDarkMode ? 20 : 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
