import 'package:flutter/material.dart';
import '../service/DioClient.dart';
import '../data/modele/ProductSuggestion.dart';

class SuggestionProvider extends ChangeNotifier {
  final _dio = DioClient().dio;

  List<ProductSuggestion> _suggestions = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;


  List<ProductSuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;


  SuggestionProvider() {
    loadSuggestions();
  }


  Future<void> loadSuggestions({bool forceRefresh = false}) async {
    final now = DateTime.now();

    if (!forceRefresh && _suggestions.isNotEmpty && _lastFetchTime != null && now.difference(_lastFetchTime!).inMinutes < 10) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get("/products/suggestions");


      final List rawList = response.data as List;


      final Map<String, ProductSuggestion> uniqueProducts = {};

      for (var item in rawList) {
        final suggestion = ProductSuggestion.fromJson(item);
        final String normalizedName = suggestion.nom.toLowerCase().trim();


        if (!uniqueProducts.containsKey(normalizedName)) {
          uniqueProducts[normalizedName] = suggestion;
        }
      }


      _suggestions = uniqueProducts.values.toList();

      _lastFetchTime = now;
    } catch (e) {
      debugPrint("❌ Erreur suggestions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void clearCache() {
    _suggestions = [];
    _lastFetchTime = null;
    notifyListeners();
  }
}
