import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool _scanned = false;
  String _qrCodeValue = '';

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
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR Code Scanned')),
                        );
                        break; // Stop scanning after the first QR code is detected
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }
}
