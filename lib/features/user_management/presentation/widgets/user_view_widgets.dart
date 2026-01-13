import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserGridView extends StatefulWidget {
  final List<UserModel> users;
  final Function(UserModel) onTap;
  final Function(UserModel)? onEdit;
  final Function(UserModel)? onDelete;
  final Function(UserModel)? onToggleStatus;
  final Function(UserModel)? onAssignRole;
  final bool allowSelection;
  final Function(UserModel, bool)? onSelectionChanged;
  final Set<int> selectedUsers;

  const UserGridView({
    super.key,
    required this.users,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onAssignRole,
    this.allowSelection = false,
    this.onSelectionChanged,
    this.selectedUsers = const {},
  });

  @override
  State<UserGridView> createState() => _UserGridViewState();
}

class _UserGridViewState extends State<UserGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.users.length,
      itemBuilder: (context, index) {
        final user = widget.users[index];
        final isSelected = widget.selectedUsers.contains(user.id);
        
        return UserGridCard(
          user: user,
          onTap: () => widget.onTap(user),
          onEdit: widget.onEdit != null ? () => widget.onEdit!(user) : null,
          onDelete: widget.onDelete != null ? () => widget.onDelete!(user) : null,
          onToggleStatus: widget.onToggleStatus != null ? () => widget.onToggleStatus!(user) : null,
          onAssignRole: widget.onAssignRole != null ? () => widget.onAssignRole!(user) : null,
          isSelected: isSelected,
          allowSelection: widget.allowSelection,
          onSelectionChanged: widget.allowSelection && widget.onSelectionChanged != null
              ? (bool? selected) => widget.onSelectionChanged!(user, selected ?? false)
              : null,
        );
      },
    );
  }
}

class UserGridCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onAssignRole;
  final bool isSelected;
  final bool allowSelection;
  final ValueChanged<bool?>? onSelectionChanged;

  const UserGridCard({
    super.key,
    required this.user,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onAssignRole,
    this.isSelected = false,
    this.allowSelection = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and selection
              Row(
                children: [
                  // Selection checkbox
                  if (allowSelection)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: onSelectionChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  
                  // Avatar
                  Expanded(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: _getRoleColor(user.primaryRole),
                      child: Text(
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(user.accountStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // User name
              Text(
                user.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Email
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Role and institution
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.primaryRole).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getRoleDisplayName(user.primaryRole),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(user.primaryRole),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (user.institutionName != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.institutionName!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onToggleStatus != null)
                    _buildActionButton(
                      context,
                      user.isActive ? Icons.block : Icons.check_circle,
                      user.isActive ? Colors.orange : Colors.green,
                      onToggleStatus!,
                      tooltip: user.isActive ? 'Désactiver' : 'Activer',
                    ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 4),
                    _buildActionButton(
                      context,
                      Icons.edit,
                      Colors.blue,
                      onEdit!,
                      tooltip: 'Modifier',
                    ),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    _buildActionButton(
                      context,
                      Icons.delete,
                      Colors.red,
                      onDelete!,
                      tooltip: 'Supprimer',
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

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    String? tooltip,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
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
        return 'Teacher';
      case 'staff':
        return 'Staff';
      case 'moderator':
        return 'Moderator';
      case 'student':
        return 'Student';
      default:
        return role;
    }
  }
}

class UserCompactListView extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onTap;
  final Function(UserModel)? onEdit;
  final Function(UserModel)? onDelete;
  final Function(UserModel)? onToggleStatus;
  final Function(UserModel)? onAssignRole;
  final bool allowSelection;
  final Function(UserModel, bool)? onSelectionChanged;
  final Set<int> selectedUsers;

  const UserCompactListView({
    super.key,
    required this.users,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onAssignRole,
    this.allowSelection = false,
    this.onSelectionChanged,
    this.selectedUsers = const {},
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = selectedUsers.contains(user.id);
        
        return UserCompactListTile(
          user: user,
          onTap: () => onTap(user),
          onEdit: onEdit != null ? () => onEdit!(user) : null,
          onDelete: onDelete != null ? () => onDelete!(user) : null,
          onToggleStatus: onToggleStatus != null ? () => onToggleStatus!(user) : null,
          onAssignRole: onAssignRole != null ? () => onAssignRole!(user) : null,
          isSelected: isSelected,
          allowSelection: allowSelection,
          onSelectionChanged: allowSelection && onSelectionChanged != null
              ? (bool? selected) => onSelectionChanged!(user, selected ?? false)
              : null,
        );
      },
    );
  }
}

class UserCompactListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onAssignRole;
  final bool isSelected;
  final bool allowSelection;
  final ValueChanged<bool?>? onSelectionChanged;

  const UserCompactListTile({
    super.key,
    required this.user,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onAssignRole,
    this.isSelected = false,
    this.allowSelection = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection checkbox
            if (allowSelection)
              Checkbox(
                value: isSelected,
                onChanged: onSelectionChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: _getRoleColor(user.primaryRole),
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(user.primaryRole, _getRoleColor(user.primaryRole)),
                const SizedBox(width: 4),
                _buildStatusChip(user.accountStatus, _getStatusColor(user.accountStatus)),
                if (user.institutionName != null) ...[
                  const SizedBox(width: 4),
                  _buildStatusChip(user.institutionName!, Colors.grey),
                ],
              ],
            ),
          ],
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(user.accountStatus),
                shape: BoxShape.circle,
              ),
            ),
            
            // Action menu
            if (onEdit != null || onDelete != null || onToggleStatus != null)
              PopupMenuButton<String>(
                onSelected: (action) => _handleAction(context, action),
                itemBuilder: (context) => [
                  if (onEdit != null)
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
                  if (onToggleStatus != null)
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block : Icons.check_circle,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Désactiver' : 'Activer'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
        
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
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

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'toggle':
        onToggleStatus?.call();
        break;
      case 'delete':
        onDelete?.call();
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

class ViewModeToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onModeChanged;

  const ViewModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            context,
            'Liste',
            Icons.view_list,
            ViewMode.list,
          ),
          _buildModeButton(
            context,
            'Grille',
            Icons.grid_view,
            ViewMode.grid,
          ),
          _buildModeButton(
            context,
            'Compact',
            Icons.view_list,
            ViewMode.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    IconData icon,
    ViewMode mode,
  ) {
    final isSelected = currentMode == mode;
    
    return Material(
      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onModeChanged(mode),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ViewMode {
  list,
  grid,
  compact,
}
