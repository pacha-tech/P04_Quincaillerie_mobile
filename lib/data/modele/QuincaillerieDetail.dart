import 'package:decimal/decimal.dart';

class QuincaillerieDetail {

  final String name;
  final String ville;
  final String quartier;
  final String? telephone;
  final Decimal? averageRating;
  final String status;

  QuincaillerieDetail({required this.name, required this.ville, required this.quartier, required this.telephone, required this.averageRating, required this.status});

  factory QuincaillerieDetail.fromJson(Map<String, dynamic> json) {
    return QuincaillerieDetail(
      name: json['name'],
      ville: json['ville'],
      quartier: json['quartier'],
      telephone: json['telephone'],
      averageRating: json['averageRating']??= Decimal.zero,
      status: json['status'],
    );
  }
}