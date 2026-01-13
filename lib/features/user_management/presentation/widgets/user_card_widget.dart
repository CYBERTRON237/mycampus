import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserCardWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onAssignRole;

  const UserCardWidget({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onAssignRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getRoleColor(user.primaryRole),
                    child: Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (user.matricule != null)
                          Text(
                            'Mat: ${user.matricule}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Status indicators
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Online status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: user.isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isOnline ? 'En ligne' : 'Hors ligne',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Account status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(user.accountStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusLabel(user.accountStatus),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Role and institution info
              Row(
                children: [
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.primaryRole).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRoleColor(user.primaryRole).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      user.roleDisplayName ?? user.primaryRole,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRoleColor(user.primaryRole),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  if (user.institutionName != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.institutionName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              
              if (user.departmentName != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.departmentName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action buttons
              if (onEdit != null || onDelete != null || onToggleStatus != null || onAssignRole != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onToggleStatus != null)
                      TextButton.icon(
                        onPressed: onToggleStatus,
                        icon: Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                          size: 16,
                        ),
                        label: Text(user.isActive ? 'Désactiver' : 'Activer'),
                        style: TextButton.styleFrom(
                          foregroundColor: user.isActive ? Colors.orange : Colors.green,
                        ),
                      ),
                    
                    if (onAssignRole != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onAssignRole,
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Rôle'),
                      ),
                    ],
                    
                    if (onEdit != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Modifier'),
                      ),
                    ],
                    
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Colors.purple;
      case 'admin_national':
        return Colors.red;
      case 'admin_local':
        return Colors.deepOrange;
      case 'leader':
        return Colors.indigo;
      case 'teacher':
        return Colors.blue;
      case 'staff':
        return Colors.teal;
      case 'moderator':
        return Colors.amber;
      case 'alumni':
        return Colors.brown;
      case 'student':
        return Colors.green;
      case 'guest':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.orange;
      case 'banned':
        return Colors.red;
      case 'pending_verification':
        return Colors.blue;
      case 'graduated':
        return Colors.purple;
      case 'withdrawn':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      case 'suspended':
        return 'Suspendu';
      case 'banned':
        return 'Banni';
      case 'pending_verification':
        return 'En attente';
      case 'graduated':
        return 'Diplômé';
      case 'withdrawn':
        return 'Retiré';
      default:
        return status;
    }
  }
}
