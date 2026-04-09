import 'package:decimal/decimal.dart';

class QuincaillerieDetail {

  final String name;
  final String region;
  final String ville;
  final String quartier;
  final String precision;
  final String telephone;
  final Decimal averageRating;
  final String photoUrl;
  final String longitude;
  final String latitude;
  final String status;
  final String? description;

  QuincaillerieDetail({required this.name, required this.region , required this.ville, required this.quartier, required this.precision , required this.telephone, required this.averageRating, required this.photoUrl, required this.longitude, required this.latitude, required this.status, required this.description});

  factory QuincaillerieDetail.fromJson(Map<String, dynamic> json) {
    return QuincaillerieDetail(
      name: json['name'],
      region: json['region'],
      ville: json['ville'],
      quartier: json['quartier'],
      precision: json['precision'],
      telephone: json['telephone'],
      averageRating: Decimal.parse(json['averageRating']?.toString() ?? '0'),
      photoUrl: json['photoUrl'],
      longitude: json['longitude'].toString(),
      latitude: json['latitude'].toString(),
      status: json['status'],
      description: json['description']?? ""
    );
  }
}