import 'dart:async';
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


  final StreamController<Message> _notificationController = StreamController<Message>.broadcast();
  Stream<Message> get notificationsStream => _notificationController.stream;

  final StreamController<String> _readReceiptsController = StreamController<String>.broadcast();
  Stream<String> get readReceiptsStream => _readReceiptsController.stream;

  final Map<String, dynamic> _activeSubscriptions = {};
  final Map<String, String> _connectHeaders = {};
  Future<String?> Function()? _fetchTokenCallback;


  void init(String userId , Future<String?> Function() fetchTokenCallback ) {
    if (_client != null && _client!.connected) return;

    _fetchTokenCallback = fetchTokenCallback;

    print("Initialisation WebSocket pour userId : $userId");

    _client = StompClient(
      config: StompConfig(
        url: 'ws://192.168.0.109:9010/connexion/websocket',
        //url: 'wss://p04-quincaillerie.onrender.com/connexion/websocket',

        heartbeatOutgoing: const Duration(seconds: 20),
        heartbeatIncoming: const Duration(seconds: 20),

        stompConnectHeaders: _connectHeaders,

        beforeConnect: () async {
          print('Tentative de (re)connexion... Appel du Provider pour le token');
          try {
            if (_fetchTokenCallback != null) {
              String? freshToken = await _fetchTokenCallback!();

              if (freshToken != null) {
                _connectHeaders['Authorization'] = 'Bearer $freshToken';
              }
            }
          } catch (e) {
            print("Erreur lors du callback pour le token : $e");
          }
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
      destination: '/canal/notifications/$userId',
      callback: (frame) {
        if (frame.body != null) {
          print("🔔 Notification reçue en arrière-plan !");

          final dynamic data = json.decode(frame.body!);
          Message nouveauMessage = Message.fromJson(data);

          _notificationController.add(nouveauMessage);
        }
      },
    );

    // 🚀 NOUVEAU : Abonnement pour les CONFIRMATIONS DE LECTURE
    _client!.subscribe(
      // NOTE: Assure-toi que ton Spring Boot envoie bien sur ce canal !
      destination: '/canal/readReceipts/$userId',
      callback: (frame) {
        if (frame.body != null) {
          print("👀 Confirmation de lecture reçue !");

          // Le body doit contenir l'ID de la conversation qui vient d'être lue
          // (Si ton serveur renvoie des guillemets autour de la string comme '"ID_CONV"',
          // pense à utiliser json.decode(frame.body!) au lieu de le prendre brut)
          String idConversationLue = frame.body!.replaceAll('"', '');

          _readReceiptsController.add(idConversationLue);
        }
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