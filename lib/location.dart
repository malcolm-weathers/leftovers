import 'package:location/location.dart';

class MyLocation {
  Future<Map<String, double>> get() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    Map<String, double> _myLoc = {
      'latitude': _locationData.latitude,
      'longitude': _locationData.longitude
    };
    return _myLoc;
  }
}