import 'package:brixel/service/ApiService.dart';
import '../modele/ProductSuggestion.dart';


class SuggestionService {
  final ApiService _apiService = ApiService();


  List<ProductSuggestion>? _cachedSuggestions;


  DateTime? _lastFetchTime;

  Future<List<ProductSuggestion>> getAllSuggestions() async {
    final now = DateTime.now();

    if (_cachedSuggestions != null &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 10) {

      print("🚀 Retour du cache (Données datant de ${now.difference(_lastFetchTime!).inMinutes} min)");
      return _cachedSuggestions!;
    }


    try {
      print("🌐 Appel serveur en cours (Cache expiré ou vide)...");
      final results = await _apiService.getSuggestions();

      _cachedSuggestions = results;
      _lastFetchTime = now;

      return _cachedSuggestions ?? [];
    } catch (e) {
      print("Erreur lors de la récupération : $e");
      return _cachedSuggestions ?? [];
    }
  }


  void clearCache() {
    _cachedSuggestions = null;
    _lastFetchTime = null;
    print("🧹 Cache vidé manuellement");
  }
}