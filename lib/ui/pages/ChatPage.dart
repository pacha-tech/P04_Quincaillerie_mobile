
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/modele/Conversation.dart';
import '../../data/modele/Message.dart';
import '../../data/dto/message/messageDTO.dart';
import '../../provider/UserProvider.dart';
import '../../service/message/MessageService.dart';
import '../../service/message/MessageStomp.dart';
import '../../../ui/theme/AppColors.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final String? initialMessage;
  final String? idQuincaillerie;

  const ChatPage({
    super.key,
    required this.conversation,
    this.initialMessage,
    this.idQuincaillerie,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();


  StreamSubscription<String>? _readReceiptSubscription;

  bool _isLoadingHistory = true;

  String get myId => context.read<UserProvider>().myId;

  @override
  void initState() {
    super.initState();

    if (widget.conversation.idConversation != null && widget.conversation.idConversation!.isNotEmpty) {
      _loadInitialMessages();

      MessageStomp().subscribeToConversation(widget.conversation.idConversation!, (Message incomingMsg) {
        if (mounted) {
          setState(() {
            _messages.insert(0, incomingMsg);
            _scrollToBottom();
          });

          if (incomingMsg.idSender != myId && !incomingMsg.estLu) {
            _messageService.markRead([incomingMsg.idMessage!]);
          }
        }
      });


      _readReceiptSubscription = MessageStomp().readReceiptsStream.listen((String idConvLue) {

        if (idConvLue == widget.conversation.idConversation) {
          if (mounted) {
            setState(() {

              for (var msg in _messages) {
                if (msg.idSender == myId && !msg.estLu) {
                  msg.estLu = true;
                }
              }
            });
          }
        }
      });

    } else {
      _isLoadingHistory = false;
    }

    if (widget.initialMessage != null) {
      _messageController.text = widget.initialMessage!;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadInitialMessages() async {
    if (widget.conversation.idConversation == null || widget.conversation.idConversation!.isEmpty) return;

    try {
      final history = await _messageService.getMessageByConversation(widget.conversation.idConversation!);
      if (mounted) {
        setState(() {
          _messages.addAll(history.reversed);
          _isLoadingHistory = false;
        });
        _scrollToBottom();
        _readConfirmation();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
      debugPrint("Erreur chargement historique: $e");
    }
  }

  Future<void> _readConfirmation() async {
    List<String> idMessageNonLues = [];

    for(var mess in _messages){
      if(!mess.estLu){
        if(mess.idMessage != null && mess.idMessage!.isNotEmpty){
          idMessageNonLues.add(mess.idMessage!);
        }
      }
    }

    if(idMessageNonLues.isNotEmpty){
      await _messageService.markRead(idMessageNonLues);
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) return "Aujourd'hui";
    if (dateToCheck == yesterday) return "Hier";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final dto = MessageDTO(
      idConversation: widget.conversation.idConversation,
      contenu: text,
      idReceiver: widget.idQuincaillerie,
    );

    MessageStomp().sendMessage(dto);
    _messageController.clear();
  }

  @override
  void dispose() {
    _readReceiptSubscription?.cancel();

    if (widget.conversation.idConversation != null && widget.conversation.idConversation!.isNotEmpty) {
      MessageStomp().unsubscribeFromConversation(widget.conversation.idConversation!);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.conversation.nameReceiver,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg.idSender == myId;

                bool showDateDivider = false;
                if (index == _messages.length - 1) {
                  showDateDivider = true;
                } else {
                  final prevMsg = _messages[index + 1];
                  if (_getDateLabel(msg.createdAt) != _getDateLabel(prevMsg.createdAt)) {
                    showDateDivider = true;
                  }
                }

                return Column(
                  children: [
                    if (showDateDivider) _buildDateDivider(_getDateLabel(msg.createdAt)),
                    _buildBubble(msg, isMe),
                  ],
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.grey, thickness: 0.6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.grey, thickness: 0.6)),
        ],
      ),
    );
  }

  Widget _buildBubble(Message msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(msg.createdAt ?? DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.cardBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.contenu ?? "",
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 15.2,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isMe ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 5),
                    Icon(
                      msg.estLu ? Icons.done_all : Icons.done,
                      size: 14,
                      color: msg.estLu ? AppColors.priceGreen : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 68,
            color: AppColors.primary.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            "Commencez la discussion",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Envoyez un message pour discuter avec le quincaillier",
            style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Écrire un message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.5),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/modele/Conversation.dart';
import '../../data/modele/Message.dart';
import '../../data/dto/message/messageDTO.dart';
import '../../provider/UserProvider.dart';
import '../../service/message/MessageService.dart';
import '../../service/message/MessageStomp.dart';
import '../../../ui/theme/AppColors.dart';
import '../widgets/SkeletonPulsar.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final String? initialMessage;
  final String? idQuincaillerie;

  const ChatPage({
    super.key,
    required this.conversation,
    this.initialMessage,
    this.idQuincaillerie,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  StreamSubscription<String>? _readReceiptSubscription;

  bool _isLoadingHistory = true;

  String get myId => context.read<UserProvider>().myId;

  @override
  void initState() {
    super.initState();

    if (widget.conversation.idConversation != null && widget.conversation.idConversation!.isNotEmpty) {
      _loadInitialMessages();

      MessageStomp().subscribeToConversation(widget.conversation.idConversation!, (Message incomingMsg) {
        if (mounted) {
          setState(() {
            _messages.insert(0, incomingMsg);
            _scrollToBottom();
          });

          if (incomingMsg.idSender != myId && !incomingMsg.estLu) {
            _messageService.markRead([incomingMsg.idMessage!]);
          }
        }
      });

      _readReceiptSubscription = MessageStomp().readReceiptsStream.listen((String idConvLue) {
        if (idConvLue == widget.conversation.idConversation) {
          if (mounted) {
            setState(() {
              for (var msg in _messages) {
                if (msg.idSender == myId && !msg.estLu) {
                  msg.estLu = true;
                }
              }
            });
          }
        }
      });

    } else {
      _isLoadingHistory = false;
    }

    if (widget.initialMessage != null) {
      _messageController.text = widget.initialMessage!;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadInitialMessages() async {
    if (widget.conversation.idConversation == null || widget.conversation.idConversation!.isEmpty) return;

    try {
      final history = await _messageService.getMessageByConversation(widget.conversation.idConversation!);
      if (mounted) {
        setState(() {
          _messages.addAll(history.reversed);
          _isLoadingHistory = false;
        });
        _scrollToBottom();
        _readConfirmation();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
      debugPrint("Erreur chargement historique: $e");
    }
  }

  Future<void> _readConfirmation() async {
    List<String> idMessageNonLues = [];

    for(var mess in _messages){
      if(!mess.estLu){
        if(mess.idMessage != null && mess.idMessage!.isNotEmpty){
          idMessageNonLues.add(mess.idMessage!);
        }
      }
    }

    if(idMessageNonLues.isNotEmpty){
      await _messageService.markRead(idMessageNonLues);
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) return "Aujourd'hui";
    if (dateToCheck == yesterday) return "Hier";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final dto = MessageDTO(
      idConversation: widget.conversation.idConversation,
      contenu: text,
      idReceiver: widget.idQuincaillerie,
    );

    MessageStomp().sendMessage(dto);
    _messageController.clear();
  }

  @override
  void dispose() {
    _readReceiptSubscription?.cancel();

    if (widget.conversation.idConversation != null && widget.conversation.idConversation!.isNotEmpty) {
      MessageStomp().unsubscribeFromConversation(widget.conversation.idConversation!);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.conversation.nameReceiver,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? _buildSkeletonChat()
                : _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg.idSender == myId;

                bool showDateDivider = false;
                if (index == _messages.length - 1) {
                  showDateDivider = true;
                } else {
                  final prevMsg = _messages[index + 1];
                  if (_getDateLabel(msg.createdAt) != _getDateLabel(prevMsg.createdAt)) {
                    showDateDivider = true;
                  }
                }

                return Column(
                  children: [
                    if (showDateDivider) _buildDateDivider(_getDateLabel(msg.createdAt)),
                    _buildBubble(msg, isMe),
                  ],
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  // ── SKELETON CHAT ────────────────────────────────────────────────────────
  Widget _buildSkeletonChat() {
    // Une fausse liste de messages pour simuler une conversation réaliste
    // isMe détermine le côté, widthFactor simule la longueur du texte
    final mockMessages = [
      {'isMe': true, 'width': 0.6},
      {'isMe': false, 'width': 0.4},
      {'isMe': false, 'width': 0.7},
      {'isMe': true, 'width': 0.3},
      {'isMe': false, 'width': 0.5},
    ];

    return SkeletonPulsar(
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: mockMessages.length,
        itemBuilder: (context, index) {
          final msg = mockMessages[index];
          return _buildSkeletonBubble(msg['isMe'] as bool, msg['width'] as double);
        },
      ),
    );
  }

  Widget _buildSkeletonBubble(bool isMe, double widthFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width * widthFactor,
          height: 45, // Hauteur moyenne d'une ligne de texte + padding
          decoration: BoxDecoration(
            // Squelette plus clair pour tes messages, gris pour les reçus
            color: isMe ? AppColors.primary.withOpacity(0.15) : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── COMPOSANTS ORIGINAUX ──────────────────────────────────────────────────
  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.grey, thickness: 0.6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.grey, thickness: 0.6)),
        ],
      ),
    );
  }

  Widget _buildBubble(Message msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(msg.createdAt ?? DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.cardBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.contenu ?? "",
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 15.2,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isMe ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 5),
                    Icon(
                      msg.estLu ? Icons.done_all : Icons.done,
                      size: 14,
                      color: msg.estLu ? AppColors.priceGreen : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 68,
            color: AppColors.primary.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            "Commencez la discussion",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Envoyez un message pour discuter avec le quincaillier",
            style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Écrire un message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.5),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
