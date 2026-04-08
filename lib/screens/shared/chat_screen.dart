import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shared_models.dart';
import '../../navigation/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';

/// Chat Contacts Screen (Message List)
///
/// Features:
/// - List of chat contacts
/// - Unread message count
/// - Online status indicator
/// - Search contacts
class ChatContactsScreen extends StatefulWidget {
  const ChatContactsScreen({super.key});

  @override
  State<ChatContactsScreen> createState() => _ChatContactsScreenState();
}

class _ChatContactsScreenState extends State<ChatContactsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();

  List<ChatContact> _contacts = [];
  String _searchQuery = '';
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_chatSubscription == null) {
      final auth = context.read<AuthProvider>();
      final uid = auth.userId;
      if (uid != null && uid.isNotEmpty) {
        _chatSubscription = FirestoreService.streamUserChats(uid).listen((snapshot) {
          if (!mounted) return;

          final mapped = snapshot.docs
              .map((doc) => _mapChatDocToContact(uid, doc.id, doc.data()))
              .toList();

          setState(() {
            _contacts = mapped;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _pulseController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  ChatContact _mapChatDocToContact(
    String currentUid,
    String chatId,
    Map<String, dynamic> data,
  ) {
    final participantIds = ((data['participantIds'] as List?) ?? const [])
        .whereType<String>()
        .toList();
    final otherUserId = participantIds.firstWhere(
      (id) => id != currentUid,
      orElse: () => currentUid,
    );

    final details = (data['participantDetails'] as Map<String, dynamic>?) ?? {};
    final otherDetails = (details[otherUserId] as Map<String, dynamic>?) ?? {};

    final rawTime = data['lastMessageAt'];
    DateTime? lastTime;
    if (rawTime is Timestamp) {
      lastTime = rawTime.toDate();
    } else if (rawTime is String) {
      lastTime = DateTime.tryParse(rawTime);
    }

    return ChatContact(
      id: otherUserId,
      chatId: chatId,
      name: (otherDetails['name'] as String?) ?? 'TSL User',
      role: (otherDetails['role'] as String?) ?? 'user',
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: lastTime,
      unreadCount: 0,
      isOnline: false,
    );
  }

  List<ChatContact> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.role.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  int get _totalUnread =>
      _contacts.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(innerBoxIsScrolled),
          ];
        },
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContactsList()),
          ],
        ),
      ),
      floatingActionButton: _buildNewChatFab(),
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF00897B),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderContent(),
        title: innerBoxIsScrolled
            ? Text(
                AppLocalizations.of(context).chatTitle,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              )
            : null,
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00897B), Color(0xFF00796B), Color(0xFF004D40)],
        ),
      ),
      child: Stack(
        children: [
          // Chat bubble pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _ChatBubblePatternPainter(),
            ),
          ),
          // Decorative circles
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.chat_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).chatTitle,
                              style: AppTypography.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Row(
                              children: [
                                if (_totalUnread > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .chatNewCount(_totalUnread),
                                      style: AppTypography.caption.copyWith(
                                        color: const Color(0xFF00897B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Text(
                                  AppLocalizations.of(context)
                                      .chatConversationCount(_contacts.length),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.cardWhite,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _searchDebouncer.run(() => setState(() => _searchQuery = value)),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).chatSearchConversations,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    if (_filteredContacts.isEmpty) {
      return Center(
        child: TslEmptyState(
          icon: Icons.chat_bubble_outline,
          title: _searchQuery.isNotEmpty
              ? AppLocalizations.of(context).commonNoResults
              : AppLocalizations.of(context).chatNoConversations,
          message: _searchQuery.isNotEmpty
              ? AppLocalizations.of(context).noMatchSearch
              : AppLocalizations.of(context).startConversation,
          actionText: _searchQuery.isNotEmpty
              ? AppLocalizations.of(context).clearSearch
              : AppLocalizations.of(context).newConversation,
          onAction: _searchQuery.isNotEmpty
              ? () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                }
              : () => _showNewChatSheet(),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: _filteredContacts.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 80,
      ),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return _ContactCard(
          contact: contact,
          pulseAnimation: _pulseController,
          onTap: () => _openChat(contact),
        );
      },
    );
  }

  Widget _buildNewChatFab() {
    return FloatingActionButton(
      onPressed: () => _showNewChatSheet(),
      backgroundColor: const Color(0xFF00897B),
      child: const Icon(Icons.edit_outlined, color: Colors.white),
    );
  }

  void _openChat(ChatContact contact) {
    context.push(AppRoutes.chatWithId(contact.id), extra: contact);
  }

  void _showNewChatSheet() {
    final auth = context.read<AuthProvider>();
    final user = context.read<UserProvider>().currentUser;
    if (auth.userId == null || auth.userRole == null || user == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NewChatSheet(
        currentUserId: auth.userId!,
        currentUserRole: auth.userRole!,
        currentUserName: user.name,
        onContactSelected: (contact) {
          Navigator.pop(context);
          _openChat(contact);
        },
      ),
    );
  }
}

/// Contact card widget
class _ContactCard extends StatelessWidget {
  final ChatContact contact;
  final AnimationController pulseAnimation;
  final VoidCallback onTap;

  const _ContactCard({
    required this.contact,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: AppSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: contact.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (contact.lastMessageTime != null)
                          Text(
                            _formatTime(contact.lastMessageTime!),
                            style: AppTypography.caption.copyWith(
                              color: contact.unreadCount > 0
                                  ? const Color(0xFF00897B)
                                  : AppColors.textSecondary,
                              fontWeight: contact.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(contact.role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            contact.role,
                            style: AppTypography.caption.copyWith(
                              color: _getRoleColor(contact.role),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.lastMessage ?? AppLocalizations.of(context).noMessages,
                            style: AppTypography.bodySmall.copyWith(
                              color: contact.unreadCount > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: contact.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.unreadCount > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${contact.unreadCount}',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getRoleColor(contact.role),
                _getRoleColor(contact.role).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getRoleColor(contact.role).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              contact.name[0].toUpperCase(),
              style: AppTypography.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (contact.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                final scale = 1.0 + math.sin(pulseAnimation.value * math.pi * 2) * 0.15;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'dealer':
        return const Color(0xFF2E7D32);
      case 'mistri':
        return const Color(0xFF388E3C);
      case 'architect':
        return const Color(0xFF1B5E20);
      case 'support':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

/// New chat sheet
class _NewChatSheet extends StatelessWidget {
  final String currentUserId;
  final UserRole currentUserRole;
  final String currentUserName;
  final void Function(ChatContact) onContactSelected;

  const _NewChatSheet({
    required this.currentUserId,
    required this.currentUserRole,
    required this.currentUserName,
    required this.onContactSelected,
  });

  @override
  Widget build(BuildContext context) {
    final query = switch (currentUserRole) {
      UserRole.mistri => FirestoreService.dealersCollection.limit(30),
      UserRole.dealer => FirestoreService.mistrisCollection.limit(30),
      UserRole.architect => FirestoreService.dealersCollection.limit(30),
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(AppLocalizations.of(context).newConversation, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xl),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs
                  .where((doc) => doc.id != currentUserId)
                  .toList();

              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    AppLocalizations.of(context).commonNoResults,
                    style: AppTypography.bodyMedium,
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final contactName = (data['name'] as String?) ?? 'TSL User';
                  final contactRole = (data['role'] as String?) ?? _defaultRoleLabel(currentUserRole);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00897B),
                      child: Text(
                        contactName.isNotEmpty ? contactName[0] : 'T',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(contactName),
                    subtitle: Text(contactRole),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final chatId = await FirestoreService.createOrGetDirectChat(
                        userId: currentUserId,
                        userName: currentUserName,
                        userRole: currentUserRole.key,
                        otherUserId: doc.id,
                        otherUserName: contactName,
                        otherUserRole: contactRole,
                      );

                      onContactSelected(
                        ChatContact(
                          id: doc.id,
                          chatId: chatId,
                          name: contactName,
                          role: contactRole,
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _defaultRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.mistri:
        return 'dealer';
      case UserRole.dealer:
        return 'mistri';
      case UserRole.architect:
        return 'dealer';
    }
  }
}

/// Chat bubble pattern painter
class _ChatBubblePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw chat bubbles pattern
    final bubblePositions = [
      const Offset(50, 30),
      const Offset(200, 60),
      const Offset(120, 100),
      const Offset(280, 40),
      const Offset(30, 120),
    ];

    for (final pos in bubblePositions) {
      _drawChatBubble(canvas, pos, paint, 20 + math.Random(pos.dx.toInt()).nextDouble() * 15);
    }
  }

  void _drawChatBubble(Canvas canvas, Offset position, Paint paint, double size) {
    final path = Path();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: position, width: size * 1.5, height: size),
      Radius.circular(size / 3),
    );
    path.addRRect(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===================================
// CHAT SCREEN
// ===================================

/// Chat Screen (Individual Conversation)
///
/// Features:
/// - Message list with timestamps
/// - Text input with send button
/// - Photo sharing capability
/// - Typing indicator
class ChatScreen extends StatefulWidget {
  final ChatContact contact;

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _typingController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messageSubscription;

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    final chatId = widget.contact.chatId;
    if (chatId != null && chatId.isNotEmpty) {
      _messageSubscription = FirestoreService.streamChatMessages(chatId).listen((snapshot) {
        if (!mounted) return;

        final myId = context.read<AuthProvider>().userId;
        final mapped = snapshot.docs.map((doc) {
          final data = doc.data();
          final senderId = (data['senderId'] as String?) ?? '';
          final rawType = (data['type'] as String?) ?? 'text';
          final rawTime = data['timestamp'];

          DateTime ts = DateTime.now();
          if (rawTime is Timestamp) {
            ts = rawTime.toDate();
          }

          return ChatMessage(
            id: doc.id,
            senderId: senderId,
            sender: senderId == myId ? MessageSender.me : MessageSender.other,
            type: rawType == 'image' ? MessageType.image : MessageType.text,
            content: (data['content'] as String?) ?? '',
            timestamp: ts,
            isRead: (data['isRead'] as bool?) ?? false,
          );
        }).toList();

        setState(() {
          _messages = mapped;
        });

        _scrollToBottom();
      });
    }

    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatId = widget.contact.chatId;
    final auth = context.read<AuthProvider>();
    final user = context.read<UserProvider>().currentUser;
    final content = _messageController.text.trim();

    if (chatId == null || auth.userId == null || user == null) return;

    _messageController.clear();

    await FirestoreService.sendChatMessage(
      chatId: chatId,
      senderId: auth.userId!,
      senderName: user.name,
      senderRole: user.role.key,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          if (_isTyping) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF00897B),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  widget.contact.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.contact.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00897B), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
                Text(
                  widget.contact.isOnline ? 'Online' : widget.contact.role,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showOptionsSheet(),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showDate = index == 0 ||
            !_isSameDay(_messages[index - 1].timestamp, message.timestamp);

        return Column(
          children: [
            if (showDate) _buildDateSeparator(message.timestamp),
            _MessageBubble(message: message),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: AppColors.divider),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                _formatDate(date),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.divider),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: AppShadows.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
                    final offset = math.sin(
                      (_typingController.value * 2 * math.pi) + (index * 0.5),
                    ) * 4;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.translate(
                        offset: Offset(0, offset),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${widget.contact.name.split(' ')[0]} is typing...',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
                onPressed: () => _showAttachmentOptions(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Send button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00897B), Color(0xFF00796B)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00897B).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  void _showOptionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('Mute Notifications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search in Chat'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Chat',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send Attachment', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.camera_alt,
                  'Camera',
                  const Color(0xFF388E3C),
                ),
                _buildAttachmentOption(
                  Icons.photo,
                  'Gallery',
                  const Color(0xFF9C27B0),
                ),
                _buildAttachmentOption(
                  Icons.location_on,
                  'Location',
                  const Color(0xFF4CAF50),
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file,
                  'Document',
                  const Color(0xFF2196F3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  bool get _isMe => message.sender == MessageSender.me;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
          left: _isMe ? 48 : 0,
          right: _isMe ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment:
              _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: _isMe
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00897B), Color(0xFF00796B)],
                      )
                    : null,
                color: _isMe ? null : AppColors.cardWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(_isMe ? 20 : 4),
                  bottomRight: Radius.circular(_isMe ? 4 : 20),
                ),
                boxShadow: AppShadows.xs,
              ),
              child: message.type == MessageType.image
                  ? _buildImageMessage()
                  : _buildTextMessage(),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                if (_isMe) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? const Color(0xFF00897B)
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage() {
    return Text(
      message.content,
      style: AppTypography.bodyMedium.copyWith(
        color: _isMe ? Colors.white : AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message.content,
            style: AppTypography.bodySmall.copyWith(
              color: _isMe ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $ampm';
  }
}

