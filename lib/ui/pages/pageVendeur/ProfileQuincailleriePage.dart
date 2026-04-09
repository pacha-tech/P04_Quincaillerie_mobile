import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/QuincaillerieService.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../data/modele/QuincaillerieDetail.dart';

class ProfileQuincailleriePage extends StatefulWidget {
  const ProfileQuincailleriePage({super.key});

  @override
  State<ProfileQuincailleriePage> createState() => _ProfileQuincailleriePageState();
}

class _ProfileQuincailleriePageState extends State<ProfileQuincailleriePage> {
  late Future<QuincaillerieDetail?> _detailFuture;
  final QuincaillerieService _quincaillerieService = QuincaillerieService();
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _detailFuture = getDetailQuincaillerie();
    });
  }

  Future<QuincaillerieDetail?> getDetailQuincaillerie() async {
    try {
      return await _quincaillerieService.getProfileQuincaillerie();
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FutureBuilder<QuincaillerieDetail?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorWidgets(
              message: error is NoInternetConnectionException ? error.message : "Erreur de chargement",
              iconData: error is NoInternetConnectionException ? Icons.wifi_off : Icons.error_outline,
              onRetry: _loadData,
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState("Profil introuvable");
          }

          final quincaillerie = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, quincaillerie),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(quincaillerie),
                      const SizedBox(height: 24),
                      _buildActionButtons(context, quincaillerie), // Boutons de gestion
                      const SizedBox(height: 32),
                      _buildSectionTitle("Description de l'établissement"),
                      const SizedBox(height: 8),
                      Text(
                        quincaillerie.description ?? "Aucune description fournie.",
                        style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle("Informations de Localisation"),
                      const SizedBox(height: 12),
                      _buildLocationCard(quincaillerie),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, QuincaillerieDetail quincaillerie) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.blueAccent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: quincaillerie.photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.hardware, size: 50, color: Colors.grey),
              ),
            ),
            // Zone de photo : Bouton pour changer l'image
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  // Logique pour changer la photo
                },
                backgroundColor: Colors.white,
                child: Icon(Icons.camera_alt, color: colorScheme.secondary),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black38],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(QuincaillerieDetail quincaillerie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mon Magazin",
              style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(quincaillerie.averageRating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(quincaillerie.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, QuincaillerieDetail quincaillerie) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigation vers la page d'édition
            },
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text("Modifier le profil"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(QuincaillerieDetail quincaillerie) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildLocationRow(Icons.location_city, "Ville & Quartier", "${quincaillerie.ville}, ${quincaillerie.quartier}"),
          const Divider(height: 24),
          _buildLocationRow(Icons.map_outlined, "Région", quincaillerie.region),
          const Divider(height: 24),
          _buildLocationRow(Icons.near_me_outlined, "Précision adresse", quincaillerie.precision),
          const Divider(height: 24),
          _buildLocationRow(Icons.phone_android_outlined, "Contact affiché", quincaillerie.telephone),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold));

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          TextButton(onPressed: _loadData, child: const Text("Réessayer")),
        ],
      ),
    );
  }
}