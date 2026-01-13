import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserSelectionWidget extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;
  final VoidCallback? onTap;
  final bool compact;
  final Function(String, UserModel)? onQuickAction;

  const UserSelectionWidget({
    super.key,
    required this.user,
    required this.isSelected,
    this.onSelectionChanged,
    this.onTap,
    this.compact = false,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            children: [
              // Selection checkbox
              Checkbox(
                value: isSelected,
                onChanged: onSelectionChanged,
              ),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: compact ? 16 : 20,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 14 : 16,
                                ),
                              ),
                              if (!compact) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusChip(context, user.primaryRole, _getRoleColor(user.primaryRole)),
                          const SizedBox(width: 8),
                          _buildStatusChip(context, user.accountStatus, _getStatusColor(user.accountStatus)),
                          const SizedBox(width: 8),
                          if (user.institutionName != null)
                            _buildStatusChip(context, user.institutionName!, Colors.grey),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Quick actions
              if (!compact)
                PopupMenuButton<String>(
                  onSelected: (action) => _handleQuickAction(context, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('Voir détails'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'complete_edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_note, size: 16),
                          SizedBox(width: 8),
                          Text('Modification complète'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(Icons.power_settings_new, size: 16),
                          SizedBox(width: 8),
                          Text('Activer/Désactiver'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleQuickAction(BuildContext context, String action) {
    if (onQuickAction != null) {
      onQuickAction!(action, user);
      return;
    }
    
    // Fallback behavior if no callback provided
    switch (action) {
      case 'view':
        // Navigate to user details
        break;
      case 'edit':
        // Navigate to edit user
        break;
      case 'complete_edit':
        // Navigate to complete edit user
        break;
      case 'toggle':
        // Toggle user status
        break;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Colors.purple;
      case 'admin_national':
        return Colors.red;
      case 'admin_local':
        return Colors.orange;
      case 'leader':
        return Colors.teal;
      case 'teacher':
        return Colors.green;
      case 'staff':
        return Colors.blue;
      case 'moderator':
        return Colors.indigo;
      case 'student':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      case 'banned':
        return Colors.red;
      case 'pending_verification':
        return Colors.amber;
      case 'graduated':
        return Colors.blue;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
