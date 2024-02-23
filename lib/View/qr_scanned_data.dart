import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geo_scan/Models/checkpoint.dart';
import 'package:geo_scan/Utility/device_info.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/scandata.dart';

class QRScannedData extends StatefulWidget {
  const QRScannedData({super.key});

  @override
  State<QRScannedData> createState() => _QRScannedDataState();
}

class _QRScannedDataState extends State<QRScannedData> {
  List<ScanData> _scanDataList = [];
  DatabaseHelper _dbHelper = DatabaseHelper();
  String _currentCheckpointName = '';
  String _currentCheckpointId = '';

  @override
  void initState() {
    super.initState();
    getScannedData().then((value) {
      setState(() {
        _scanDataList = value;
      });
      getCurrentCheckpointData().then((value) {
        setState(() {
          _currentCheckpointName = value[0]['checkpoint_name'];
          _currentCheckpointId = value[0]['id'].toString();
        });
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
            Text(
              '$_currentCheckpointId $_currentCheckpointName Scanned Data.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _scannerDataList(context),
            ElevatedButton(
              onPressed: () {
                getDataToShare().then((value) {
                  print(value);
                  shareCSVFile(dataToCSV(value), _currentCheckpointName);
                });
              },
              child: const Text('Share Scanned Data'),
            ),
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
                            Text(
                                'Timestamp: ${_scanDataList[index].timestamp}'),
                            Text(
                                'Checkpoint : ${_scanDataList[index].checkpoint_id}'),
                          ],
                        ),
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

  Future<List<Map<String, dynamic>>> getCurrentCheckpointData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? checkpointId = prefs.getInt('currentCheckpointId');
    String checkpointName = prefs.getString('currentCheckpointName') ?? 'None';
    return [
      {'id': checkpointId, 'checkpoint_name': checkpointName}
    ];
  }

  Future<List<ScanData>> getScannedData() async {
    return await _dbHelper.getScannedData();
  }

  Future<List<Map<String, dynamic>>> getDataToShare() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? checkpointId = prefs.getInt('currentCheckpointId');
    String checkpointName = prefs.getString('currentCheckpointName') ?? 'None';
    List<ScanData> scanData = await _dbHelper.getScannedData();
    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < scanData.length; i++) {
      data.add({
        'checkpointId': scanData[i].checkpoint_id,
        'checkpointName': await _dbHelper.getCheckpointName(checkpointId!),
        'data': scanData[i].data,
        'timestamp': scanData[i].timestamp
      });
    }
    return data;
  }

  dataToCSV(List<Map<String, dynamic>> data) {
    String csv = '';
    csv += 'Car Code,Time Captured\n';
    for (int i = 1; i < data.length; i++) {
      csv += '${data[i]['data']},${data[i]['timestamp']}\n';
    }
    return csv;
  }

  Future<void> shareCSVFile(
      String csvData, String currentCheckpointName) async {
    final tempDir = await getTemporaryDirectory();
    Map<String, dynamic> deviceInfo =
        await GetDeviceInformation().allInformationOfDevice();
    // String? deviceId = await GetDeviceInformation().getDeviceId();
    String deviceInfoString =
        '${deviceInfo['company']}-${deviceInfo['device']}';
    String checkpointName = currentCheckpointName;
    String fileString = '$deviceInfoString-$checkpointName';
    final file = await File('${tempDir.path}/$fileString.csv').create();
    await file.writeAsString(csvData);
    Share.shareFiles([(file.path)], text: 'CSV Data');
  }
}
