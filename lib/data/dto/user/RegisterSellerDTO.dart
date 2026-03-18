
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
  final String photoUrl;
  final String description;
  final double latitude;
  final double longitude;
  final String nui;
  final bool acceptsTerms;
  final bool wantTips;

  RegisterSellerDTO({required this.password , required this.name , required this.email , required this.phone , required this.role , required this.imageUserUrl , required this.storeName , required this.region , required this.ville , required this.quartier , required this.precision , required this.photoUrl , required this.description , required this.latitude , required this.longitude , required this.nui , required this.acceptsTerms , required this.wantTips});

  Map<String , dynamic> toJson() => {
    "user": {
      "password": password,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "imageUrl": imageUserUrl,
    },
    "quincaillerie": {
      "storeName":storeName,
      "region": region,
      "ville": ville,
      "quartier": quartier,
      "precision": precision,
      "photoUrl": photoUrl,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "phone":phone,
      "nui":nui,
      "acceptTerms":acceptsTerms,
      "wantTips":wantTips
    }
  };
}