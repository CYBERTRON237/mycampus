import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/group_model.dart';
import '../../domain/models/message_model.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../data/repositories/group_repository.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/group_info_widget.dart';
import '../../../../constants/app_colors.dart';
import '../../../../../core/providers/theme_provider.dart';

class GroupConversationPage extends StatefulWidget {
  final GroupModel group;

  const GroupConversationPage({
    super.key,
    required this.group,
  });

  @override
  State<GroupConversationPage> createState() => _GroupConversationPageState();
}

class _GroupConversationPageState extends State<GroupConversationPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  
  List<MessageModel> _messages = [];
  List<GroupMemberModel> _members = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _messageLoadOffset = 0;
  static const int _messageLimit = 50;
  
  String? _currentUserId;
  bool _showGroupInfo = false;
  MessageModel? _replyingToMessage;
  final bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      // Obtenir l'ID de l'utilisateur actuel depuis le repository
      final messagingRepository = Provider.of<MessagingRepositoryImpl>(context, listen: false);
      _currentUserId = messagingRepository.currentUserId;
      
      if (_currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Charger les messages et les membres en parallèle
      await Future.wait([
        _loadMessages(),
        _loadGroupMembers(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final messagingRepository = Provider.of<MessagingRepositoryImpl>(context, listen: false);
      
      // Pour les groupes, nous utilisons l'ID du groupe comme conversationId
      final conversationId = widget.group.uuid ?? widget.group.id?.toString() ?? '';
      
      if (conversationId != null) {
        final result = await messagingRepository.getMessages(
          conversationId,
          limit: _messageLimit,
          offset: loadMore ? _messageLoadOffset : 0,
        );

        result.fold(
          (error) => throw Exception(error),
          (newMessages) {
            if (mounted) {
              setState(() {
                if (loadMore) {
                  _messages.addAll(newMessages.reversed);
                } else {
                  _messages = newMessages.reversed.toList();
                }
                _messageLoadOffset += _messageLimit;
              });
              
              if (!loadMore) {
                _scrollToBottom();
              }
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des messages: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted && loadMore) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<String?> _getOrCreateGroupConversation() async {
    try {
      // Pour les groupes, nous utilisons l'UUID du groupe ou l'ID converti en string
      return widget.group.uuid ?? widget.group.id?.toString();
    } catch (e) {
      throw Exception('Impossible de récupérer l\'ID de conversation: $e');
    }
  }

  Future<void> _loadGroupMembers() async {
    try {
      final groupRepository = Provider.of<GroupRepositoryImpl>(context, listen: false);
      final groupId = widget.group.id;
      if (groupId != null) {
        final result = await groupRepository.getGroupMembers(groupId);

        result.fold(
          (error) => throw Exception(error),
          (members) {
            if (mounted) {
              setState(() => _members = members);
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des membres: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    // Effacer le champ de texte
    _messageController.clear();
    
    // Annuler la réponse si en cours
    if (_replyingToMessage != null) {
      setState(() => _replyingToMessage = null);
    }

    try {
      final messagingRepository = Provider.of<MessagingRepositoryImpl>(context, listen: false);
      final conversationId = await _getOrCreateGroupConversation();
      
      if (conversationId != null) {
        final result = await messagingRepository.sendMessage(
          receiverId: conversationId,
          content: text,
          type: MessageType.text,
        );

        result.fold(
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur d\'envoi: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (sentMessage) {
            // Ajouter le message localement pour une réponse immédiate
            if (mounted) {
              setState(() {
                _messages.insert(0, sentMessage);
              });
              _scrollToBottom();
            }
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi du message: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onRefresh() async {
    _messageLoadOffset = 0;
    await _loadMessages();
  }

  void _showMessageActions(MessageModel message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkTheme;
    final isMe = message.senderId == _currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.reply,
                      color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                    title: Text(
                      'Répondre',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _replyingToMessage = message);
                      _messageFocusNode.requestFocus();
                    },
                  ),
                  if (isMe) ...[
                    ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                      ),
                      title: Text(
                        'Modifier',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implémenter l'édition
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: AppColors.error,
                      ),
                      title: Text(
                        'Supprimer',
                        style: TextStyle(
                          color: AppColors.error,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implémenter la suppression
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _showGroupInfo = !_showGroupInfo);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.grey[300],
                    backgroundImage: widget.group.avatarUrl != null
                        ? NetworkImage(widget.group.avatarUrl!)
                        : null,
                    child: widget.group.avatarUrl == null
                        ? Text(
                            _getGroupInitials(widget.group.name),
                            style: TextStyle(
                              color: isDarkMode ? AppColors.textOnPrimary : AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.group.currentMembersCount} membres',
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textOnPrimary),
            onPressed: () {
              setState(() => _showGroupInfo = !_showGroupInfo);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textOnPrimary),
            onPressed: () {
              _showGroupOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Informations du groupe (affiché/masqué)
          if (_showGroupInfo)
            GroupInfoWidget(
              group: widget.group,
              members: _members,
              onClose: () => setState(() => _showGroupInfo = false),
            ),
          
          // Liste des messages
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          );
                        }

                        if (index >= _messages.length) {
                          return const SizedBox.shrink();
                        }

                        final message = _messages[index];
                        final isMe = message.senderId == _currentUserId;
                        final showAvatar = index == 0 || 
                            _messages[index - 1].senderId != message.senderId;
                        final showTimestamp = index == 0 ||
                            _messages[index - 1].senderId != message.senderId ||
                            (_messages[index - 1].createdAt.difference(message.createdAt).inMinutes > 5);

                        return _buildMessageBubble(
                          message,
                          isMe,
                          showAvatar,
                          showTimestamp,
                        );
                      },
                    ),
                  ),
          ),
          
          // Zone de saisie de message
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool showAvatar,
    bool showTimestamp,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme;
    
    return Column(
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _formatMessageDate(message.createdAt),
              style: TextStyle(
                color: isDarkMode ? AppColors.textLight : Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        MessageBubbleWidget(
          message: message,
          isFromMe: isMe,
          showAvatar: showAvatar,
          onLongPress: () => _showMessageActions(message),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
    return Column(
      children: [
        // Indicateur de réponse
        if (_replyingToMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.grey[100],
              border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Réponse à ${_getSenderName(_replyingToMessage!.senderId)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _replyingToMessage!.content.length > 50
                            ? '${_replyingToMessage!.content.substring(0, 50)}...'
                            : _replyingToMessage!.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? AppColors.textLight : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() => _replyingToMessage = null);
                  },
                ),
              ],
            ),
          ),
        
        // Zone de saisie principale
        MessageInputWidget(
          controller: _messageController,
          focusNode: _messageFocusNode,
          onSend: _sendMessage,
          onAttachmentTap: () => _showComingSoonSnackBar('Pièces jointes'),
          onStickerSelected: (sticker) => _sendSticker(sticker.url ?? ''),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  void _showGroupOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.people,
                      color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                    title: Text(
                      'Voir les membres',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _showGroupInfo = true);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.search,
                      color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                    title: Text(
                      'Rechercher',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar('Recherche dans la conversation');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar('Paramètres de notification');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'Quitter le groupe',
                      style: TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _leaveGroup();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: Text('Êtes-vous sûr de vouloir quitter le groupe "${widget.group.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final groupRepository = Provider.of<GroupRepositoryImpl>(context, listen: false);
        final groupId = widget.group.id;
        if (groupId != null) {
          final result = await groupRepository.leaveGroup(groupId);

          result.fold(
            (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: $error'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vous avez quitté le groupe'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            },
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _sendSticker(String stickerUrl) {
    _showComingSoonSnackBar('Stickers - URL: $stickerUrl');
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Bientôt disponible!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  String _getGroupInitials(String groupName) {
    final words = groupName.split(' ');
    if (words.length >= 2) {
      return words[0][0] + words[1][0];
    }
    return groupName.substring(0, groupName.length >= 2 ? 2 : groupName.length);
  }

  String _getSenderName(String? senderId) {
    if (senderId == null) return 'Inconnu';
    
    final member = _members.firstWhere(
      (m) => m.userId?.toString() == senderId,
      orElse: () => GroupMemberModel(
        userId: int.tryParse(senderId) ?? 0,
        role: GroupMemberRole.member,
        status: GroupMemberStatus.active,
        joinedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    // Retourner le nom complet si disponible, sinon le nom d'utilisateur
    final fullName = member.fullName ?? 
           '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    
    if (fullName.isNotEmpty) {
      return fullName;
    } else {
      return 'Utilisateur $senderId';
    }
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return date.day.toString();
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
