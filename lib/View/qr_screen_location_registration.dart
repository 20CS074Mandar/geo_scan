import 'package:flutter/material.dart';
import 'package:geo_scan/View/HomePage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScreenLocationRegistration extends StatefulWidget {
  const QRScreenLocationRegistration({super.key});

  @override
  State<QRScreenLocationRegistration> createState() =>
      _QRScreenLocationRegistrationState();
}

class _QRScreenLocationRegistrationState
    extends State<QRScreenLocationRegistration> {
  bool _scanned = false;
  String _qrCodeValue = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _scanned = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.4,
          child: MobileScanner(onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (_scanned) return;
            for (final barcode in barcodes) {
              setState(() async {
                _scanned = true;
                _qrCodeValue = barcode.rawValue!;
                await _insertQRData(_qrCodeValue);
              });
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
              break; // Stop scanning after the first QR code is detected
            }
          }),
        ),
      ),
    );
  }

  Future<void> _insertQRData(String checkPointString) async {
    // checkPointStringFormat: "CheckPointId-CheckPointName"
    List<String> checkPointData = checkPointString.split("-");
    // save checkpoint id in shared preferences and check point name too
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("currentCheckpointId", int.parse(checkPointData[0]));
    preferences.setString("currentCheckpointName", checkPointData[1]);
  }

  Future<int> getCurrentCheckpointId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int checkpointId = preferences.getInt("currentCheckpointId") ?? 0;
    return checkpointId;
  }
}
