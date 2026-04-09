

class Promotion {
  final String nom;
  final String taux;
  final String dateDebut;
  final String dateFin;
  final bool estActif;
  final int? nbreProduits;

  Promotion({required this.nom , required this.taux , required this.dateDebut , required this.dateFin , required this.estActif , required this.nbreProduits});

  factory Promotion.fromJson(Map<String , dynamic> json ){
    return Promotion(
        nom: json["name"],
        taux: json["taux"],
        dateDebut: json["dateDebut"],
        dateFin: json["dateFin"],
        estActif: json["estActif"],
        nbreProduits: json["nbreProduits"] ?? 0
    );
  }
}