import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class GetDeviceInformation {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<String> deviceMacAddress() async {
    String deviceMacAddress = "0";

    return deviceMacAddress;
  }

  Future<Map<String, dynamic>> allInformationOfDevice() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return deviceData;
  }

  Map<String, dynamic> _readAndroidBuildData(
      AndroidDeviceInfo androidDeviceInfo) {
    var deviceData = {
      "company": androidDeviceInfo.brand,
      "model": androidDeviceInfo.model,
      "device": androidDeviceInfo.device,
      "deviceType": "A"
    };
    return deviceData;
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo iosDeviceInfo) {
    // during ios review and change the infos---------------------------------------------------
    var deviceData = {
      "company": "Apple",
      "model": iosDeviceInfo.model,
      "device": iosDeviceInfo.name,
      "deviceType": "I"
    };
    return deviceData;
  }
}
