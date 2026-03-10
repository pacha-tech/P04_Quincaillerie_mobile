import 'package:brixel/data/modele/ProductStock.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/ui/pages/pageVendeur/AddProductPage.dart';
import 'package:brixel/ui/widgets/DeleteProductPopup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Exception/NoInternetConnectionException.dart';
import 'UpdateProductPage.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final ProductService _productService = ProductService();
  late ColorScheme colorScheme;


  final TextEditingController _searchController = TextEditingController();


  bool _showSearchBar = false;


  String _sortOption = 'Date d\'ajout';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _showFilterMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 60, 20, 0),
      items: [
        PopupMenuItem(
          value: 'Date d\'ajout',
          child: const Text('Date d\'ajout'),
          onTap: () => setState(() => _sortOption = 'Date d\'ajout'),
        ),
        PopupMenuItem(
          value: 'Ordre croissant',
          child: const Text('Ordre croissant (A → Z)'),
          onTap: () => setState(() => _sortOption = 'Ordre croissant'),
        ),
        PopupMenuItem(
          value: 'Ordre décroissant',
          child: const Text('Ordre décroissant (Z → A)'),
          onTap: () => setState(() => _sortOption = 'Ordre décroissant'),
        ),
        PopupMenuItem(
          value: 'Prix croissant',
          child: const Text('Prix croissant'),
          onTap: () => setState(() => _sortOption = 'Prix croissant'),
        ),
        PopupMenuItem(
          value: 'Prix décroissant',
          child: const Text('Prix décroissant'),
          onTap: () => setState(() => _sortOption = 'Prix décroissant'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: _showSearchBar
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Rechercher...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 18),
          onSubmitted: (_) => setState(() => _showSearchBar = false),
        )
            : const Text("Mon Stock", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (!_showSearchBar)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() {
                _showSearchBar = true;
                _searchController.clear();
              }),
            ),
          if(!_showSearchBar)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterMenu,
            ),
          if(!_showSearchBar)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(() {}), // Force refresh du FutureBuilder
            ),
          if(_showSearchBar)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => setState(() {
                _showSearchBar = false;
                _searchController.clear();
              }),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ProductStock?>>(
              future: _productService.getProductsByQuincaillerie(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  //return _buildErrorState(snapshot.error.toString());

                  if (snapshot.hasError) {
                    final error = snapshot.error;


                    if (error is NoInternetConnectionException) {
                      return _buildErrorState(
                        error.message,
                        icon: Icons.wifi_off_rounded,
                        onRetry: () => setState(() {}),
                      );
                    }


                    if (error is DioException) {
                      String message = "Erreur réseau";
                      if (error.type == DioExceptionType.connectionTimeout) {
                        message = "Le serveur met trop de temps à répondre";
                      } else if (error.response?.statusCode == 404) {
                        message = "Service introuvable sur le serveur";
                      }

                      return _buildErrorState(
                        message,
                        icon: Icons.cloud_off_rounded,
                        onRetry: () => setState(() {}),
                      );
                    }


                    return _buildErrorState("Une erreur est survenue : ${error.toString()}");
                  }
                }


                final allProducts = snapshot.data ?? [];


                final query = _searchController.text.trim().toLowerCase();
                List<ProductStock?> filtered = allProducts;
                if (query.isNotEmpty) {
                  filtered = allProducts.where((p) {
                    return p != null &&
                        (p!.name.toLowerCase().contains(query));
                  }).toList();
                }

                // Tri
                switch (_sortOption) {
                  case 'Ordre croissant':
                    filtered.sort((a, b) => a!.name.compareTo(b!.name));
                    break;
                  case 'Ordre décroissant':
                    filtered.sort((a, b) => b!.name.compareTo(a!.name));
                    break;
                  case 'Prix croissant':
                    filtered.sort((a, b) => a!.sellPrice.compareTo(b!.sellPrice));
                    break;
                  case 'Prix décroissant':
                    filtered.sort((a, b) => b!.sellPrice.compareTo(a!.sellPrice));
                    break;
                // 'Date d\'ajout' : à implémenter quand tu auras createdAt
                  default:
                    break;
                }


                final count = filtered.length;

                if (count == 0) {
                  return _buildEmptyState(colorScheme);
                }

                return Column(
                  children: [
                    _buildStockSummary(count, colorScheme),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index]!;
                          return GestureDetector(
                            // onTap: () => _goToProductDetails(product),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Image
                                    Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                                      )
                                          : Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: 28),
                                    ),
                                    const SizedBox(width: 16),

                                    // Infos produit
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 2),
                                          Text("${product.brand} • ${product.category}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "${product.stock} ${product.unit}",
                                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),


                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${product.sellPrice} FCFA",
                                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 15),
                                        ),
                                        const Text("Prix Vente", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                                      ],
                                    ),

                                    // Menu 3 points
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                                      onSelected: (value) {
                                        if (value == 'modifier') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UpdateProductPage(product: product),
                                            ),
                                          );
                                        } else if (value == 'supprimer') {
                                          showDialog(
                                              context: context,
                                              barrierColor: Colors.black.withOpacity(0.7),
                                              barrierDismissible: false,
                                              builder: (context) => DeleteProductPopup(productId: "10" , name: product.name)
                                          );
                                        } else if (value == 'autre') {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Autre action")),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'modifier', child: Text("Modifier")),
                                        const PopupMenuItem(value: 'supprimer', child: Text("Supprimer", style: TextStyle(color: Colors.red))),
                                        const PopupMenuItem(value: 'autre', child: Text("Autre")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary(int count, ColorScheme color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.primary, color.secondary],
          begin: Alignment.bottomLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Produits", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("$count", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: color.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("Aucun produit en stock", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, {IconData icon = Icons.error_outline, VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Réessayer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}