import 'package:geolocator/geolocator.dart';

class GeoLocation {
  Future<Position> _determineLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<double> getLongitude() {
    return _determineLocation().then((value) => value.longitude.toDouble());
  }

  Future<double> getLatitude() {
    return _determineLocation().then((value) => value.latitude.toDouble());
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
}
