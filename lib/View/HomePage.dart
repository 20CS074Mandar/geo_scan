import 'package:flutter/material.dart';
import 'package:geo_scan/View/qr_scanned_data.dart';
import 'package:geo_scan/View/qr_screen.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/scandata.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loader = true;
  String _qrCodeValue = '';
  String checkpointName = "";
  String currentCheckpointId = "";
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      getCurrentCheckpoint().then((value) {
        setState(() {
          currentCheckpointId = value[0];
          checkpointName = value[1];
          _loader = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 20, right: 20),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 25),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    checkpointName,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    currentCheckpointId,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => const HomePage()),
                  );
                },
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  // Navigate to the QR Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (builder) => const QRScreen()),
                  );
                },
                icon: const Icon(Icons.qr_code),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onDoubleTap: (){
                  dbHelper.deleteAllScannedData();
                },
                child: IconButton(
                  onPressed: () {
                    // Navigate to the QR Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => const QRScannedData(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _loader
                ? Lottie.asset(
                    "assets/animations/app_loader.json",
                    height: 150,
                    width: 150,
                  )
                : const Column(
                    children: [
                      Text(
                        "Home Page",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _insertQRData(String data) async {
    final scanData = ScanData(
      checkpoint_id: 1,
      timestamp: DateTime.now().toIso8601String(),
      data: data,
    );
    await dbHelper.insertScanData(scanData);
    print("Data inserted successfully!");
  }

  Future<List> getCurrentCheckpoint() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int id = preferences.getInt("currentCheckpointId") ?? 0;
    String checkpointName = await dbHelper.getCheckpointName(id);
    List<String> result = [];
    result.add(id.toString());
    result.add(checkpointName);
    return result;
  }
}
