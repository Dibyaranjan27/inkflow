import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inkflow/screens/home_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inkflow/constants.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a loading process
    Timer(Duration(seconds: 2), () {
      // Navigate to WelcomeScreen after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Circular image
                ClipOval(
                  child: Image.asset(
                    "assets/images/girl-book-reading.png",
                    width: 400, // Adjust the width as needed
                    height: 400, // Adjust the height as needed
                    fit: BoxFit.cover, // Ensures the image covers the circle
                  ),
                ),
                SizedBox(
                    height: 20), // Space between logo and loading indicator
                SpinKitWaveSpinner(
                  color: kLogoColor,
                  waveColor: kWaveColor,
                  trackColor: kTrackColor,
                  size: 100.0,
                ), // Loading indicator
                SizedBox(height: 20),
                Text(
                  "Loading...",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
