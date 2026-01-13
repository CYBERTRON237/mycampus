import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/sticker_model.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../data/datasources/messaging_remote_datasource.dart';
import '../../services/websocket_service.dart';
import '../../services/presence_service.dart';
import '../../../auth/services/auth_service.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/message_actions_widget.dart';
import 'user_profile_page.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ConversationPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? conversationId; // Ajouter l'ID de conversation pré-créé

  const ConversationPage({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.conversationId, // Paramètre optionnel
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> 
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final PresenceService _presenceService = PresenceService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  bool _userIsOnline = false;
  bool _userIsTyping = false;
  bool _hasLoadedOnce = false;
  
  List<MessageModel> _messages = [];
  List<MessageModel> _newMessages = []; // Messages non lus
  String? _currentUserId;
  late final MessagingRepository _messagingRepository;
  MessageModel? _replyingToMessage;
  FocusNode _messageFocusNode = FocusNode();
  
  Timer? _refreshTimer;
  Timer? _typingTimer;
  Timer? _presenceCheckTimer;
  late AnimationController _typingIndicatorController;
  late AnimationController _messageEnterAnimationController;
  
  static const int _messageLoadLimit = 1000;
  int _messageLoadOffset = 0;
  String? _cachedConversationId;

  @override
  void initState() {
    super.initState();
    
    // Utiliser l'ID de conversation pré-créé si disponible
    if (widget.conversationId != null) {
      _cachedConversationId = widget.conversationId;
    }
    
    _initializeAnimations();
    _initializeRepository();
    _initializeWebSocket();
    _initializePresence();
    
    // Initialiser les notifications de manière async
    _initializeNotifications().then((_) {
      // Éviter les rechargements multiples
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasLoadedOnce) {
          _loadMessages();
        }
      });
    });
    
    _scrollController.addListener(_scrollListener);
    _startAutoRefresh();
    _checkUserOnlineStatus();
  }
  
  
  void _initializeWebSocket() {
    // Activer WebSocket pour le temps réel avec l'ID utilisateur courant
    final currentUserId = _authService.currentUser?.id.toString() ?? '1';
    final webSocketService = WebSocketService(userId: currentUserId);
    
    if (webSocketService.isConnected) {
      webSocketService.disconnect();
    }
    
    webSocketService.connect();
    webSocketService.joinRoom(widget.userId);
    
    // Écouter les messages en temps réel
    webSocketService.messageStream.listen((message) {
      final messageModel = message;
      
      if (mounted) {
        final isForThisConversation = 
            messageModel.senderId == widget.userId || 
            messageModel.receiverId == widget.userId;
            
        if (isForThisConversation) {
          final messageExists = _messages.any((msg) => msg.id == messageModel.id);
          final newMessageExists = _newMessages.any((msg) => msg.id == messageModel.id);
          
          if (!messageExists && !newMessageExists) {
            // Si le message est de l'autre utilisateur, l'ajouter aux nouveaux messages
            if (messageModel.senderId != _currentUserId) {
              setState(() {
                _newMessages.insert(0, messageModel);
              });
            } else {
              // Si c'est notre message, l'ajouter normalement
              setState(() {
                _messages.add(messageModel);
              });
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _scrollToBottom();
                }
              });
            }
          }
        }
      }
    });
    
    // Écouter les événements de frappe
    webSocketService.typingStream.listen((event) {
      if (mounted && event.userId == widget.userId) {
        setState(() {
          _userIsTyping = event.isTyping;
        });
      }
    });
    
    // Écouter les statuts utilisateur
    webSocketService.userStatusStream.listen((event) {
      if (mounted && event.userId == widget.userId) {
        setState(() {
          _userIsOnline = event.isOnline;
        });
      }
    });
  }

  void _insertMessageOptimized(MessageModel message) {
    if (!mounted) return;
    
    // Insertion optimisée
    setState(() {
      _messages.add(message);
    });
  }

  Future<void> _initializeNotifications() async {
    // Utiliser le bon service d'authentification
    final authUser = await _authService.getCurrentUser();
    _currentUserId = authUser?.id.toString() ?? '1';
  }

  void _initializeAnimations() {
    _typingIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _messageEnterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _initializeRepository() async {
    final token = await _authService.getToken();
    final baseUrl = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging'
        : 'http://127.0.0.1/mycampus/api/messaging';
    
    _messagingRepository = MessagingRepositoryImpl(
      remoteDataSource: MessagingRemoteDataSourceImpl(
        client: http.Client(),
        baseUrl: baseUrl,
        authToken: token,
      ),
      currentUserId: _currentUserId ?? '1',
    );
  }

  void _startAutoRefresh() {
    // Rafraîchissement toutes les 3 secondes au lieu de 200ms pour éviter les problèmes
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLoading && mounted && _cachedConversationId != null && _hasLoadedOnce) {
        // TOUJOURS rafraîchir mais NE PAS forcer le scroll
        _loadMessages(isAutoRefresh: true);
      }
    });
  }

  Future<void> _checkUserOnlineStatus() async {
    try {
      // Vérifier le statut de présence via le service
      final presence = await _presenceService.getUserPresence(int.parse(widget.userId));
      
      if (mounted && presence != null) {
        setState(() {
          _userIsOnline = presence.isOnline;
        });
      }

      // Configurer un timer pour vérifier périodiquement
      _presenceCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
        if (mounted) {
          final updatedPresence = await _presenceService.getUserPresence(int.parse(widget.userId));
          if (updatedPresence != null) {
            setState(() {
              _userIsOnline = updatedPresence.isOnline;
            });
          }
        }
      });
    } catch (e) {
      print('Error checking user online status: $e');
    }
  }

  void _initializePresence() {
    // Démarrer le suivi de présence pour l'utilisateur actuel
    _presenceService.startTracking();
    
    // Écouter les mises à jour de présence
    _presenceService.presenceStream.listen((presenceUpdate) {
      if (mounted && presenceUpdate.userId.toString() == widget.userId) {
        setState(() {
          _userIsOnline = presenceUpdate.isOnline;
        });
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.offset < _scrollController.position.maxScrollExtent - 200) {
      if (!_showScrollToBottom) {
        setState(() {
          _showScrollToBottom = true;
        });
      }
    } else {
      if (_showScrollToBottom) {
        setState(() {
          _showScrollToBottom = false;
        });
      }
    }

    // Charger plus de messages lorsqu'on atteint le haut (pour WhatsApp)
    if (_scrollController.offset <= 100 && !_isLoadingMore && _hasMoreMessages) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _messageLoadOffset += _messageLoadLimit;
      
      final client = http.Client();
      String url = kIsWeb 
          ? 'http://localhost/mycampus/api/messaging/messages/get_messages.php'
          : 'http://127.0.0.1/mycampus/api/messaging/messages/get_messages.php';
      
      final response = await client.get(
        Uri.parse('$url?id=$_cachedConversationId'), // Pas de limite pour charger tous les messages
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': _currentUserId!, // Add user ID header
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Délai d\'attente dépassé'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final newMessages = jsonData.map((json) => MessageModel.fromJson(json)).toList();

        setState(() {
          _messages.insertAll(0, newMessages);
          _isLoadingMore = false;
          _hasMoreMessages = false; // Plus besoin de charger plus de messages - tout est chargé
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMessages({bool isAutoRefresh = false}) async {
    // Pour auto-refresh: ne jamais bloquer
    if (_isLoading && !isAutoRefresh) return;

    // Pour auto-refresh: pas de loading spinner
    setState(() {
      _isLoading = !isAutoRefresh;
    });

    try {
      // Utiliser le cache pour auto-refresh
      if (!isAutoRefresh) {
        _cachedConversationId = null;
        _newMessages.clear(); // Vider les nouveaux messages au chargement initial
        await _getOrCreateConversationId();
      }

      if (_cachedConversationId == null) {
        throw Exception('Could not get conversation ID');
      }
      
      await _loadMessagesFromConversation(_cachedConversationId!, isAutoRefresh: isAutoRefresh);
      
      // Forcer un deuxième chargement après un court délai pour les nouvelles conversations
      if (!isAutoRefresh && _messages.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted && _cachedConversationId != null) {
          await _loadMessagesFromConversation(_cachedConversationId!, isAutoRefresh: true);
        }
      }
      
      _hasLoadedOnce = true;
    } catch (e) {
      if (!isAutoRefresh && mounted) {
        _showErrorSnackBar('Erreur chargement messages');
        print('Erreur loadMessages: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getOrCreateConversationId() async {
    // Si l'ID de conversation est déjà disponible (pré-créé), ne pas faire d'appel API
    if (_cachedConversationId != null) {
      return;
    }
    
    final client = http.Client();
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/messages/get_conversation_id.php'
        : 'http://127.0.0.1/mycampus/api/messaging/messages/get_conversation_id.php';
    
    final conversationResponse = await client.get(
      Uri.parse(url).replace(queryParameters: {
        'user_id': _currentUserId,
        'participant_id': widget.userId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': _currentUserId!, // Add user ID header (non-null assertion)
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Délai d\'attente dépassé'),
    );

    if (conversationResponse.statusCode == 200) {
      final conversationData = json.decode(conversationResponse.body);

      if (conversationData['success'] == true) {
        _cachedConversationId = conversationData['conversation_id'].toString();
      } else {
        if (mounted) {
          setState(() {
            _messages = [];
            _isLoading = false;
          });
        }
        return;
      }
    } else {
      throw Exception('Erreur: ${conversationResponse.statusCode}');
    }
  }

  Future<void> _markReceivedMessagesAsDelivered(List<MessageModel> messages) async {
    try {
      // Find received messages (sent by other user) that are not yet delivered
      final receivedMessages = messages.where((message) => 
        message.senderId != _currentUserId && 
        message.status != MessageStatus.delivered &&
        message.status != MessageStatus.read
      ).toList();

      if (receivedMessages.isNotEmpty && _cachedConversationId != null) {
        await _messagingRepository.markMessagesAsDelivered(_cachedConversationId!);
      }
    } catch (e) {
      print('Error marking messages as delivered: $e');
    }
  }

  Future<void> _loadMessagesFromConversation(String conversationId, {bool isAutoRefresh = false}) async {
    final client = http.Client();
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/messages/get_messages.php'
        : 'http://127.0.0.1/mycampus/api/messaging/messages/get_messages.php';
    
    final response = await client.get(
      Uri.parse('$url?id=$conversationId'), // Pas de limite ni d'offset pour charger tous les messages
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': _currentUserId!, // Add user ID header
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Délai d\'attente dépassé'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final newMessages = jsonData.map((json) => MessageModel.fromJson(json)).toList();

      // Marquer les messages reçus comme delivered (un trait -> deux traits)
      await _markReceivedMessagesAsDelivered(newMessages);

      // Sauvegarder l'état auto-refresh avant le setState
      final wasAutoRefresh = isAutoRefresh;

      if (mounted) {
        setState(() {
          // Pour auto-refresh: ajouter seulement les messages qui n'existent pas déjà
          if (_messageLoadOffset == 0) {
            // Premier chargement: remplacer la liste
            _messages = newMessages;
          } else {
            // Auto-refresh: ajouter seulement les nouveaux messages
            for (final newMessage in newMessages) {
              if (!_messages.any((msg) => msg.id == newMessage.id)) {
                _messages.add(newMessage);
              }
            }
          }
          _isLoading = false;
          _hasMoreMessages = false; // Plus besoin de charger plus de messages - tout est chargé
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            // PAS de scroll automatique pour auto-refresh - préserver la position utilisateur
            if (_messageLoadOffset == 0 && !wasAutoRefresh) {
              // Scroll vers le bas uniquement pour le premier chargement manuel
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        });
      }
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<void> _sendMessage() async {
    print('🚀 DEBUG: _sendMessage() appelé');
    
    if (_messageController.text.trim().isEmpty) {
      print('❌ DEBUG: Message vide, envoi annulé');
      return;
    }

    final content = _messageController.text.trim();
    print('📝 DEBUG: Contenu du message: "$content"');
    
    _messageController.clear();

    setState(() {
      _isTyping = false;
    });

    // Envoyer l'indicateur de frappe via WebSocket immédiatement
    final currentUserId = _authService.currentUser?.id.toString() ?? '1';
    final webSocketService = WebSocketService(userId: currentUserId);
    webSocketService.sendTyping(
      roomId: widget.userId,
      isTyping: false,
    );

    // Message optimiste instantané
    final optimisticMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: widget.userId,
      content: content,
      type: MessageType.text,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    // Insertion optimiste instantané - OPTIMISATION MAXIMALE
    setState(() {
      _messages.add(optimisticMessage);
    });
    
    // Scroll immédiat APRÈS le setState - mais seulement si l'utilisateur est déjà en bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isAtBottom()) {
        _scrollToBottom();
      }
    });
    
    try {
      // Vérifier si WebSocket est connecté
      final currentUserId = _authService.currentUser?.id.toString() ?? '1';
      final webSocketService = WebSocketService(userId: currentUserId);
      if (webSocketService.isConnected) {
        // Envoi WebSocket pour temps réel
        webSocketService.sendMessage(
          roomId: widget.userId,
          content: content,
        );
      } else {
        print('WebSocket non connecté, utilisation de HTTP uniquement');
      }

      final result = await _messagingRepository.sendMessage(
        receiverId: widget.userId,
        content: content,
        type: MessageType.text,
      );

      result.fold(
        (error) {
          _showErrorSnackBar('Erreur lors de l\'envoi du message');
          
          // Retirer le message optimiste
          setState(() {
            _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
          });
        },
        (sentMessage) {
          // Remplacement optimisé avec setState unique
          final index = _messages.indexWhere((msg) => msg.id == optimisticMessage.id);
          if (index != -1 && mounted) {
            setState(() {
              _messages[index] = sentMessage;
            });
            
            // Scroll après mise à jour - seulement si l'utilisateur est en bas
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isAtBottom()) _scrollToBottom();
            });
          }
          
          // Rafraîchir les messages pour s'assurer qu'ils sont tous là
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _cachedConversationId != null) {
              _loadMessagesFromConversation(_cachedConversationId!);
            }
          });
        },
      );
    } catch (e) {
      print('Exception envoi message: $e');
      _showErrorSnackBar('Erreur lors de l\'envoi du message');
      
      setState(() {
        _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
      });
    }
  }

  Future<void> _sendSticker(StickerModel sticker) async {
    // Envoyer le sticker via WebSocket immédiatement
    final currentUserId = _authService.currentUser?.id.toString() ?? '1';
    final webSocketService = WebSocketService(userId: currentUserId);
    webSocketService.sendMessage(
      roomId: widget.userId,
      content: sticker.url,
      messageType: 'sticker',
    );

    // Message optimiste instantané avec le bon type
    final optimisticMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: widget.userId,
      content: sticker.url, // Garder l'URL dans content pour compatibilité
      type: MessageType.image, // Utiliser image pour compatibilité avec votre BDD
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
      attachmentUrl: sticker.url,
      attachmentName: sticker.name,
      metadata: {
        'sticker_id': sticker.id,
        'sticker_emoji': sticker.emoji,
        'is_sticker': true,
      },
    );

    // Insertion optimisée
    _insertMessageOptimized(optimisticMessage);
    _scrollToBottom();

    try {
      final result = await _messagingRepository.sendMessage(
        receiverId: widget.userId,
        content: sticker.url, // Garder l'URL dans content
        type: MessageType.image, // Utiliser image pour compatibilité
        attachmentUrl: sticker.url,
        attachmentName: sticker.name,
      );

      result.fold(
        (error) {
          _showErrorSnackBar('Erreur lors de l\'envoi du sticker');
          
          setState(() {
            _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
          });
        },
        (sentMessage) {
          final index = _messages.indexWhere((msg) => msg.id == optimisticMessage.id);
          if (index != -1) {
            setState(() {
              _messages[index] = sentMessage;
            });
          }
          
          _scrollToBottom();
        },
      );
    } catch (e) {
      print('Exception envoi sticker: $e');
      _showErrorSnackBar('Erreur lors de l\'envoi du sticker');
      
      setState(() {
        _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
      });
    }
  }

  bool _isAtBottom() {
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset >= _scrollController.position.maxScrollExtent - 100;
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

  
  void _handleTyping(String value) {
    _typingTimer?.cancel();
    setState(() {
      _isTyping = true;
    });

    // Envoyer l'indicateur de frappe via WebSocket
    final currentUserId = _authService.currentUser?.id.toString() ?? '1';
    final webSocketService = WebSocketService(userId: currentUserId);
    webSocketService.sendTyping(
      roomId: widget.userId,
      isTyping: true,
    );

    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        
        // Envoyer l'arrêt de frappe
        webSocketService.sendTyping(
          roomId: widget.userId,
          isTyping: false,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  
  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Bientôt disponible',
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
      resizeToAvoidBottomInset: true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
    return AppBar(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
      elevation: 2,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.light,
      ),
      leadingWidth: 56,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Retour',
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(contact: _createContactFromConversation()),
            ),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.grey[300],
              backgroundImage: widget.userAvatar != null
                  ? NetworkImage(widget.userAvatar!)
                  : null,
              child: widget.userAvatar == null
                  ? Text(
                      _getInitials(widget.userName),
                      style: TextStyle(
                        color: isDarkMode ? AppColors.textOnPrimary : AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _userIsTyping
                        ? 'écrit...'
                        : _userIsOnline
                            ? 'En ligne'
                            : 'Hors ligne',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view_contact',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: isDarkMode ? AppColors.primaryDark : AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Text('Voir le contact'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search, color: isDarkMode ? AppColors.primaryDark : AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Text('Rechercher'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(Icons.notifications_off, color: isDarkMode ? AppColors.primaryDark : AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Mettre en silence'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'wallpaper',
              child: Row(
                children: [
                  Icon(Icons.wallpaper, color: isDarkMode ? AppColors.primaryDark : AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Fond d\'écran'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'more',
              child: Row(
                children: [
                  Icon(Icons.more_horiz, color: isDarkMode ? AppColors.primaryDark : AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Plus'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view_contact':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(contact: _createContactFromConversation()),
                  ),
                );
                break;
              case 'search':
                _showComingSoonSnackBar('Recherche dans la conversation');
                break;
              case 'mute':
                _showComingSoonSnackBar('Mise en silence de la conversation');
                break;
              case 'wallpaper':
                _showComingSoonSnackBar('Personnalisation du fond d\'écran');
                break;
              case 'more':
                _showComingSoonSnackBar('Options supplémentaires');
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
    return Column(
      children: [
        // Indicateur de nouveaux messages
        if (_newMessages.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary,
            child: Row(
              children: [
                const Icon(Icons.new_releases, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_newMessages.length} nouveau${_newMessages.length > 1 ? 'x' : ''} message${_newMessages.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _messages.insertAll(0, _newMessages.reversed.toList());
                      _newMessages.clear();
                    });
                    _scrollToBottom();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Voir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _buildMessagesList(),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessagesList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
    if (_isLoading && _messages.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: isDarkMode ? AppColors.textLight : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun message',
              style: TextStyle(
                color: isDarkMode ? AppColors.textLight : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Envoyez votre premier message à ${widget.userName}',
              style: TextStyle(
                color: isDarkMode ? AppColors.textLight : Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
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

            final message = _messages[index];
            final isMe = message.senderId == _currentUserId;
            final showAvatar = index == _messages.length - 1 || 
                _messages[index + 1].senderId != message.senderId;
            final showTimestamp = index == _messages.length - 1 ||
                _messages[index + 1].senderId != message.senderId ||
                (_messages[index + 1].createdAt.difference(message.createdAt).inMinutes > 5);

            return _buildMessageBubble(
              message,
              isMe,
              showAvatar,
              showTimestamp,
            );
          },
        ),
        if (_showScrollToBottom)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool showAvatar,
    bool showTimestamp,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
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
          senderAvatar: isMe ? null : (widget.userAvatar ?? message.sender?.avatar),
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
        // Reply indicator
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
                        'Réponse à ${_replyingToMessage!.sender?.fullName ?? 'quelqu\'un'}',
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
                    setState(() {
                      _replyingToMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
        
        // Main input area avec MessageInputWidget
        MessageInputWidget(
          controller: _messageController,
          onSend: _sendMessage,
          onAttachmentTap: () => _showComingSoonSnackBar('Pièces jointes'),
          onStickerSelected: _sendSticker,
          isDarkMode: Provider.of<ThemeProvider>(context).isDarkTheme,
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) { 
      const days = [
        'Dimanche',
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi'
      ];
      return days[dateTime.weekday % 7];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _typingTimer?.cancel();
    _presenceCheckTimer?.cancel();
    _typingIndicatorController.dispose();
    _messageEnterAnimationController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    
    // Arrêter le suivi de présence
    _presenceService.stopTracking();
    
    super.dispose();
  }

  // WhatsApp-like CRUD operations
  void _editMessage(MessageModel message) {
    _messageController.text = message.content;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le message'),
        content: TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Votre message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _messagingRepository.editMessage(message.id, _messageController.text);
              _loadMessages();
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(String messageId, {bool deleteForEveryone = false}) {
    _messagingRepository.deleteMessage(messageId, deleteForEveryone: deleteForEveryone).then((_) {
      _loadMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteForEveryone ? 'Message supprimé pour tout le monde' : 'Message supprimé'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _showMessageActions(MessageModel message) {
    final isFromMe = message.senderId == _currentUserId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessageActionsWidget(
        message: message,
        isFromMe: isFromMe,
        onEdit: isFromMe ? () => _editMessage(message) : null,
        onDelete: isFromMe ? () => _deleteMessage(message.id) : null,
        onDeleteForEveryone: isFromMe ? () => _deleteMessage(message.id, deleteForEveryone: true) : null,
        onReply: () => _replyToMessage(message),
        onForward: () => _forwardMessage(message),
        onCopy: () => _copyMessage(message),
        onInfo: () => _showMessageInfo(message),
      ),
    );
  }

  void _replyToMessage(MessageModel message) {
    setState(() {
      _replyingToMessage = message;
    });
    _messageFocusNode.requestFocus();
  }

  void _forwardMessage(MessageModel message) {
    // Show dialog to select contact to forward to
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de transfert bientôt disponible')),
    );
  }

  void _copyMessage(MessageModel message) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copié')),
    );
  }

  void _showMessageInfo(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations du message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Envoyé par: ${message.sender?.fullName ?? 'Inconnu'}'),
            Text('Le: ${message.createdAt.toString()}'),
            if (message.isEdited) const Text('Statut: Modifié'),
            if (message.deletedForEveryone) const Text('Statut: Supprimé pour tous'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Crée un ContactModel à partir des informations de la conversation
  ContactModel _createContactFromConversation() {
    final nameParts = widget.userName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    return ContactModel(
      id: widget.userId,
      userId: _currentUserId ?? '',
      contactUserId: widget.userId,
      firstName: firstName,
      lastName: lastName,
      email: '', // Pas disponible dans la conversation
      avatar: widget.userAvatar,
      phone: null, // Pas disponible dans la conversation
      role: 'student', // Valeur par défaut
      status: ContactStatus.accepted, // On est dans une conversation, donc le contact est accepté
      createdAt: DateTime.now(),
      lastSeenAt: null,
      isFavorite: false,
      isOnline: _userIsOnline,
    );
  }
}
