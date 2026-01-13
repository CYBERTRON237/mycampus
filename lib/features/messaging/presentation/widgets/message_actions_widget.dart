import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/message_model.dart';
import 'package:intl/intl.dart';

class MessageActionsWidget extends StatelessWidget {
  final MessageModel message;
  final bool isFromMe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteForEveryone;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onStar;
  final VoidCallback? onCopy;
  final VoidCallback? onInfo;

  const MessageActionsWidget({
    super.key,
    required this.message,
    required this.isFromMe,
    this.onEdit,
    this.onDelete,
    this.onDeleteForEveryone,
    this.onReply,
    this.onForward,
    this.onStar,
    this.onCopy,
    this.onInfo,
  });

  bool get canEdit => isFromMe && 
                      message.type == MessageType.text && 
                      !message.isDeleted &&
                      DateTime.now().difference(message.createdAt).inMinutes <= 15;

  bool get canDeleteForEveryone => isFromMe && 
                                   !message.isDeleted &&
                                   DateTime.now().difference(message.createdAt).inHours <= 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message preview header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isFromMe ? const Color(0xFF25D366) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    message.type == MessageType.text ? Icons.text_fields : 
                    message.type == MessageType.image ? Icons.image :
                    message.type == MessageType.file ? Icons.insert_drive_file :
                    Icons.attach_file,
                    color: isFromMe ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content.length > 30 
                            ? '${message.content.substring(0, 30)}...' 
                            : message.content,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormat('HH:mm').format(message.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (message.isEdited) ...[
                            const SizedBox(width: 4),
                            Text(
                              '· modifié',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
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
          
          // Action items
          _buildActionItem(
            icon: Icons.reply,
            title: 'Répondre',
            onTap: () {
              Navigator.pop(context);
              onReply?.call();
            },
          ),
          
          _buildActionItem(
            icon: Icons.forward,
            title: 'Transférer',
            onTap: () {
              Navigator.pop(context);
              onForward?.call();
            },
          ),
          
          if (message.type == MessageType.text)
            _buildActionItem(
              icon: Icons.copy,
              title: 'Copier',
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copié'),
                    duration: Duration(seconds: 2),
                  ),
                );
                onCopy?.call();
              },
            ),
          
          _buildActionItem(
            icon: message.isEdited ? Icons.star_border : Icons.star,
            title: message.isEdited ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onTap: () {
              Navigator.pop(context);
              onStar?.call();
            },
          ),
          
          if (canEdit)
            _buildActionItem(
              icon: Icons.edit,
              title: 'Modifier',
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
          
          if (isFromMe) ...[
            _buildActionItem(
              icon: Icons.delete_outline,
              title: 'Supprimer pour moi',
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
            
            if (canDeleteForEveryone)
              _buildActionItem(
                icon: Icons.delete,
                title: 'Supprimer pour tout le monde',
                titleColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteForEveryoneConfirmation(context);
                },
              ),
          ],
          
          _buildActionItem(
            icon: Icons.info_outline,
            title: 'Informations',
            onTap: () {
              Navigator.pop(context);
              onInfo?.call();
            },
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.grey[700], size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  void _showDeleteForEveryoneConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer pour tout le monde',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ceci supprimera le message pour tous les participants de la conversation. Cette action est irréversible.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vous ne pouvez supprimer un message pour tout le monde que dans l\'heure suivant son envoi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteForEveryone?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
