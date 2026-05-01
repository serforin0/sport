import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A43), // Background Dark Blue
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 240,
        ),
      ),
    );
  }
}
