
class Conversation {
  final String idConversation;
  final String nameReceiver;
  final String lastMessage;
  final DateTime updateAt;

  Conversation({required this.idConversation , required this.nameReceiver , required this.lastMessage , required this.updateAt});

  factory Conversation.fromJson(Map<String , dynamic> json){
    return Conversation(
      idConversation: json["idConversation"],
      nameReceiver: json["nameReceiver"],
      lastMessage: json["lastMessage"],
      updateAt: DateTime.parse(json["updateAt"])
    );
  }
}
