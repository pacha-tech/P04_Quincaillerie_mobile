
/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../data/modele/Conversation.dart';
import '../../data/modele/Message.dart';
import '../../data/dto/message/messageDTO.dart';
import '../../service/message/MessageService.dart';
import '../../service/message/MessageStomp.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final String? initialMessage;
  const ChatPage({super.key, required this.conversation, this.initialMessage});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _apiService = MessageService();

  bool _isLoadingHistory = true;
  final String myId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();

    MessageStomp().subscribeToConversation(widget.conversation.idConversation, (Message incomingMsg) {
      if (mounted) {
        print(incomingMsg.contenu);
        setState(() {
          _messages.insert(0, incomingMsg);
        });
      }
    });

    if (widget.initialMessage != null) {
      _messageController.text = widget.initialMessage!;
    }
  }

  Future<void> _loadInitialMessages() async {
    try {
      final history = await _apiService.getMessageByConversation(widget.conversation.idConversation);
      if (mounted) {
        setState(() {
          _messages.addAll(history.reversed);
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
      debugPrint("Erreur chargement historique: $e");
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
        idReceiver: null , // Correction vers l'ID du destinataire
    );

    MessageStomp().sendMessage(dto);
    _messageController.clear();
  }

  @override
  void dispose() {
    MessageStomp().unsubscribeFromConversation(widget.conversation.idConversation);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(
                widget.conversation.nameReceiver[0].toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.conversation.nameReceiver,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
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

                // Logique pour afficher le séparateur de date
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
                    if (showDateDivider) _buildDateDivider(_getDateLabel(msg.createdAt!)),
                    _buildBubble(msg, isMe),
                  ],
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
        ],
      ),
    );
  }

  Widget _buildBubble(Message msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(msg.createdAt ?? DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                color: isMe ? Colors.blueAccent : Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.contenu ?? "",
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.estLu ? Icons.done_all : Icons.done,
                          size: 13,
                          color: msg.estLu ? Colors.lightGreenAccent : Colors.white70,
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Garder _buildEmptyChat et _buildInput tels quels)
  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text("Dites bonjour 👋", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Écrire un message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _handleSend,
              child: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../data/modele/Conversation.dart';
import '../../data/modele/Message.dart';
import '../../data/dto/message/messageDTO.dart';
import '../../service/message/MessageService.dart';
import '../../service/message/MessageStomp.dart';
import '../../../ui/theme/AppColors.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final String? initialMessage;

  const ChatPage({
    super.key,
    required this.conversation,
    this.initialMessage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _apiService = MessageService();

  bool _isLoadingHistory = true;
  final String myId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();

    MessageStomp().subscribeToConversation(widget.conversation.idConversation, (Message incomingMsg) {
      if (mounted) {
        setState(() {
          _messages.insert(0, incomingMsg);
          _scrollToBottom();
        });
      }
    });

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
    try {
      final history = await _apiService.getMessageByConversation(widget.conversation.idConversation);
      if (mounted) {
        setState(() {
          _messages.addAll(history.reversed);
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
      debugPrint("Erreur chargement historique: $e");
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
      idReceiver: null,
    );

    MessageStomp().sendMessage(dto);
    _messageController.clear();
  }

  @override
  void dispose() {
    MessageStomp().unsubscribeFromConversation(widget.conversation.idConversation);
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.conversation.nameReceiver.isNotEmpty
                    ? widget.conversation.nameReceiver[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.conversation.nameReceiver,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                  if (_getDateLabel(msg.createdAt!) != _getDateLabel(prevMsg.createdAt!)) {
                    showDateDivider = true;
                  }
                }

                return Column(
                  children: [
                    if (showDateDivider) _buildDateDivider(_getDateLabel(msg.createdAt!)),
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