
class RegisterSellerDTO {
  final String password;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String imageUserUrl;
  final String storeName;
  final String region;
  final String ville;
  final String quartier;
  final String precision;
  final String photoStoreUrl;
  final String description;
  final double latitude;
  final double longitude;

  RegisterSellerDTO({required this.password , required this.name , required this.email , required this.phone , required this.role , required this.imageUserUrl , required this.storeName , required this.region , required this.ville , required this.quartier , required this.precision , required this.photoStoreUrl , required this.description , required this.latitude , required this.longitude});

  Map<String , dynamic> toJson() => {
    "password": password,
    "name": name,
    "email": email,
    "phone": phone,
    "role": role,
    "imageUserUrl": imageUserUrl,
    "storeName": storeName,
    "region": region,
    "ville": ville,
    "quartier": quartier,
    "precision": precision,
    "photoStoreUrl": photoStoreUrl,
    "description": description,
    "latitude": latitude,
    "longitude": longitude
  };
}