import 'package:flutter/material.dart';
import 'package:geo_scan/Models/checkpoint.dart';
import 'package:geo_scan/View/qr_scanned_data.dart';
import 'package:geo_scan/View/splash_screen.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:geolocator/geolocator.dart';

import './Utility/geo_location.dart';
import 'View/qr_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  double _longitude = 0.0;
  double _latitude = 0.0;
  bool _longitudeLoader = true;
  bool _latitudeLoader = true;
  final double _thresholdDistance = 3.0;
  final List<Checkpoint> _locationData = [
    // Location(latitude: 37.4297983, longitude: -122.2126),
    // Location(latitude: 37.4397983, longitude: -122.2126),
    // Location(latitude: 37.4497983, longitude: -122.2126),
    // Location(latitude: 37.4597983, longitude: -122.2126),
    // Location(latitude: 37.5000000, longitude: -122.2126),
  ];

  @override
  void initState() {
    super.initState();
    getCheckpoints().then((value) {
      setState(() {
        _locationData.addAll(value);
      });
    });
    checkLocationPermission().then((value) {
      if (value) {
        GeoLocation().getLongitude().then((value) {
          setState(() {
            //print("Longitude: $value");
            _longitude = value;
            _longitudeLoader = false;
          });
        });
        GeoLocation().getLatitude().then((value) {
          //print("Latitude: $value");
          setState(() {
            _latitude = value;
            _latitudeLoader = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Longitude: ",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  _longitudeLoader ? buildLoader() : Text("$_longitude"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Latitude: ",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  _latitudeLoader ? buildLoader() : Text("$_latitude"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text("Threshold $_thresholdDistance km",
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              locationList(context)
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.home),
                color: Colors.black,
                onPressed: () {
                  // Navigate to the QR Screen
                  Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => const MyApp()));
                },
              ),
            ),
            Expanded(
              child: IconButton(
                  onPressed: () {
                    // Navigate to the QR Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const QRScreen()));
                  },
                  icon: const Icon(Icons.qr_code)),
            ),
            Expanded(
              child: IconButton(
                  onPressed: () {
                    // Navigate to the QR Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const QRScannedData()));
                  },
                  icon: const Icon(Icons.list)),
            ),
          ],
        )));
  }

  Widget buildLoader() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color
        borderRadius: BorderRadius.circular(5), // Circular border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0.5,
            blurRadius: 0.5,
            offset: const Offset(0, 1), // Shadow position
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.deepPurple), // Color of the progress indicator
        ),
      ),
    );
  }

  Widget locationList(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _locationData.length,
          itemBuilder: (BuildContext context, int index) {
            Checkpoint location = _locationData[index];
            final latitude = location.latitude;
            final longitude = location.longitude;
            final checkpointName = location.checkpoint_name;
            final distance = GeoLocation().calculateDistance(
                _latitude, _longitude, location.latitude, location.longitude);
            return Container(
              padding: const EdgeInsets.all(10.0),
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: GeoLocation().checkPointStatus(
                        GeoLocation().calculateDistance(_latitude, _longitude,
                            location.latitude, location.longitude),
                        _thresholdDistance)
                    ? Colors.green
                    : Colors.red,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checkpoint Name: $checkpointName',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: $latitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Longitude: $longitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Distance: ${distance.toStringAsFixed(2)} km',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    bool locationStatus = true;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationStatus = false;
      return Future.error('Location services are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      locationStatus = false;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        locationStatus = false;
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      locationStatus = false;
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions');
    }
    return locationStatus;
  }

  Future<List<Checkpoint>> getCheckpoints() async {
    return await databaseHelper.getCheckpoints();
  }
}
