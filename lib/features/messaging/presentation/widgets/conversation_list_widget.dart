import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../auth/services/auth_service.dart';
import 'package:mycampus/features/messaging/domain/models/message_model.dart';
import 'package:mycampus/features/messaging/services/notification_service.dart';
import 'package:mycampus/features/messaging/data/repositories/messaging_repository_impl.dart';
import 'package:mycampus/features/messaging/data/datasources/messaging_remote_datasource.dart';
import '../../../../constants/app_colors.dart';

class ConversationListWidget extends StatefulWidget {
  final String? searchQuery;
  final Function(String userId, String userName, String? userAvatar)?
      onConversationTap;
  final Function(ConversationModel conversation)? onConversationSelected;
  final String? selectedConversationId;

  const ConversationListWidget({
    super.key,
    this.searchQuery,
    this.onConversationTap,
    this.onConversationSelected,
    this.selectedConversationId,
  });

  @override
  State<ConversationListWidget> createState() =>
      _ConversationListWidgetState();
}

class _ConversationListWidgetState extends State<ConversationListWidget>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<ConversationModel> _conversations = [];
  List<ConversationModel> _filteredConversations = [];
  
  String? _selectedConversationId;
  bool _isSearching = false;
  Timer? _debounceTimer;
  Timer? _refreshTimer;
  bool _isNavigating = false;
  
  late AnimationController _fadeAnimationController;
  late AnimationController _notificationAnimationController;
  
  Map<String, int> _conversationUnreadCounts = {};
  Map<String, Color> _conversationNotificationColors = {};
  StreamSubscription<Map<String, int>>? _notificationSubscription;
  
  late MessagingRepositoryImpl _messagingRepository;
  bool _repositoryInitialized = false;
  AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _initializeAnimations();
    _initializeNotifications();
    _startAutoRefresh();
    _loadConversations();
  }

  Future<void> _initializeRepository() async {
    final authUser = await _authService.getCurrentUser();
    final currentUserId = authUser?.id?.toString() ?? '1';
    _messagingRepository = MessagingRepositoryImpl(
      remoteDataSource: MessagingRemoteDataSourceImpl(
        client: http.Client(),
        baseUrl: 'http://127.0.0.1/mycampus',
      ),
      currentUserId: currentUserId,
    );
    _repositoryInitialized = true;
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _notificationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimationController.forward();
  }

  void _initializeNotifications() async {
    final authUser = await _authService.getCurrentUser();
    if (authUser?.id != null) {
      final notificationService = NotificationService(userId: authUser!.id.toString());
      notificationService.initialize();
      
      _notificationSubscription = notificationService
          .conversationNotificationsStream
          .listen((notificationCounts) {
        if (mounted) {
          setState(() {
            _conversationUnreadCounts = notificationCounts;
            _generateNotificationColors();
          });
        }
      });
    }
  }

  void _generateNotificationColors() {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.secondary,
      Colors.purple,
      AppColors.error,
      Colors.teal,
      Colors.indigo,
    ];
    
    _conversationNotificationColors.clear();
    var colorIndex = 0;
    
    for (final conversationId in _conversationUnreadCounts.keys) {
      _conversationNotificationColors[conversationId] = colors[colorIndex % colors.length];
      colorIndex++;
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        _loadConversations();
      }
    });
  }

  Future<void> _loadConversations() async {
    try {
      // S'assurer que le repository est initialisé
      if (!_repositoryInitialized) {
        await _initializeRepository();
      }
      
      final authUser = await _authService.getCurrentUser();
      final userId = authUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // print('Loading conversations for user ID: $userId (type: ${userId.runtimeType})');

      // Utiliser le repository au lieu de l'appel HTTP direct
      final result = await _messagingRepository.getConversations();
      
      result.fold(
        (error) {
          // print('Error loading conversations: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _conversations = [];
            });
            // _showErrorSnackBar('Erreur chargement conversations: $error');
          }
        },
        (conversations) {
          // print('Loaded ${conversations.length} conversations from repository');
          
          // Filtrer les conversations pour exclure l'utilisateur courant
          final filteredConversations = conversations
              .where((conv) => conv.participantId != userId.toString())
              .toList();
          // print('Filtered to ${filteredConversations.length} conversations');

          if (mounted) {
            setState(() {
              _conversations = filteredConversations;
              _filteredConversations = filteredConversations;
              _isLoading = false;
            });
            _applyFilter();
          }
        },
      );
    } catch (e) {
      // print('Exception chargement conversations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _conversations = [];
        });
        // _showErrorSnackBar('Erreur chargement conversations');
      }
    }
  }

  void _applyFilter() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      _filteredConversations = _conversations;
    } else {
      final query = widget.searchQuery!.toLowerCase();
      _filteredConversations = _conversations.where((conversation) {
        return conversation.participantName.toLowerCase().contains(query) ||
            (conversation.participantAvatar != null &&
                conversation.participantAvatar!.toLowerCase().contains(query));
      }).toList();
    }
  }

  void _handleSearchChange(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isSearching = query.isNotEmpty;
          _applyFilter();
        });
      }
    });
  }

  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _refreshTimer?.cancel();
    _fadeAnimationController.dispose();
    _notificationAnimationController.dispose();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConversationListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _handleSearchChange(widget.searchQuery ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF075E54)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement conversations...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredConversations.isEmpty && _isSearching) {
      return _buildNoResultsState();
    }

    return FadeTransition(
      opacity: _fadeAnimationController.view,
      child: ListView.separated(
        itemCount: _filteredConversations.length,
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        itemBuilder: (context, index) {
          final conversation = _filteredConversations[index];
          final isSelected = widget.selectedConversationId == conversation.participantId;

          return AnimatedBuilder(
            animation: _fadeAnimationController.view,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                (1 - _fadeAnimationController.value) * 50,
                0,
              ),
              child: Opacity(
                opacity: _fadeAnimationController.value,
                child: _buildConversationTile(conversation, isSelected),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Icon(
              Icons.message_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez une nouvelle conversation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _loadConversations();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075E54),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec d\'autres termes',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conversation, bool isSelected) {
    final unreadCount = _conversationUnreadCounts[conversation.participantId] ?? conversation.unreadCount;
    final notificationColor = _conversationNotificationColors[conversation.participantId];
    final hasNewNotification = unreadCount > 0 && notificationColor != null;
    
    return Material(
      color: isSelected ? const Color(0xFF128C7E).withOpacity(0.1) : (hasNewNotification ? notificationColor!.withOpacity(0.05) : const Color(0xFFECE5DD)),
      child: InkWell(
        onTap: () async {
          if (_isNavigating) return;
          
          // Marquer la conversation comme lue
          if (unreadCount > 0) {
            final authUser = await _authService.getCurrentUser();
            if (authUser?.id != null) {
              final notificationService = NotificationService(userId: authUser!.id.toString());
              notificationService.markConversationAsRead(conversation.participantId);
            }
          }
          
          setState(() {
            _selectedConversationId = conversation.id;
            _isNavigating = true;
          });

          if (widget.onConversationTap != null) {
            widget.onConversationTap!(
              conversation.participantId,
              conversation.participantName,
              conversation.participantAvatar,
            );
          }
          
          if (widget.onConversationSelected != null) {
            widget.onConversationSelected!(conversation);
          }
          
          // Reset navigation flag after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isNavigating = false;
              });
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: hasNewNotification 
                ? Border(left: BorderSide(color: notificationColor!, width: 4))
                : null,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFECE5DD),
                    backgroundImage: conversation.participantAvatar != null
                        ? NetworkImage(conversation.participantAvatar!)
                        : null,
                    child: conversation.participantAvatar == null
                        ? Text(
                            _getInitials(conversation.participantName),
                            style: const TextStyle(
                              color: Color(0xFF075E54),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  if (hasNewNotification)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: notificationColor,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation.participantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: unreadCount > 0 && notificationColor != null
                                  ? notificationColor
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(conversation.lastActivity),
                          style: TextStyle(
                            fontSize: 12,
                            color: unreadCount > 0 && notificationColor != null
                                ? notificationColor
                                : Colors.grey[600],
                            fontWeight: unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildLastMessage(conversation.lastMessage),
                        ),
                        const SizedBox(width: 8),
                        if (!hasNewNotification && conversation.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (conversation.isMuted)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.notifications_off,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ),
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

  Widget _buildLastMessage(MessageModel? message) {
    if (message == null) {
      return Text(
        'Aucun message',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey[500],
          fontSize: 13,
        ),
      );
    }

    final currentUserId = _authService.currentUser?.id.toString() ?? '1';
    final isFromMe = message.senderId == currentUserId;
    final prefix = isFromMe ? 'Vous: ' : '';
    
    // Vérifier si c'est un sticker via les métadonnées
    final isSticker = message.metadata?['is_sticker'] == true;

    switch (message.type) {
      case MessageType.text:
        return Text(
          '$prefix${message.content}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 13,
          ),
        );
      case MessageType.image:
        if (isSticker) {
          final stickerEmoji = message.metadata?['sticker_emoji'] as String?;
          return Row(
            children: [
              if (stickerEmoji != null && stickerEmoji.isNotEmpty) ...[
                Text(
                  stickerEmoji,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  '${prefix}Sticker',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.emoji_emotions_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${prefix}Sticker',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          );
        }
        return Row(
          children: [
            Icon(Icons.image, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${prefix}Photo',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        );
      case MessageType.sticker:
        final stickerEmoji = message.metadata?['sticker_emoji'] as String?;
        return Row(
          children: [
            if (stickerEmoji != null && stickerEmoji.isNotEmpty) ...[
              Text(
                stickerEmoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '${prefix}Sticker',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ] else ...[
              Icon(
                Icons.emoji_emotions_outlined,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${prefix}Sticker',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ],
        );
      case MessageType.file:
        return Row(
          children: [
            Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${prefix}Fichier',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        );
      case MessageType.audio:
        return Row(
          children: [
            Icon(Icons.audiotrack, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${prefix}Audio',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        );
      case MessageType.video:
        return Row(
          children: [
            Icon(Icons.videocam, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${prefix}Vidéo',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        );
      default:
        return Text(
          '$prefix${message.content}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 13,
          ),
        );
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return '${dateTime.day}/${dateTime.month}';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'À l\'instant';
    }
  }
}
