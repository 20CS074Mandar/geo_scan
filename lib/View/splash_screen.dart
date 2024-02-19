import 'package:flutter/material.dart';
import 'package:geo_scan/View/HealthCheck.dart';
import 'package:lottie/lottie.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    // Add any initialization logic here
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate waiting for the animation to complete
    await Future.delayed(const Duration(seconds: 5)); // Adjust the duration as needed

    // Navigate to the next screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HealthCheck()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset('assets/animations/splash_animation.json'),
      ),
    );
  }
}
