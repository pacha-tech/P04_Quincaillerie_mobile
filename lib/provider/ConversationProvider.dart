
/*
import 'dart:async';
import 'package:flutter/material.dart';
import '../../service/message/ConversationService.dart';
import '../data/modele/Conversation.dart';
import '../data/modele/Message.dart';
import '../service/message/MessageStomp.dart';

class ConversationProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  StreamSubscription? _subscription;
  final ConversationService _conversationService = ConversationService();

  // États pour l'interface
  bool _isLoading = false;
  Object? _error; // Pour stocker les exceptions (NoInternet, UserNotConnected, etc.)

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  // 1. Méthode pour charger la liste initiale
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationService.getAllConversation();
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Méthode pour écouter les messages en temps réel
  void initNotifications() {
    print("🎧 DÉBUT DE L'ÉCOUTE DES MESSAGES...");
    _subscription?.cancel();

    _subscription = MessageStomp().notificationsStream.listen((Message newMessage) async {
      print("📩 NOUVEAU MESSAGE REÇU EN DIRECT : ${newMessage.contenu}");
      int index = _conversations.indexWhere((c) => c.idConversation == newMessage.idConversation);

      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          lastMessage: newMessage.contenu,
          updateAt: newMessage.createdAt,
          unreadCount: _conversations[index].unreadCount + 1,
        );
        final convToMove = _conversations.removeAt(index);
        _conversations.insert(0, convToMove);
      } else {
        // Nouvelle discussion, on recharge tout silencieusement
        try {
          _conversations = await _conversationService.getAllConversation();
        } catch (e) {
          print("Erreur rechargement: $e");
        }
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
 */


import 'dart:async';
import 'package:flutter/material.dart';
import '../../service/message/ConversationService.dart';
import '../data/modele/Conversation.dart';
import '../data/modele/Message.dart';
import '../service/message/MessageStomp.dart';

class ConversationProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  StreamSubscription? _subscription;
  StreamSubscription? _readReceiptSubscription;
  final ConversationService _conversationService = ConversationService();

  // États pour l'interface
  bool _isLoading = false;
  Object? _error; // Pour stocker les exceptions (NoInternet, UserNotConnected, etc.)

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  // 1. Méthode pour charger la liste initiale
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationService.getAllConversation();
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Méthode pour écouter les messages et les lectures en temps réel
  void initNotifications(String myId) {
    print("🎧 DÉBUT DE L'ÉCOUTE DES MESSAGES...");
    _subscription?.cancel();
    _readReceiptSubscription?.cancel();

    // ÉCOUTE DES NOUVEAUX MESSAGES
    _subscription = MessageStomp().notificationsStream.listen((Message newMessage) async {
      print("📩 NOUVEAU MESSAGE REÇU EN DIRECT : ${newMessage.contenu}");
      int index = _conversations.indexWhere((c) => c.idConversation == newMessage.idConversation);

      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(
          lastMessage: newMessage.contenu,
          lastMessageSenderId: newMessage.idSender, // On met à jour l'expéditeur
          lastMessageRead: newMessage.estLu,        // On met à jour le statut de lecture
          updateAt: newMessage.createdAt,
          // On incrémente le badge SEULEMENT si le message ne vient pas de moi
          unreadCount: (newMessage.idSender == myId)
              ? _conversations[index].unreadCount
              : _conversations[index].unreadCount + 1,
        );
        // On remonte la conversation en haut de la liste
        final convToMove = _conversations.removeAt(index);
        _conversations.insert(0, convToMove);
      } else {
        // Nouvelle discussion, on recharge tout silencieusement
        try {
          _conversations = await _conversationService.getAllConversation();
        } catch (e) {
          print("Erreur rechargement: $e");
        }
      }
      notifyListeners();
    });

    // ÉCOUTE DES CONFIRMATIONS DE LECTURE (Passage de V à VV)
    // Assure-toi que MessageStomp expose bien un readReceiptsStream
    if (MessageStomp().readReceiptsStream != null) {
      _readReceiptSubscription = MessageStomp().readReceiptsStream!.listen((String idConversationLue) {
        int index = _conversations.indexWhere((c) => c.idConversation == idConversationLue);

        if (index != -1) {
          // L'autre personne a lu la conversation, on passe les coches en bleu (true)
          _conversations[index] = _conversations[index].copyWith(
            lastMessageRead: true,
          );
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _readReceiptSubscription?.cancel();
    super.dispose();
  }
}