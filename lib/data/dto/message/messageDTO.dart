class MessageDTO {
  final String? idConversation;
  final String contenu;
  final String? idReceiver;

  MessageDTO({required this.idConversation, required this.contenu, required this.idReceiver});

  Map<String , dynamic> toJson() => {
    "idConversation": idConversation,
    "contenu": contenu,
    "idReceiver": idReceiver
  };
}
