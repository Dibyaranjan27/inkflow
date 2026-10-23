import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkflow/theme/app_theme.dart';
import 'package:inkflow/screens/loading_screen.dart';
import 'package:inkflow/screens/welcome_screen.dart';
import 'package:inkflow/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// Root application widget configuring centralized theme and routing container.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inkflow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthCheck(),
    );
  }
}

/// Lifecycle and session gatekeeper widget.
/// Manages initial routing based on persisted user login status and first-launch state.
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isFirstOpen = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check the login status using SharedPreferences
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if it's the user's first time opening the app
    _isFirstOpen = prefs.getBool('isFirstOpen') ?? true;

    if (_isFirstOpen) {
      // Set the first open flag to false after the first launch
      await prefs.setBool('isFirstOpen', false);
    }

    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false; // Finish loading
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show empty scaffold inheriting background color from AppTheme.lightTheme
      return const Scaffold();
    }

    // Decide the initial screen based on login status
    // Redirect to SignInScreen if not logged in and not the first time
    if (!_isLoggedIn && !_isFirstOpen) {
      return LoginScreen(); // Redirect to the SignInScreen
    }

    return _isLoggedIn ? LoadingScreen() : WelcomeScreen();
  }
}
