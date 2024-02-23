import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geo_scan/View/Settings.dart';
import 'package:geo_scan/View/qr_scanned_data.dart';
import 'package:geo_scan/View/qr_screen.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/scandata.dart';
import '../Utility/device_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loader = true;
  List<ScanData> _scanDataList = [];
  String checkpointName = "";
  String currentCheckpointId = "";
  DatabaseHelper dbHelper = DatabaseHelper();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  int _totalUniqueScans = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      getScannedData().then((value) {
        setState(() {
          _scanDataList = value;
        });
        getTotalUniqueScans().then((value) {
          setState(() {
            _totalUniqueScans = value;
          });
        });
        getCurrentCheckpoint().then((value) {
          setState(() {
            currentCheckpointId = value[0];
            checkpointName = value[1];
            _loader = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (builder) => const QRScreen()));
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ART 40',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Current Checkpoint: $checkpointName",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Export to CSV'),
              onTap: () {
                getDataToShare().then((value) {
                  shareCSVFile(dataToCSV(value), checkpointName);
                });
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => const Settings()),
                );
              },
            ),
          ],
        ),
      ),
      body: _loader
          ? Center(
              child: Lottie.asset(
                "assets/animations/app_loader.json",
                height: 150,
                width: 150,
              ),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Total Cars : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(_totalUniqueScans.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DataTable(
                      // Datatable widget that have the property columns and rows.
                      columns: const [
                        DataColumn(
                          label: Text('Car Code'),
                        ),
                        DataColumn(
                          label: Text('Time Captured'),
                        ),
                      ],
                      rows: _scanDataList.map((scanData) {
                        return DataRow(cells: [
                          DataCell(Text(scanData.data)),
                          DataCell(Text(scanData.timestamp)),
                        ]);
                      }).toList(),
                    )
                  ],
                ),
              ),
            ),
    );
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

  Future<int> getTotalUniqueScans() async {
    int totalUniqueScans = await dbHelper.totalUniqueScannedData();
    return totalUniqueScans;
  }

  Future<List<ScanData>> getScannedData() async {
    return await dbHelper.getScannedData();
  }

  Future<List<Map<String, dynamic>>> getDataToShare() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? checkpointId = prefs.getInt('currentCheckpointId');
    List<ScanData> scanData = await dbHelper.getScannedData();
    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < scanData.length; i++) {
      data.add({
        'checkpointId': scanData[i].checkpoint_id,
        'checkpointName': await dbHelper.getCheckpointName(checkpointId!),
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
        '${deviceInfo['company']}-${deviceInfo['device']}'.toLowerCase();
    String checkpointName = currentCheckpointName.toLowerCase();
    String fileString = '$checkpointName.$deviceInfoString';
    final file = await File('${tempDir.path}/$fileString.csv').create();
    await file.writeAsString(csvData);
    Share.shareFiles([(file.path)], text: 'CSV Data');
  }
}
