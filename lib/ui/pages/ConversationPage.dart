
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Exception/AppException.dart';
import '../../Exception/NoInternetConnectionException.dart';
import '../../Exception/UserNotConnectedException.dart';
import '../../data/modele/Conversation.dart';
import '../../main.dart';
import '../../provider/ConversationProvider.dart';
import '../../provider/UserProvider.dart'; // N'oublie pas cet import !
import '../widgets/ErrorWidgets.dart';
import 'ChatPage.dart';
import '../../../ui/theme/AppColors.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> with RouteAware{

    @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) {

        final myId = Provider.of<UserProvider>(context, listen: false).myId;
        final provider = Provider.of<ConversationProvider>(context, listen: false);

        provider.fetchConversations();
        provider.initNotifications(myId);
      });
    }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null) routeObserver.subscribe(this, modalRoute);
    }

    @override
    void didPopNext() {
      setState((){
        WidgetsBinding.instance.addPostFrameCallback((_) {

          final myId = Provider.of<UserProvider>(context, listen: false).myId;
          final provider = Provider.of<ConversationProvider>(context, listen: false);

          provider.fetchConversations();
          provider.initNotifications(myId);
        });
      });
    }

    @override
    void dispose() {
      routeObserver.unsubscribe(this);
      super.dispose();
    }

    String _formatTime(DateTime? date) {
      if (date == null) return "--:--";
      return DateFormat('HH:mm').format(date);
    }

    @override
    Widget build(BuildContext context) {

      final myId = context.read<UserProvider>().myId;

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
        body: Consumer<ConversationProvider>(
          builder: (context, provider, child) {

            if (provider.isLoading && provider.conversations.isEmpty) {
              return _buildSkeletonLoader();
            }

            if (provider.error != null && provider.conversations.isEmpty) {
              final error = provider.error;
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
                onRetry: () => provider.fetchConversations(),
              );
            }

            if (provider.conversations.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchConversations(),
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: provider.conversations.length,
                itemBuilder: (context, index) {
                  // On passe myId à la méthode qui construit la carte
                  return _buildConversationCard(provider.conversations[index], myId);
                },
              ),
            );
          },
        ),
      );
    }

    Widget _buildConversationCard(Conversation conv, String myId) {
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)),
              );
            },
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

                        Row(
                          children: [
                            if (conv.lastMessageSenderId == myId) ...[
                              const SizedBox(width: 4),
                              Icon(
                                conv.lastMessageRead ? Icons.done_all : Icons.done,
                                size: 16,
                                color: conv.lastMessageRead ? Colors.blue : Colors.grey.shade400,
                              ),
                            ],
                            SizedBox(width: 10),

                            if (conv.lastMessageSenderId == myId)
                              const Text(
                                "Vous: ",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),

                            Expanded(
                              child: Text(
                                conv.lastMessage.isNotEmpty ? conv.lastMessage : "Aucun message...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: conv.unreadCount > 0 ? Colors.black87 : AppColors.textMuted,
                                  fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(conv.updateAt),
                        style: TextStyle(
                          fontSize: 13.5,
                          color: conv.unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                          fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (conv.unreadCount > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conv.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
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