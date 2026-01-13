import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/models/message_model.dart';

class EnhancedMessageBubbleWidget extends StatelessWidget {
  final MessageModel message;
  final bool isFromMe;
  final Function(MessageModel)? onTap;
  final Function(MessageModel)? onLongPress;

  const EnhancedMessageBubbleWidget({
    super.key,
    required this.message,
    required this.isFromMe,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () => onTap?.call(message),
              onLongPress: () => onLongPress?.call(message),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: _getBubbleColor(),
                  borderRadius: _getBubbleBorderRadius(),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message content
                    _buildMessageContent(),
                    
                    // Message metadata (time, status, edited indicator)
                    _buildMessageMetadata(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBubbleColor() {
    if (message.deletedForEveryone) {
      return Colors.grey[100]!;
    }
    return isFromMe ? const Color(0xFFDCF8C6) : Colors.white;
  }

  BorderRadius _getBubbleBorderRadius() {
    if (isFromMe) {
      return const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      );
    }
  }

  Widget _buildMessageContent() {
    if (message.deletedForEveryone) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Ce message a été supprimé',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            message.content,
            style: TextStyle(
              color: isFromMe ? Colors.black87 : Colors.black87,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        );
        
      case MessageType.image:
        return _buildImageContent();
        
      case MessageType.file:
        return _buildFileContent();
        
      case MessageType.audio:
        return _buildAudioContent();
        
      case MessageType.video:
        return _buildVideoContent();
        
      default:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            message.content,
            style: TextStyle(
              color: isFromMe ? Colors.black87 : Colors.black87,
              fontSize: 16,
            ),
          ),
        );
    }
  }

  Widget _buildImageContent() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 300,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (message.attachmentUrl != null)
              Image.network(
                message.attachmentUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image, color: Colors.grey),
                ),
              ),
            
            // Optional caption
            if (message.content.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.insert_drive_file,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.attachmentName ?? 'Fichier',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (message.content.isNotEmpty)
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.download,
          color: isFromMe ? Colors.blue[700] : Colors.blue,
          size: 20,
        ),
      ],
    ),
  );
  }

  Widget _buildAudioContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFromMe ? Colors.blue[700] : Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 30,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isFromMe ? Colors.blue[700] : Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        20,
                        (index) => Container(
                          width: 2,
                          height: 4 + (index % 4) * 4,
                          margin: const EdgeInsets.only(right: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '0:15',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Video thumbnail placeholder
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
              ),
            ),
            
            // Play button overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            
            // Duration indicator
            if (message.content.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageMetadata() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time
          Text(
            DateFormat('HH:mm').format(message.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: isFromMe ? Colors.grey[700] : Colors.grey[600],
            ),
          ),
          
          // Edited indicator
          if (message.isEdited) ...[
            const SizedBox(width: 4),
            Text(
              '· modifié',
              style: TextStyle(
                fontSize: 11,
                color: isFromMe ? Colors.grey[700] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          // Message status (only for sent messages)
          if (isFromMe) ...[
            const SizedBox(width: 4),
            _buildMessageStatusIcon(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icon(
          Icons.schedule,
          size: 12,
          color: Colors.grey[600],
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12,
          color: Colors.grey[600],
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 12,
          color: Colors.grey[600],
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 12,
          color: Colors.blue[400],
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 12,
          color: Colors.red[400],
        );
    }
  }
}
