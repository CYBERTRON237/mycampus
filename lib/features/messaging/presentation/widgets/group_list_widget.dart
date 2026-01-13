import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/group_model.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class GroupListWidget extends StatelessWidget {
  final List<GroupModel> groups;
  final bool isLoading;
  final Function(GroupModel) onGroupTap;
  final Function(GroupModel) onGroupLongPress;
  final Function() onCreateGroup;

  const GroupListWidget({
    super.key,
    required this.groups,
    this.isLoading = false,
    required this.onGroupTap,
    required this.onGroupLongPress,
    required this.onCreateGroup,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Column(
      children: [
        // En-tête avec bouton créer
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Groupes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: onCreateGroup,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Créer'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Liste des groupes avec Expanded pour occuper l'espace disponible
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : groups.isEmpty
                  ? _buildEmptyState(context, isDarkMode)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return _buildGroupTile(context, group, isDarkMode);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: isDarkMode ? AppColors.textLight : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun groupe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? AppColors.textLight : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier groupe pour commencer',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.textLight : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateGroup,
            icon: const Icon(Icons.add),
            label: const Text('Créer un groupe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, GroupModel group, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.grey[300],
          backgroundImage: group.avatarUrl != null
              ? NetworkImage(group.avatarUrl!)
              : null,
          child: group.avatarUrl == null
              ? Text(
                  _getGroupInitials(group.name),
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textOnPrimary : AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                group.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            if (group.isOfficial)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Officiel',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description != null) ...[
              const SizedBox(height: 2),
              Text(
                group.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 14,
                  color: isDarkMode ? AppColors.textLight : Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  '${group.currentMembersCount} membres',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.textLight : Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _getVisibilityIcon(group.visibility),
                  size: 14,
                  color: isDarkMode ? AppColors.textLight : Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _getVisibilityDisplayName(group.visibility),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppColors.textLight : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatLastMessageTime(group.updatedAt),
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? AppColors.textLight : Colors.grey[500],
              ),
            ),
            if (group.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  group.unreadCount > 99 ? '99+' : group.unreadCount.toString(),
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
        onTap: () => onGroupTap(group),
        onLongPress: () => onGroupLongPress(group),
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

  IconData _getVisibilityIcon(GroupVisibility visibility) {
    switch (visibility) {
      case GroupVisibility.public:
        return Icons.public;
      case GroupVisibility.private:
        return Icons.lock;
      case GroupVisibility.secret:
        return Icons.visibility_off;
      case GroupVisibility.restricted:
        return Icons.security;
      case GroupVisibility.official:
        return Icons.verified;
    }
    return Icons.group; // Default fallback
  }

  String _getVisibilityDisplayName(GroupVisibility visibility) {
    switch (visibility) {
      case GroupVisibility.public:
        return 'Public';
      case GroupVisibility.private:
        return 'Privé';
      case GroupVisibility.secret:
        return 'Secret';
      case GroupVisibility.restricted:
        return 'Restreint';
      case GroupVisibility.official:
        return 'Officiel';
    }
    return 'Inconnu'; // Default fallback
  }

  String _formatLastMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} j';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
