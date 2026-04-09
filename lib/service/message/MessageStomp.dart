import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../data/modele/Message.dart';
import 'package:brixel/data/dto/message/messageDTO.dart';

class MessageStomp {

  static final MessageStomp _instance = MessageStomp._internal();

  factory MessageStomp() {
    return _instance;
  }

  MessageStomp._internal();

  StompClient? _client;


  final Map<String, dynamic> _activeSubscriptions = {};


  void init(String userId , String token) {
    if (_client != null && _client!.connected) return;

    print("userId : $userId token : $token");

    _client = StompClient(
      config: StompConfig(
        url: 'ws://192.168.0.109:9010/connexion/websocket',
        //+***url: 'wss://p04-quincaillerie.onrender.com/connexion/websocket',

        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onConnect: (frame) {
          print('Connecté avec le token');

          _subscribeToPrivateChannel(userId);
        },

        reconnectDelay: const Duration(seconds: 5),
        onWebSocketError: (e) => print('Erreur WebSocket: $e'),
        onStompError: (frame) => print('Erreur STOMP: ${frame.body}'),
        onDisconnect: (frame) => print('Déconnecté du WebSocket'),
      ),
    );

    _client!.activate();
  }


  void subscribeToConversation(String convId, Function(Message) onMessageReceived) {
    if (_client == null || !_client!.connected) {
      print("Erreur: Client non connecté. Impossible de s'abonner.");
      return;
    }


    if (_activeSubscriptions.containsKey(convId)) return;

    final unsubscribeFn = _client!.subscribe(
      destination: '/canal/conversation/$convId',
      callback: (frame) {
        if (frame.body != null) {
          //final Map<String, dynamic> msgJson = json.decode(frame.body!);
          //onMessageReceived(Message.fromJson(msgJson));

          final dynamic data = json.decode(frame.body!);

          print("Données reçues sur le socket : $data");

          if (data is List) {
            for (var item in data) {
              onMessageReceived(Message.fromJson(item));
            }
          } else {
            onMessageReceived(Message.fromJson(data));
          }
        }
      },
    );

    _activeSubscriptions[convId] = unsubscribeFn;
    print("Abonné à la conversation: $convId");
  }


  void _subscribeToPrivateChannel(String userId) {
    _client!.subscribe(
      destination: '/user/prive/messages/$userId',
      callback: (frame) {
        print("Message privé/notification reçu en arrière-plan");
        // Optionnel : Ajouter une logique de notification locale ici
      },
    );
  }


  void sendMessage(MessageDTO message) {
    if (isConnected) {
      _client!.send(
        destination: '/envoyer/chat',
        body: json.encode(message.toJson()),
      );
      print(message.toJson());
    } else {
      print("Impossible d'envoyer le message : client non connecté.");
    }
  }


  void unsubscribeFromConversation(String convId) {
    if (_activeSubscriptions.containsKey(convId)) {
      _activeSubscriptions[convId]();
      _activeSubscriptions.remove(convId);
      print("Désabonné de: $convId");
    }
  }


  void disconnect() {
    _activeSubscriptions.forEach((key, unsubscribe) => unsubscribe());
    _activeSubscriptions.clear();
    _client?.deactivate();
    _client = null;
    print("Service MessageStomp déconnecté proprement.");
  }

  bool get isConnected => _client?.connected ?? false;
}