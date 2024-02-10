import 'package:flutter/material.dart';
import 'package:geo_scan/View/qr_scanned_data.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
                          _insertQRData(_qrCodeValue);
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>QRScannedData()));
                        break; // Stop scanning after the first QR code is detected
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }

  Future<void>_insertQRData(String data) async {
    final scanData = ScanData(
      checkpoint_id: 1,
      timestamp: DateTime.now().toIso8601String(),
      data: data,
    );
    await _dbHelper.insertScanData(scanData);
    print("Data inserted successfully!");
  }
}
