import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';
import 'package:mycampus/features/student_management/providers/enhanced_student_provider.dart';

class EnhancedStudentCard extends StatelessWidget {
  final EnhancedStudentModel student;
  final StudentViewMode viewMode;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onQuickAction;

  const EnhancedStudentCard({
    super.key,
    required this.student,
    this.viewMode = StudentViewMode.list,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onSelectionChanged,
    this.onEdit,
    this.onDelete,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewMode) {
      case StudentViewMode.grid:
        return _buildGridCard(context);
      case StudentViewMode.compact:
        return _buildCompactCard(context);
      case StudentViewMode.cards:
        return _buildCardView(context);
      case StudentViewMode.list:
      default:
        return _buildListCard(context);
    }
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Selection checkbox
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        onSelectionChanged?.call(value ?? false);
                      },
                    ),
                  ),
                
                // Profile photo
                CircleAvatar(
                  radius: 24,
                  backgroundImage: student.profilePhotoUrl != null
                      ? NetworkImage(student.profilePhotoUrl!)
                      : null,
                  child: student.profilePhotoUrl == null
                      ? Text(
                          student.firstName.isNotEmpty 
                              ? student.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                
                const SizedBox(width: 12),
                
                // Student info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.fullName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusChip(context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.matricule,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${student.levelLabel} • ${student.institutionDisplay}',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              student.email,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (student.gpa != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getGpaColor(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'GPA: ${student.gpaDisplay}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Quick actions
                if (!isSelectionMode)
                  PopupMenuButton<String>(
                    onSelected: (action) => onQuickAction?.call(action),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Voir détails'),
                          ],
                        ),
                      ),
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: student.isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(
                              student.isActive ? Icons.block : Icons.check,
                              color: student.isActive ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              student.isActive ? 'Désactiver' : 'Activer',
                              style: TextStyle(
                                color: student.isActive ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with photo and selection
                Row(
                  children: [
                    if (isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            onSelectionChanged?.call(value ?? false);
                          },
                        ),
                      ),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: student.profilePhotoUrl != null
                          ? NetworkImage(student.profilePhotoUrl!)
                          : null,
                      child: student.profilePhotoUrl == null
                          ? Text(
                              student.firstName.isNotEmpty 
                                  ? student.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const Spacer(),
                    _buildStatusChip(context),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Name and matricule
                Text(
                  student.fullName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  student.matricule,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Level and institution
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.levelLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.institutionDisplay,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // GPA indicator
                if (student.gpa != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGpaColor(context),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'GPA: ${student.gpaDisplay}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4.0),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Selection checkbox
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        onSelectionChanged?.call(value ?? false);
                      },
                    ),
                  ),
                
                // Avatar
                CircleAvatar(
                  radius: 16,
                  backgroundImage: student.profilePhotoUrl != null
                      ? NetworkImage(student.profilePhotoUrl!)
                      : null,
                  child: student.profilePhotoUrl == null
                      ? Text(
                          student.firstName.isNotEmpty 
                              ? student.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                
                const SizedBox(width: 8),
                
                // Student info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.fullName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(context),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            student.matricule,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            student.levelLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (student.gpa != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'GPA: ${student.gpaDisplay}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getGpaColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Quick actions
                if (!isSelectionMode)
                  PopupMenuButton<String>(
                    onSelected: (action) => onQuickAction?.call(action),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('Voir')),
                      if (onEdit != null)
                        const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      if (onDelete != null)
                        const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardView(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected 
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with background
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Cover photo placeholder or pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    
                    // Profile photo and status
                    Positioned(
                      left: 16,
                      bottom: -30,
                      child: Row(
                        children: [
                          if (isSelectionMode)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  onSelectionChanged?.call(value ?? false);
                                },
                              ),
                            ),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: student.profilePhotoUrl != null
                                ? NetworkImage(student.profilePhotoUrl!)
                                : null,
                            backgroundColor: Colors.white,
                            child: student.profilePhotoUrl == null
                                ? Text(
                                    student.firstName.isNotEmpty 
                                        ? student.firstName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                    
                    // Status chip
                    Positioned(
                      right: 16,
                      top: 16,
                      child: _buildStatusChip(context),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and matricule
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      student.matricule,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Academic info
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${student.levelLabel} • ${student.institutionDisplay}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            student.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            student.phone ?? 'Non renseigné',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Stats row
                    Row(
                      children: [
                        if (student.gpa != null)
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'GPA',
                              student.gpaDisplay,
                              _getGpaColor(context),
                            ),
                          ),
                        if (student.gpa != null)
                          const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Crédits',
                            '${student.totalCreditsEarned}',
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Progression',
                            '${student.progressPercentage.toStringAsFixed(0)}%',
                            _getProgressColor(context),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action buttons
                    if (!isSelectionMode)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => onQuickAction?.call('view'),
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('Voir'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (onEdit != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Modifier'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (student.status) {
      case StudentStatus.enrolled:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case StudentStatus.graduated:
        color = Colors.blue;
        icon = Icons.school;
        break;
      case StudentStatus.suspended:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case StudentStatus.withdrawn:
        color = Colors.red;
        icon = Icons.exit_to_app;
        break;
      case StudentStatus.deferred:
        color = Colors.purple;
        icon = Icons.schedule;
        break;
      case StudentStatus.onLeave:
        color = Colors.teal;
        icon = Icons.beach_access;
        break;
      case StudentStatus.expelled:
        color = Colors.red.shade900;
        icon = Icons.block;
        break;
      case StudentStatus.deceased:
        color = Colors.grey;
        icon = Icons.memory;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            student.statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGpaColor(BuildContext context) {
    if (student.gpa == null) return Colors.grey;
    
    final gpa = student.gpa!;
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.blue;
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }

  Color _getProgressColor(BuildContext context) {
    final progress = student.progressPercentage;
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.blue;
    if (progress >= 40) return Colors.orange;
    return Colors.red;
  }
}
