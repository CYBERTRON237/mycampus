import 'package:flutter/material.dart';
import '../../domain/models/message_model.dart';
import '../../../../constants/app_colors.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageModel message;
  final bool isFromMe;
  final bool showAvatar;
  final VoidCallback? onLongPress;
  final String? senderAvatar;
  final bool isDarkMode;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isFromMe,
    this.showAvatar = false,
    this.onLongPress,
    this.senderAvatar,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromMe && showAvatar) ...[
            _buildProfileAvatar(),
            const SizedBox(width: 8),
          ],
          if (!isFromMe && !showAvatar) const SizedBox(width: 40),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Column(
                crossAxisAlignment: isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: _getPadding(),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(),
                      borderRadius: _getBorderRadius(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: _buildMessageContent(),
                  ),
                  const SizedBox(height: 4),
                  _buildMessageInfo(),
                ],
              ),
            ),
          ),
          if (isFromMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (message.type) {
      case MessageType.text:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case MessageType.image:
        return const EdgeInsets.all(4);
      case MessageType.file:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case MessageType.audio:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case MessageType.video:
        return const EdgeInsets.all(4);
      case MessageType.system:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case MessageType.sticker:
        return const EdgeInsets.all(4);
    }
  }

  BorderRadius _getBorderRadius() {
    const radius = Radius.circular(16);
    const smallRadius = Radius.circular(4);
    
    if (isFromMe) {
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: smallRadius,
      );
    } else {
      return const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: smallRadius,
        bottomRight: radius,
      );
    }
  }

  Color _getBubbleColor() {
    if (message.type == MessageType.system) {
      return isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    }
    
    return isFromMe
        ? AppColors.primary
        : isDarkMode ? AppColors.surfaceDark : Colors.grey[100]!;
  }

  Widget _buildMessageContent() {
    // Vérifier si c'est un sticker via les métadonnées
    final isSticker = message.metadata?['is_sticker'] == true;
    
    if (isSticker || message.type == MessageType.sticker) {
      return _buildStickerContent();
    }
    
    switch (message.type) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.file:
        return _buildFileContent();
      case MessageType.audio:
        return _buildAudioContent();
      case MessageType.video:
        return _buildVideoContent();
      default:
        return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return Text(
      message.content,
      style: TextStyle(
        color: isFromMe 
            ? Colors.white 
            : isDarkMode ? AppColors.textLight : Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content.isNotEmpty)
          Text(
            message.content,
            style: TextStyle(
              color: isFromMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        if (message.attachmentUrl != null)
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: Stack(
              children: [
                if (message.attachmentUrl!.startsWith('http'))
                  Image.network(
                    message.attachmentUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                else
                  _buildImagePlaceholder(),
                if (message.hasAttachment)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFileContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getFileIcon(),
          color: isFromMe ? Colors.white : Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.attachmentName ?? 'Fichier',
                style: TextStyle(
                  color: isFromMe ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (message.content.isNotEmpty)
                Text(
                  message.content,
                  style: TextStyle(
                    color: isFromMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (isFromMe) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.download,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ],
    );
  }

  Widget _buildAudioContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.audiotrack,
          color: isFromMe ? Colors.white : Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            message.content.isNotEmpty ? message.content : 'Message audio',
            style: TextStyle(
              color: isFromMe ? Colors.white : Colors.black87,
            ),
          ),
        ),
        if (isFromMe) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.play_arrow,
            color: Colors.white70,
            size: 20,
          ),
        ],
      ],
    );
  }

  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content.isNotEmpty)
          Text(
            message.content,
            style: TextStyle(
              color: isFromMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        if (message.attachmentUrl != null)
          Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[400],
                  child: const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessageInfo() {
    return Padding(
      padding: EdgeInsets.only(
        left: isFromMe ? 0 : 40,
        right: isFromMe ? 40 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 4),
            _buildStatusIcon(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(
          Icons.access_time,
          size: 11,
          color: Colors.grey,
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check,
          size: 11,
          color: Colors.grey,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all,
          size: 11,
          color: Colors.grey,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 11,
          color: Colors.blue,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error,
          size: 11,
          color: Colors.red,
        );
    }
  }

  IconData _getFileIcon() {
    final fileName = message.attachmentName?.toLowerCase() ?? '';
    
    if (fileName.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description;
    } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) {
      return Icons.table_chart;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Icons.slideshow;
    } else if (fileName.endsWith('.zip') || fileName.endsWith('.rar')) {
      return Icons.folder_zip;
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || 
               fileName.endsWith('.png') || fileName.endsWith('.gif')) {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else if (now.difference(dateTime).inDays < 7) {
      final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      final weekdayIndex = dateTime.weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < days.length) {
        return days[weekdayIndex];
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Widget _buildProfileAvatar() {
    final avatarUrl = senderAvatar ?? message.sender?.avatar;
    final name = message.sender?.fullName ?? 'Utilisateur';
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey[300],
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty 
          ? NetworkImage(avatarUrl) 
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              _getInitials(name),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Widget _buildStickerContent() {
    // Afficher le sticker avec une taille appropriée et style WhatsApp
    final stickerUrl = message.attachmentUrl ?? message.content;
    final stickerEmoji = message.metadata?['sticker_emoji'] as String?;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: 150,
        maxHeight: 150,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Image du sticker
            if (stickerUrl.startsWith('assets'))
              Image.asset(
                stickerUrl,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildStickerFallback(stickerEmoji);
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  );
                },
              )
            else if (stickerUrl.startsWith('http'))
              Image.network(
                stickerUrl,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );
                  }
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF075E54),
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildStickerFallback(stickerEmoji);
                },
              )
            else
              _buildStickerFallback(stickerEmoji),
            
            // Badge d'emoji en superposition si disponible
            if (stickerEmoji != null && stickerEmoji.isNotEmpty)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      stickerEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerFallback(String? emoji) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[100],
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emoji != null && emoji.isNotEmpty) ...[
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              'Sticker',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Icon(
              Icons.emoji_emotions_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Sticker',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
