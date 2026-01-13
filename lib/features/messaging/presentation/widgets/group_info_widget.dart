import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/group_model.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class GroupInfoWidget extends StatelessWidget {
  final GroupModel group;
  final List<GroupMemberModel> members;
  final VoidCallback onClose;

  const GroupInfoWidget({
    super.key,
    required this.group,
    required this.members,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.divider : Colors.grey[300]!,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                      ),
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.currentMembersCount} membres',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          _getVisibilityIcon(group.visibility),
                          size: 16,
                          color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getVisibilityDisplayName(group.visibility),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                ),
                onPressed: onClose,
              ),
            ],
          ),
          
          if (members.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: members.length > 10 ? 11 : members.length,
                itemBuilder: (context, index) {
                  if (index == 10 && members.length > 10) {
                    return _buildMoreMembersWidget(context, members.length - 10);
                  }
                  
                  final member = members[index];
                  return _buildMemberAvatar(context, member);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(BuildContext context, GroupMemberModel member) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.grey[300],
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    _getMemberInitials(member.fullName ?? 'Utilisateur ${member.userId}'),
                    style: TextStyle(
                      color: isDarkMode ? AppColors.textOnPrimary : AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            child: Text(
              member.fullName?.split(' ').first ?? 'User',
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreMembersWidget(BuildContext context, int remainingCount) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plus',
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
            ),
          ),
        ],
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

  String _getMemberInitials(String fullName) {
    final words = fullName.split(' ');
    if (words.length >= 2) {
      return words[0][0] + words[1][0];
    }
    return fullName.substring(0, fullName.length >= 2 ? 2 : fullName.length);
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
}
