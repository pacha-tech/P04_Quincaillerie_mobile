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


    if (!forceRefresh &&
        _suggestions.isNotEmpty &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 10) {
      return;
    }

    _isLoading = true;
    notifyListeners(); // Notifie l'UI pour afficher un loader

    try {
      final response = await _dio.get("/products/suggestions");

      print(response);

      _suggestions = (response.data as List)
          .map((item) => ProductSuggestion.fromJson(item))
          .toList();

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
