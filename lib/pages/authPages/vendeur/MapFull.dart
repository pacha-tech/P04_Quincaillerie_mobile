import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapFull extends StatefulWidget {
  const MapFull({super.key});

  @override
  State<MapFull> createState() => _MapFullState();
}

class _MapFullState extends State<MapFull> {
  LatLng? _selectedLocation;
  final LatLng _defaultCenter = LatLng(3.865, 11.520); // Yaoundé

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir la position de votre boutique"),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Carte pleine écran
          FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation ?? _defaultCenter,
              initialZoom: 12.0,
              // Active toutes les interactions : zoom, drag, clic
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, LatLng point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.quinca.market.app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 60,
                      height: 60,
                      alignment: Alignment.bottomCenter,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Bouton "Confirmer" en bas (n'apparaît que si position sélectionnée)
          if (_selectedLocation != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  // On renvoie la position à la page précédente
                  Navigator.pop(context, _selectedLocation);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                ),
                child: const Text(
                  "Confirmer cette position",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}