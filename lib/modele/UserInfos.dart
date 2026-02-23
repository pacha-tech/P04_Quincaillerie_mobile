
class UserInfos {
  final String name;
  final String phone;
  final String photoUrl;
  final String role;

  UserInfos({required this.name , required this.phone , required this.photoUrl , required this.role});

  factory UserInfos.fromJson(Map<String , dynamic> json){
    return UserInfos(
        name: json['name']??"",
        phone: json['phone']??"",
        photoUrl: json['photoUrl']??"",
        role: json['role']
    );
  }
}