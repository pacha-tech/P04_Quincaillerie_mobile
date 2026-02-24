import 'package:flutter/material.dart';
import '../modele/ProductSearch.dart';
import '../service/ApiService.dart';

class QuincaillerieDetailsPage extends StatefulWidget {
  final String quincaillerieId;
  final ProductSearch product;

  const QuincaillerieDetailsPage({
    super.key,
    required this.quincaillerieId,
    required this.product,
  });

  @override
  State<QuincaillerieDetailsPage> createState() => _QuincaillerieDetailsPageState();
}

class _QuincaillerieDetailsPageState extends State<QuincaillerieDetailsPage> {
  late Future<dynamic> _storeFuture;

  @override
  void initState() {
    super.initState();
    _storeFuture = ApiService().getDetailQuincaillerie(widget.quincaillerieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: FutureBuilder<dynamic>(
        future: _storeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erreur de chargement"));
          }

          final store = snapshot.data!;
          final priceEntry = widget.product.prices.firstWhere(
                (p) => p.idQuincaillerie == widget.quincaillerieId,
            orElse: () => widget.product.prices.first,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                pinned: true,
                elevation: 0.5,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  // Définit la position finale du nom quand la barre est réduite
                  titlePadding: const EdgeInsetsDirectional.only(start: 55, bottom: 16),
                  title: Row(
                    //mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.inventory, color: Colors.blue, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        store.name ?? "Quincaillerie",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 80), // Espace sous le titre étendu
                    child: Column(
                      children: [
                        // Les infos secondaires placées sous le nom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                Text(" ${store.quartier ?? 'N/A'}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ]
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                Text(" ${store.telephone ?? 'telephone'}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ]
                            ),
                            _buildRatingBadge(store.averageRating),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. LE PRODUIT SÉLECTIONNÉ ---
              SliverToBoxAdapter(
                child: _buildProductHighlight(priceEntry),
              ),

              // --- 3. SECTION RECOMMANDATIONS ---
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    "Vous pouvez aussi avoir besoin de:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildRecommendationCard(index),
                  childCount: 8,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingBadge(dynamic rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text("${rating ?? '0.0'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductHighlight(dynamic priceEntry) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.image, color: Colors.blue, size: 35),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${priceEntry.price} FCFA",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text("Acheter"),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50, height: 50,
          color: Colors.grey.shade100,
          child: const Icon(Icons.image, color: Colors.blue),
        ),
        title: Text("Nom"),
        subtitle: const Text("Description brève du produit"),
        trailing: const Icon(Icons.add, color: Colors.blue),
        onTap: () {},
      ),
    );
  }
}
