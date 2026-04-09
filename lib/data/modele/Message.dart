
class Message {
  final String? idMessage;
  final String? idConversation;
  final String? nomSender;
  final String? idSender;
  final String? idReceiver;
  final String? contenu;
  final bool estLu;
  final DateTime? luAt;
  final DateTime createdAt;

  Message({required this.idMessage , required this.idConversation , required this.nomSender , required this.idSender , required this.idReceiver , required this.contenu , required this.estLu , required this.luAt , required this.createdAt});

  factory Message.fromJson(Map<String , dynamic> json){
    return Message(
      idMessage: json["idMesssage"],
      idConversation: json["idConversation"],
      nomSender: json["nomSender"],
      idSender: json["idSender"],
      idReceiver: json["idReceiver"],
      contenu: json["contenu"],
      estLu: json["estLu"],
      luAt: json["luAt"] != null ? DateTime.parse(json["luAt"]) : null,
      createdAt: DateTime.parse(json["createdAt"])
      //createdAt: DateTime.parse(json["createdAt"])
    );
  }

}