import 'package:flutter/material.dart';
import 'package:geo_scan/View/HealthCheck.dart';
import 'package:geo_scan/View/HomePage.dart';
import 'package:geo_scan/View/SelectLocation.dart';
import 'package:geo_scan/View/qr_screen_location_registration.dart';
import 'package:lottie/lottie.dart';

class LocationDetectionMethod extends StatefulWidget {
  const LocationDetectionMethod({super.key});

  @override
  State<LocationDetectionMethod> createState() =>
      _LocationDetectionMethodState();
}

enum SingingCharacter { AutoLocationDetection, QRBasedLocationDetection }

class _LocationDetectionMethodState extends State<LocationDetectionMethod> {
  SingingCharacter? _character = SingingCharacter.AutoLocationDetection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Detection Method'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select Location Detection Method',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildOptionCard(
              title: 'Auto Location Detection',
              description:
                  'Uses your device GPS to automatically detect your location',
              icon: Icons.location_on,
              value: SingingCharacter.AutoLocationDetection,
              lottieAsset: 'assets/animations/location.json',
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              title: 'QR Based Location Detection',
              description: 'Scan a QR code to determine your location',
              icon: Icons.qr_code_scanner,
              value: SingingCharacter.QRBasedLocationDetection,
              lottieAsset: 'assets/animations/scan.json',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_character == SingingCharacter.AutoLocationDetection) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HealthCheck()),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SelectLocation()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required SingingCharacter value,
    required String lottieAsset,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _character == value
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _character = value;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<SingingCharacter>(
                value: value,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Lottie.asset(
                  lottieAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
