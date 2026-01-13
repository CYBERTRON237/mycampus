import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class BulkActionsWidget extends StatefulWidget {
  final List<UserModel> selectedUsers;
  final Function(List<UserModel>) onSelectionChanged;
  final VoidCallback? onExportSelected;
  final VoidCallback? onActivateSelected;
  final VoidCallback? onDeactivateSelected;
  final VoidCallback? onDeleteSelected;

  const BulkActionsWidget({
    super.key,
    required this.selectedUsers,
    required this.onSelectionChanged,
    this.onExportSelected,
    this.onActivateSelected,
    this.onDeactivateSelected,
    this.onDeleteSelected,
  });

  @override
  State<BulkActionsWidget> createState() => _BulkActionsWidgetState();
}

class _BulkActionsWidgetState extends State<BulkActionsWidget> {
  bool _isAllSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with selection controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Select all checkbox
                Checkbox(
                  value: _isAllSelected,
                  onChanged: (value) {
                    setState(() {
                      _isAllSelected = value ?? false;
                    });
                    _handleSelectAll(_isAllSelected);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Sélection multiple',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (widget.selectedUsers.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${widget.selectedUsers.length} sélectionné(s)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Bulk action buttons
          if (widget.selectedUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions groupées',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionButton(
                        context,
                        'Exporter',
                        Icons.download,
                        Colors.blue,
                        widget.onExportSelected,
                      ),
                      _buildActionButton(
                        context,
                        'Activer',
                        Icons.check_circle,
                        Colors.green,
                        widget.onActivateSelected,
                      ),
                      _buildActionButton(
                        context,
                        'Désactiver',
                        Icons.block,
                        Colors.orange,
                        widget.onDeactivateSelected,
                      ),
                      _buildActionButton(
                        context,
                        'Supprimer',
                        Icons.delete,
                        Colors.red,
                        widget.onDeleteSelected,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Selection summary
          if (widget.selectedUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildSelectionSummary(context),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    final activeCount = widget.selectedUsers.where((u) => u.isActive).length;
    final inactiveCount = widget.selectedUsers.length - activeCount;
    
    final roleDistribution = <String, int>{};
    for (final user in widget.selectedUsers) {
      roleDistribution[user.primaryRole] = (roleDistribution[user.primaryRole] ?? 0) + 1;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé de la sélection',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Status breakdown
        Row(
          children: [
            _buildSummaryChip('Actifs', activeCount, Colors.green),
            const SizedBox(width: 8),
            _buildSummaryChip('Inactifs', inactiveCount, Colors.red),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Role breakdown
        Text(
          'Par rôle:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: roleDistribution.entries.map((entry) {
            return Chip(
              label: Text('${_getRoleDisplayName(entry.key)}: ${entry.value}'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleSelectAll(bool selectAll) {
    // This would need access to all users to select/deselect all
    // For now, we'll just notify the parent
    if (selectAll) {
      // In a real implementation, you'd pass all users here
      widget.onSelectionChanged([]);
    } else {
      widget.onSelectionChanged([]);
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Admin';
      case 'admin_national':
        return 'Admin National';
      case 'admin_local':
        return 'Admin Local';
      case 'leader':
        return 'Leader';
      case 'teacher':
        return 'Enseignant';
      case 'staff':
        return 'Personnel';
      case 'moderator':
        return 'Modérateur';
      case 'student':
        return 'Étudiant';
      default:
        return role;
    }
  }
}

class BulkActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final Color actionColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const BulkActionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(actionIcon, color: actionColor),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: actionColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: actionColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cette action affectera tous les utilisateurs sélectionnés.',
                    style: TextStyle(
                      color: actionColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
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
          onPressed: onCancel,
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: onConfirm,
          icon: Icon(actionIcon, size: 16),
          label: Text(actionLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class ExportProgressDialog extends StatefulWidget {
  final int totalUsers;
  final Function(double) onProgress;
  final VoidCallback onComplete;
  final Function(String) onError;

  const ExportProgressDialog({
    super.key,
    required this.totalUsers,
    required this.onProgress,
    required this.onComplete,
    required this.onError,
  });

  @override
  State<ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<ExportProgressDialog> {
  double _progress = 0.0;
  bool _isCompleted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _simulateExport();
  }

  void _simulateExport() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _progress = i / 100.0;
        });
        widget.onProgress(_progress);
      }
    }
    
    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download),
          SizedBox(width: 8),
          Text('Exportation en cours'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          Text(
            'Exportation de ${widget.totalUsers} utilisateur(s)...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${(_progress * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        if (_isCompleted)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
      ],
    );
  }
}

class UserSelectionWidget extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectionChanged;
  final VoidCallback? onTap;
  final bool compact;

  const UserSelectionWidget({
    super.key,
    required this.user,
    required this.isSelected,
    this.onSelectionChanged,
    this.onTap,
    this.compact = false,
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
    switch (action) {
      case 'view':
        // Navigate to user details
        break;
      case 'edit':
        // Navigate to edit user
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
