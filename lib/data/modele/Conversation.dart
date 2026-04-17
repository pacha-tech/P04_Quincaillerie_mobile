
class Conversation {
  final String? idConversation;
  final String nameReceiver;
  final String lastMessage;
  String lastMessageSenderId;
  bool lastMessageRead;
  final DateTime updateAt;
  final int unreadCount;


  Conversation({
    required this.idConversation,
    required this.nameReceiver,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageRead,
    required this.updateAt,
    required this.unreadCount
  });

  factory Conversation.fromJson(Map<String , dynamic> json){
    return Conversation(
        idConversation: json["idConversation"],
        nameReceiver: json["nameReceiver"],
        lastMessage: json["lastMessage"],
        lastMessageSenderId: json["lastMessageSenderId"],
        lastMessageRead: json["lastMessageRead"],
        updateAt: DateTime.parse(json["updateAt"]),
        unreadCount: json["unreadCount"] ?? 0
    );
  }


  Conversation copyWith({
    String? idConversation,
    String? nameReceiver,
    String? lastMessage,
    String? lastMessageSenderId,
    bool? lastMessageRead,
    DateTime? updateAt,
    int? unreadCount,
  }) {
    return Conversation(
      idConversation: idConversation ?? this.idConversation,
      nameReceiver: nameReceiver ?? this.nameReceiver,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageRead: lastMessageRead ?? this.lastMessageRead,
      updateAt: updateAt ?? this.updateAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
