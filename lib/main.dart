import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nom De l’App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  // Liste des catégories avec icônes (utilisez des icônes Material pour le prototype, remplacez par assets si besoin)
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.build, 'label': 'Outils'},
    {'icon': Icons.straighten, 'label': 'Mesure'},
    {'icon': Icons.water_drop, 'label': 'Robinetterie'},
    {'icon': Icons.lock, 'label': 'Serrage & fixation'},
    {'icon': Icons.format_paint, 'label': 'Peinture'},
    {'icon': Icons.handyman, 'label': 'Perçage & vissage'},
    {'icon': Icons.security, 'label': 'Sécurité'},
    {'icon': Icons.storage, 'label': 'Stockage'},
    {'icon': Icons.lightbulb, 'label': 'Électricité'},
    {'icon': Icons.local_florist, 'label': 'Jardinage'},
    {'icon': Icons.construction, 'label': 'Façonnage & finition'},
  ];

  // Produits populaires et promotions (placeholders avec icônes, remplacez par images assets)
  final List<IconData> popularProducts = [
    Icons.lightbulb_outline, // Ampoule
    Icons.security, // Casque
    Icons.handyman, // Perceuse
    Icons.image, // Cadre
    Icons.build, // Tournevis
    Icons.gavel, // Marteau
  ];

  final List<IconData> promotions = [
    Icons.handyman, // Perceuse
    Icons.image, // Cadre
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Logo (remplacez par Image.asset si vous avez un logo)
            Text('Logo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit, une marque...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.location_on, color: Colors.black), // Icône de localisation ajoutée
              onPressed: () {
                // Logique pour gérer la localisation (ex: ouvrir une carte ou détecter GPS)
                print('Localisation cliquée');
              },
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                // Naviguer vers le panier
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Naviguer vers inscription/connexion
            },
            child: Text('S\'inscrire / Se connecter', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière
            Container(
              color: Colors.brown[800],
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tout pour vos chantiers, au meilleur prix',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'comparez les prix de centaines de quincailleries au Cameroun. Outlis, materiaux, équipement, tout est la.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Explorer catalogue
                        },
                        child: Text('Explorer le catalogue'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                      ),
                      SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          // Devenir vendeur
                        },
                        child: Text('Devenir vendeur', style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Catégories
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Icon(categories[index]['icon'], size: 30),
                        ),
                        SizedBox(height: 4),
                        Text(categories[index]['label'], textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Produits populaires
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Produits populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: popularProducts.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.yellow[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(popularProducts[index], size: 50),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Voir produit
                        },
                        child: Text('voir'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Promotions
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Promotion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: promotions.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.yellow[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(promotions[index], size: 50),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Voir promotion
                        },
                        child: Text('voir'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 80), // Espace pour la bottom nav
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          // Ajoutez plus d'icônes si besoin (ex: chat, listes, etc.)
        ],
        currentIndex: 0, // Accueil sélectionné
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Gérer navigation
        },
      ),
    );
  }
}