import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DistanceUtils {


  static double calculateKm(LatLng from, double toLat, double toLng) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      toLat,
      toLng,
    ) / 1000;
  }


  static String formatDistance(LatLng from, double toLat, double toLng) {
    double meters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      toLat,
      toLng,
    );

    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    }
    return "${(meters / 1000).toStringAsFixed(1)} km";
  }
}