

class RegisterCustomerDTO {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;
  final String imageUrl;

  RegisterCustomerDTO({required this.email , required this.password , required this.name , required this.phone , required this.role , required this.imageUrl});

  Map<String , dynamic> toJson() => {
    "email": email,
    "password": password,
    "name": name,
    "phone": phone,
    "role": role,
    "imageUrl": imageUrl
  };
}
