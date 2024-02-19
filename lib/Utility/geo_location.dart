import 'package:geolocator/geolocator.dart';

class GeoLocation {
  Future<Position> determineLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<double> getLongitude() {
    return determineLocation().then((value) => value.longitude.toDouble());
  }

  Future<double> getLatitude() {
    return determineLocation().then((value) => value.latitude.toDouble());
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    double distanceInKilometers = distanceInMeters / 1000.0;
    String inString = distanceInKilometers.toStringAsFixed(2);
    distanceInKilometers = double.parse(inString);
    return distanceInKilometers;
  }

  //This method checks if the check point is valid or not.
  bool checkPointStatus(double distance, double threshold) {
    if (distance > threshold) {
      return false;
    }
    return true;
  }

  Future<bool> checkLocationService() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<bool> checkPermission() {
    return Geolocator.checkPermission().then((value) {
      if (value == LocationPermission.always ||
          value == LocationPermission.whileInUse) {
        return true;
      }
      return false;
    });
  }
}
