import 'package:flutter/material.dart';
import 'package:inkflow/screens/authentication_screen.dart';
import 'package:inkflow/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        // Wrap the Column with SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              width: double.infinity,
              height: 590.0,
              image: AssetImage('assets/images/girl-book-reading.png'),
            ),
            SizedBox(height: 10), // Space at the top
            Text(
              'InkFlow',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10), // Space between title and tagline
            Text(
              'Dive into a world of knowledge and stories.',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30), // Space for better visibility
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AuthenticationScreen();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30), // Space at the bottom
          ],
        ),
      ),
    );
  }
}
