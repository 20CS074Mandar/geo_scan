import 'package:flutter/material.dart';
import 'package:geo_scan/View/qr_scanned_data.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/scandata.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool _scanned = false;
  String _qrCodeValue = '';
  DatabaseHelper _dbHelper = DatabaseHelper();
  int _checkpointId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _scanned = false;
    });
    getCurrentCheckpointId().then((value) {
      setState(() {
        _checkpointId = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: _scanned
            ? Text(
                'QR Code Value: $_qrCodeValue',
                style: const TextStyle(fontSize: 20),
              )
            : FractionallySizedBox(
                widthFactor: 0.8,
                heightFactor: 0.4,
                child: MobileScanner(
                  onDetect: (capture) {
                    if (!_scanned) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        setState(() {
                          _scanned = true;
                          _qrCodeValue = barcode.rawValue!;
                          _insertQRData(_checkpointId, _qrCodeValue);
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QRScannedData()));
                        break; // Stop scanning after the first QR code is detected
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _insertQRData(int checkpointId, String data) async {
    final scanData = ScanData(
      checkpoint_id: checkpointId,
      timestamp: DateTime.now().toIso8601String(),
      data: data,
    );
    await _dbHelper.insertScanData(scanData);
    print("Data inserted successfully!");
  }

  Future<int> getCurrentCheckpointId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int checkpointId = preferences.getInt("currentCheckpointId") ?? 0;
    return checkpointId;
  }
}
