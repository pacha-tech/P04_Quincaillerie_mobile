
class RegisterQuincaillerieDTO {
  final String storeName;
  final String region;
  final String ville;
  final String quartier;
  final String precision;
  final String imageUrl;
  final String description;
  final double latitude;
  final double longitude;
  final String phone;

  RegisterQuincaillerieDTO({required this.storeName , required this.region , required this.ville , required this.quartier , required this.precision , required this.imageUrl , required this.description , required this.latitude , required this.longitude , required this.phone});

  Map<String , dynamic> toJson() => {
    "storeName": storeName,
    "region": region,
    "ville": ville,
    "quartier": quartier,
    "precision": precision,
    "imageUrl": imageUrl,
    "description": description,
    "latitude": latitude,
    "longitude": longitude,
    "phone":phone
  };

}