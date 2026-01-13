import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OnlineStatusWidget extends StatelessWidget {
  final String? avatarUrl;
  final String userName;
  final bool isOnline;
  final String? lastSeen;
  final double avatarSize;
  final bool showStatus;
  final VoidCallback? onTap;

  const OnlineStatusWidget({
    super.key,
    this.avatarUrl,
    required this.userName,
    required this.isOnline,
    this.lastSeen,
    this.avatarSize = 40.0,
    this.showStatus = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar avec point de statut
          Stack(
            children: [
              // Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: avatarSize,
                            height: avatarSize,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: avatarSize * 0.6,
                              color: Colors.grey[600],
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: avatarSize,
                            height: avatarSize,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: avatarSize * 0.6,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : Container(
                          width: avatarSize,
                          height: avatarSize,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: avatarSize * 0.6,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),
              
              // Point de statut en ligne (style WhatsApp/Messenger)
              if (showStatus)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: avatarSize * 0.3,
                    height: avatarSize * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? Colors.green : Colors.grey,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Nom et statut
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom d'utilisateur
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Statut en ligne ou dernière vue
                if (showStatus)
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.green : Colors.grey[600],
                      fontWeight: isOnline ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (isOnline) {
      return 'En ligne';
    }
    
    if (lastSeen != null) {
      final lastSeenDateTime = DateTime.tryParse(lastSeen!);
      if (lastSeenDateTime != null) {
        final now = DateTime.now();
        final difference = now.difference(lastSeenDateTime);
        
        if (difference.inMinutes < 1) {
          return 'À l\'instant';
        } else if (difference.inMinutes < 60) {
          return 'Il y a ${difference.inMinutes} min';
        } else if (difference.inHours < 24) {
          return 'Il y a ${difference.inHours} h';
        } else if (difference.inDays < 7) {
          return 'Il y a ${difference.inDays} j';
        } else {
          return 'Vu le ${lastSeenDateTime.day}/${lastSeenDateTime.month}/${lastSeenDateTime.year}';
        }
      }
    }
    
    return 'Hors ligne';
  }
}

// Widget pour le header de la conversation avec statut en ligne
class ConversationHeaderWidget extends StatelessWidget {
  final String? avatarUrl;
  final String userName;
  final bool isOnline;
  final String? lastSeen;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onVideoCallTap;

  const ConversationHeaderWidget({
    super.key,
    this.avatarUrl,
    required this.userName,
    required this.isOnline,
    this.lastSeen,
    this.onProfileTap,
    this.onCallTap,
    this.onVideoCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          
          // Avatar et info utilisateur
          Expanded(
            child: OnlineStatusWidget(
              avatarUrl: avatarUrl,
              userName: userName,
              isOnline: isOnline,
              lastSeen: lastSeen,
              avatarSize: 36.0,
              showStatus: true,
              onTap: onProfileTap,
            ),
          ),
          
          // Actions (appels)
          Row(
            children: [
              if (onCallTap != null)
                IconButton(
                  onPressed: onCallTap,
                  icon: Icon(
                    Icons.phone,
                    color: const Color(0xFF075E54),
                    size: 24,
                  ),
                ),
              
              if (onVideoCallTap != null)
                IconButton(
                  onPressed: onVideoCallTap,
                  icon: Icon(
                    Icons.videocam,
                    color: const Color(0xFF075E54),
                    size: 24,
                  ),
                ),
              
              // Menu options
              IconButton(
                onPressed: () {
                  // Menu options
                },
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black54,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
