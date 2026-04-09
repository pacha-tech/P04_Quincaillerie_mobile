
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


class LocationProvider extends ChangeNotifier {

  LocationProvider(){
    init();
  }

  LatLng? _userPosition;
  bool _isLoading = false;

  LatLng? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  bool get hasPosition => _userPosition != null;


  static const LatLng defaultPosition = LatLng(3.865, 11.520);

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _userPosition = defaultPosition;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _userPosition = defaultPosition;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _userPosition = LatLng(position.latitude, position.longitude);

      debugPrint("Service enabled: $serviceEnabled");
      debugPrint("Permission: $permission");
      debugPrint("Position: $_userPosition");

    } catch (e) {
      _userPosition = defaultPosition;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}