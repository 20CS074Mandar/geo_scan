import 'package:flutter/material.dart';
import 'package:geo_scan/View/HealthCheck.dart';
import 'package:geo_scan/View/HomePage.dart';
import 'package:geo_scan/View/LocationDetectionMethod.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();

  void initState() {
    super.initState();
    // Add any initialization logic here
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate waiting for the animation to complete
    await Future.delayed(
        const Duration(seconds: 3)); // Adjust the duration as needed

    var isCheckPointPresent = await isCheckPointPresentInCache();
    // Navigate to the next screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              isCheckPointPresent ? HomePage() : LocationDetectionMethod()),
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

  Future<bool> isCheckPointPresentInCache() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int id = preferences.getInt("currentCheckpointId") ?? 0;
    String checkpointName = await dbHelper.getCheckpointName(id);
    if (checkpointName.isNotEmpty) {
      return true;
    }
    return false;
  }
}
