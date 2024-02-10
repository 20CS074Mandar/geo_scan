import 'package:flutter/material.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:share_plus/share_plus.dart';

import '../Models/scandata.dart';

class QRScannedData extends StatefulWidget {
  const QRScannedData({super.key});

  @override
  State<QRScannedData> createState() => _QRScannedDataState();
}

class _QRScannedDataState extends State<QRScannedData> {
  List<ScanData> _scanDataList = [];
  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    getScannedData().then((value) {
      setState(() {
        _scanDataList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scanned Data'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Scanned Data',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _scannerDataList(context),
          ],
        ));
  }

  Widget _scannerDataList(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView.builder(
          itemCount: _scanDataList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'Scanned Data: ${_scanDataList[index].data}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Timestamp: ${_scanDataList[index].timestamp}'),
                            Text(
                                'Checkpoint : ${_scanDataList[index].checkpoint_id}'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child:
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Share scanned data
                        final String text = 'Scanned Data: ${_scanDataList[index].data}\n'
                            'Timestamp: ${_scanDataList[index].timestamp}\n'
                            'Checkpoint : ${_scanDataList[index].checkpoint_id}';

                        Share.share(text, subject: 'Scanned Data');
                        // Share scanned data
                      },
                    ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<ScanData>> getScannedData() async {
    return await _dbHelper.getScannedData();
  }
}
