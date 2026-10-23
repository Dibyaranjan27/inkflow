import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inkflow/screens/welcome_screen.dart';
import 'package:inkflow/screens/authentication_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkflow/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check the login status after splash screen
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Simulate a loading process
    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      // Navigate to appropriate screen based on login status
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      body: Center(
        child: Image.asset(
          "assets/images/logo for dark.png",
          width: 400,
          height: 400,
        ),
      ),
    );
  }
}
