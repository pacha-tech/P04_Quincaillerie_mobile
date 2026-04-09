import 'package:intl/intl.dart';

class AddPromotionDTO {
  final String nom;
  final double taux;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<String> idsPrices;

  AddPromotionDTO({
    required this.nom,
    required this.taux,
    required this.dateDebut,
    required this.dateFin,
    required this.idsPrices,
  });

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return {
      "nom": nom,
      "tauxRemise": taux,
      "dateDebut": formatter.format(dateDebut),
      "dateFin": formatter.format(dateFin),
      "idsPrices": idsPrices
    };
  }
}