import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:geo_scan/Models/checkpoint.dart';

class CSV{
  List<Checkpoint> checkpoints= [];
  loadAsset() async {
    final myData = await rootBundle.loadString('assets/csv/checkpoints.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(myData);
    for (int i = 1; i < csvTable.length; i++) {
      Checkpoint checkpoint = Checkpoint(
        checkpoint_name: csvTable[i][0],
        latitude: double.parse(csvTable[i][1].toString()),
        longitude: double.parse(csvTable[i][2].toString()),
      );
      checkpoints.add(checkpoint);
    }
    for(int i=0;i<checkpoints.length;i++){
      print("Checkpoint ${i}"+checkpoints[i].checkpoint_name);
    }
  }
}