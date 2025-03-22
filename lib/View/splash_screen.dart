import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_scan/Models/checkpoint.dart';
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
    _insertCheckpointsToDb().whenComplete(() {
      _navigateToNextScreen();
    });
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
    int id = preferences.getInt("currentCheckpointId") ?? -1;
    if (id != -1) {
      return true;
    }
    return false;
  }

  Future<void> _insertCheckpointsToDb() async {
    List<Checkpoint> checkpoints = await _getCheckpointsFromCSV();
    for (int i = 0; i < checkpoints.length; i++) {
      // Check if the checkpoint already exists in the database
      Checkpoint checkpoint = checkpoints[i];
      List<Checkpoint> existingCheckpoints = await dbHelper.getCheckpoints();
      bool checkpointExists = existingCheckpoints.any((existingCheckpoint) =>
          existingCheckpoint.checkpoint_name == checkpoint.checkpoint_name &&
          existingCheckpoint.latitude == checkpoint.latitude &&
          existingCheckpoint.longitude == checkpoint.longitude);
      // If the checkpoint doesn't exist, insert it into the database
      if (!checkpointExists) {
        print("Inserting checkpoint: $checkpoint");
        await dbHelper.insertCheckpoint(checkpoint);
      }
    }
  }

  Future<List<Checkpoint>> _getCheckpointsFromCSV() async {
    List<Checkpoint> checkpoints = [];
    final myData = await rootBundle.loadString('assets/csv/checkpoints.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(myData);
    for (int i = 1; i < csvTable.length; i++) {
      Checkpoint checkpoint = Checkpoint(
        checkpoint_name: csvTable[i][0],
        longitude: double.parse(csvTable[i][1].toString()),
        latitude: double.parse(csvTable[i][2].toString()),
      );
      checkpoints.add(checkpoint);
    }
    return checkpoints;
  }
}
