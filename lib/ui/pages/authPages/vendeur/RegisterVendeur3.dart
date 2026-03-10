import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'MapFull.dart';
import 'RegisterVendeur4.dart';

class RegisterVendeur3 extends StatefulWidget {
  final String nom;
  final String email;
  final String telephone;
  final String password;

  final String storeName;
  final String region;
  final String ville;
  final String quartier;
  final String precision;
  final String description;

  const RegisterVendeur3({
    super.key,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.password,
    required this.storeName,
    required this.region,
    required this.ville,
    required this.quartier,
    required this.precision,
    required this.description,
  });

  @override
  State<RegisterVendeur3> createState() => _RegisterVendeur3State();
}

class _RegisterVendeur3State extends State<RegisterVendeur3> {
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;   // Loading pour GPS
  bool _isLoading = false;           // Loading global (pour Continuer)

  // Centre par défaut : Yaoundé
  final LatLng _defaultCenter = LatLng(3.865, 11.520);

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      var status = await Permission.location.request();

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (!mounted) return;

        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Position récupérée : ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La localisation est nécessaire pour continuer"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Devenir vendeur sur Brixel"),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Position de votre magasin",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C1F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStepIndicator("1", true),
                      _buildStepConnector(true),
                      _buildStepIndicator("2", true),
                      _buildStepConnector(true),
                      _buildStepIndicator("3", true),
                      _buildStepConnector(false),
                      _buildStepIndicator("4", false),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Text("Si vous etes actuellement a l'endroit de votre magasin activer simplement votre localisaton "),
                  TextButton(
                    onPressed: (){},
                    child: Text("En savoir plus sur la localisation"),
                  ),

                  const SizedBox(height: 24),

                  // Bouton Ma position actuelle
                  ElevatedButton.icon(
                    icon: _isLoadingLocation
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                        : const Icon(Icons.my_location),
                    label: Text(_isLoadingLocation ? "Récupération..." : "Ma position actuelle"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A825),
                      foregroundColor: Colors.black87,
                      disabledBackgroundColor: const Color(0xFFFBF5DE),
                    ),
                    onPressed: (_isLoadingLocation || _isLoading) ? null : _getCurrentLocation,
                  ),

                  const SizedBox(height: 24),
                  Text("Sinon localisez le sur la carte"),
                  const SizedBox(height: 24),

                  // Bouton Voir la carte
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text("Voir la carte"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A825),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      disabledBackgroundColor: const Color(0xFFFBF5DE),
                    ),
                    onPressed: (_isLoading || _isLoadingLocation) ? null : () async {
                      final LatLng? result = await Navigator.push<LatLng?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapFull(),
                        ),
                      );

                      if (result != null && mounted) {
                        setState(() {
                          _selectedLocation = result;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Coordonnées affichées juste en dessous du bouton "Voir la carte"
                  if (_selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Coordonnées sélectionnées :\nLat: ${_selectedLocation!.latitude.toStringAsFixed(6)}\nLng: ${_selectedLocation!.longitude.toStringAsFixed(6)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Boutons Précédent / Continuer
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isLoading ? Colors.grey : const Color(0xFFF9A825),
                              width: 2,
                            ),
                            foregroundColor: _isLoading ? Colors.grey : const Color(0xFF1F0404),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("Précédent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_isLoading || _selectedLocation == null)
                              ? null
                              : () async {
                            setState(() => _isLoading = true);

                            try {
                              await Future.delayed(const Duration(milliseconds: 800));

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterVendeur4(
                                    nom: widget.nom,
                                    email: widget.email,
                                    telephone: widget.telephone,
                                    password: widget.password,
                                    storeName: widget.storeName,
                                    region: widget.region,
                                    ville: widget.ville,
                                    quartier: widget.quartier,
                                    precision: widget.precision,
                                    description: widget.description,
                                    latitude: _selectedLocation!.latitude,
                                    longitude: _selectedLocation!.longitude,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9A825),
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: const Color(0xFFFBF5DE),
                            disabledForegroundColor: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black87,
                            ),
                          )
                              : const Text("Continuer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF9A825) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 3,
      color: isActive ? const Color(0xFFF9A825) : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}