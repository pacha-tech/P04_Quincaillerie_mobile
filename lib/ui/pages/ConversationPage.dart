
/*
import 'package:brixel/Exception/UserNotConnectedException.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/modele/Conversation.dart';
import '../../service/message/ConversationService.dart';
import '../../Exception/AppException.dart';
import '../../Exception/NoInternetConnectionException.dart';
import '../widgets/ErrorWidgets.dart';
import 'ChatPage.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ConversationService _conversationService = ConversationService();
  Key _refreshKey = UniqueKey();

  void _handleRetry() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Mes Discussions",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Conversation>>(
        key: _refreshKey,
        future: _conversationService.getAllConversation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            IconData icon = Icons.error_outline_rounded;
            String message = "Une erreur est survenue";

            if (error is NoInternetConnectionException) {
              icon = Icons.wifi_off_rounded;
              message = error.message;
            } else if (error is AppException) {
              message = error.message;
            } else if(error is UserNotConnectedException) {
              message = error.message;
              icon = Icons.no_accounts;
            }

            return ErrorWidgets(
              message: message,
              iconData: icon,
              onRetry: _handleRetry,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final conversations = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _handleRetry(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(indent: 80, height: 1),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage(conversation: conv)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      conv.nameReceiver[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    conv.nameReceiver,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(conv.updateAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: 10,
      separatorBuilder: (context, index) => const Divider(indent: 80, height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
          ),
          title: Container(
            width: 120,
            height: 14,
            margin: const EdgeInsets.only(bottom: 8, right: 100),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
          ),
          subtitle: Container(
            width: double.infinity,
            height: 10,
            margin: const EdgeInsets.only(right: 40),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 100, color: Colors.blueAccent.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text(
            "Aucune conversation",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vos messages s'afficheront ici\ndès que vous aurez commencé à discuter.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
 */

import 'package:brixel/Exception/UserNotConnectedException.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/modele/Conversation.dart';
import '../../service/message/ConversationService.dart';
import '../../Exception/AppException.dart';
import '../../Exception/NoInternetConnectionException.dart';
import '../widgets/ErrorWidgets.dart';
import 'ChatPage.dart';
import '../../../ui/theme/AppColors.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ConversationService _conversationService = ConversationService();
  Key _refreshKey = UniqueKey();

  void _handleRetry() {
    setState(() => _refreshKey = UniqueKey());
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "--:--";
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          "Mes Discussions",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Conversation>>(
        key: _refreshKey,
        future: _conversationService.getAllConversation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonLoader();
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            IconData icon = Icons.error_outline_rounded;
            String message = "Une erreur est survenue";

            if (error is NoInternetConnectionException) {
              icon = Icons.wifi_off_rounded;
              message = error.message;
            } else if (error is AppException) {
              message = error.message;
            } else if (error is UserNotConnectedException) {
              message = error.message;
              icon = Icons.no_accounts_rounded;
            }

            return ErrorWidgets(
              message: message,
              iconData: icon,
              onRetry: _handleRetry,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final conversations = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _handleRetry(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return _buildConversationCard(conversations[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationCard(Conversation conv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    conv.nameReceiver.isNotEmpty ? conv.nameReceiver[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // Textes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.nameReceiver,
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        conv.lastMessage.isNotEmpty ? conv.lastMessage : "Aucun message...",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Heure
                Text(
                  _formatTime(conv.updateAt),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 160, height: 18, color: Colors.grey[200]),
                  const SizedBox(height: 10),
                  Container(width: double.infinity, height: 14, color: Colors.grey[100]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 100, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 24),
          const Text(
            "Aucune discussion",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            "Envoyez un panier à une quincaillerie\npour commencer une discussion",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}