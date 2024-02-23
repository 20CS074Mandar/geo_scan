import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_scan/Models/checkpoint.dart';
import 'package:geo_scan/Utility/geo_location.dart';
import 'package:geo_scan/View/HomePage.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:geo_scan/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'import_location_csv.dart';

class HealthCheck extends StatefulWidget {
  const HealthCheck({super.key});

  @override
  State<HealthCheck> createState() => _HealthCheckState();
}

class _HealthCheckState extends State<HealthCheck> {
  bool _locationServiceStatus = false;
  bool _locationServiceLoading = true;
  double _latitude = 0.0;
  double _longitude = 0.0;
  double threshold = 3.0;
  bool _checkpointLoading = true;
  Checkpoint noCheckpoint = Checkpoint(
    checkpoint_name: "None",
    latitude: 0.0,
    longitude: 0.0,
  );
  DatabaseHelper dbHelper = DatabaseHelper();
  Checkpoint currentCheckpoint = Checkpoint(
    checkpoint_name: "None",
    latitude: 0.0,
    longitude: 0.0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    _changeIconToCheck();
    Future.delayed(const Duration(seconds: 2), () {
      _checkLocationServiceStatus().then((value) {
        GeoLocation().determineLocation().then((value) {
          _latitude = value.latitude;
          _longitude = value.longitude;
          _insertCheckpointsToDb().whenComplete(() {
            getCurrentCheckpoint().then((value) {
              saveCurrentCheckpointId(value.id,value.checkpoint_name).whenComplete(() {
                setState(() {
                  print("Value recived: ${value.checkpoint_name}  ");
                  currentCheckpoint = value;
                  print(
                      "Current Checkpoint: ${currentCheckpoint.checkpoint_name}");
                  _checkpointLoading = false;
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Health Check',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/animations/health_check.json'),
            ),
            healthCheckItem(
              icon: const Icon(Icons.location_on, size: 25, color: Colors.red),
              serviceType: "Location Service",
              loading: _locationServiceLoading,
              serviceStatus: _locationServiceStatus,
            ),
            const SizedBox(height: 20),
            healthCheckItem(
              icon: const Icon(Icons.check_circle, size: 25, color: Colors.red),
              serviceType: "Checkpoint Status ",
              loading: _checkpointLoading,
              serviceStatus: currentCheckpoint.checkpoint_name != "None",
            ),
            const SizedBox(height: 20),
            Text(
              "Current Checkpoint: ${currentCheckpoint.checkpoint_name ?? "None"}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget healthCheckItem(
      {required Icon icon,
      required String serviceType,
      required bool loading,
      required bool serviceStatus}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        icon,
        const SizedBox(width: 10), // Adding spacing between icon and text
        Text(serviceType, style: const TextStyle(fontSize: 20)),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
          width: 25, // Adjust according to your needs
          height: 25, // Adjust according to your needs
          child: loading
              ? Lottie.asset('assets/animations/app_loader.json')
              : serviceStatus
                  ? Lottie.asset('assets/animations/check_animation.json',
                      repeat: false)
                  : Lottie.asset('assets/animations/cross_animation.json',
                      repeat: false),
        ),
      ],
    );
  }

  Future<void> _checkLocationServiceStatus() async {
    bool locationServiceStatus = await GeoLocation().checkLocationService();
    if (locationServiceStatus) {
      bool checkPermission = await GeoLocation().checkPermission();
      if (checkPermission) {
        setState(() {
          _locationServiceLoading = false;
          _locationServiceStatus = true;
        });
      } else {
        // If location service is enabled but permission is not granted,
        // prompt the user to grant permission
        bool permissionGranted = await _requestLocationPermission();
        if (permissionGranted) {
          setState(() {
            GeoLocation().determineLocation().then((value) {
              _latitude = value.latitude;
              _longitude = value.longitude;
            });
            _locationServiceLoading = false;
            _locationServiceStatus = true;
          });
        } else {
          // Handle the case where user denies permission
          // You may want to show a message to the user
          setState(() {
            _locationServiceLoading = false;
            _locationServiceStatus = false;
          });
        }
      }
    } else {
      // Handle the case where location service is not enabled
      // You may want to show a message to the user
    }
  }

  Future<bool> _requestLocationPermission() async {
    // You should use a proper permission handling mechanism here,
    // such as using the permission_handler package
    // This is a basic example using showDialog to ask for permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _insertCheckpointsToDb() async {
    List<Checkpoint> checkpoints = await getCheckpointsFromCSV();
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

  Future<List<Checkpoint>> getCheckpointsFromCSV() async {
    List<Checkpoint> _checkpoints = [];
    final myData = await rootBundle.loadString('assets/csv/checkpoints.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(myData);
    for (int i = 1; i < csvTable.length; i++) {
      Checkpoint checkpoint = Checkpoint(
        checkpoint_name: csvTable[i][0],
        longitude: double.parse(csvTable[i][1].toString()),
        latitude: double.parse(csvTable[i][2].toString()),
      );
      _checkpoints.add(checkpoint);
    }
    return _checkpoints;
  }

  Future<List<Checkpoint>> getCheckpointsFromDb() async {
    return await dbHelper.getCheckpoints();
  }

  Future<dynamic> getCurrentCheckpoint() async {
    List<Checkpoint> allCheckpoints = await getCheckpointsFromDb();
    Checkpoint validCheckpoint;
    for (int i = 0; i < allCheckpoints.length; i++) {
      print(
          "current longitude $_longitude latitude $_latitude and checkpoint longitude ${allCheckpoints[i].longitude} and latitude ${allCheckpoints[i].latitude} and threshold $threshold");
      double distance = GeoLocation().calculateDistance(_latitude, _longitude,
          allCheckpoints[i].latitude, allCheckpoints[i].longitude);
      print("Distance from ${allCheckpoints[i].checkpoint_name}: $distance" +
          "Threshold: $threshold");
      if (GeoLocation().checkPointStatus(distance, threshold)) {
        validCheckpoint = allCheckpoints[i];
        return validCheckpoint;
      }
    }
    return noCheckpoint;
  }

  Future<void> saveCurrentCheckpointId(int currentCheckpointId,String currentCheckpointName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("currentCheckpointId", currentCheckpointId);
    preferences.setString("currentCheckpointName", currentCheckpointName);
    print("Saved Current Checkpoint Id");
    log("Saved Current Checkpoint Id to Shared Preferences",
        name: "HealthCheck", time: DateTime.now());
  }
}
