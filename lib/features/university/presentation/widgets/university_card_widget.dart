import 'package:flutter/material.dart';
import '../../domain/models/university_model.dart';

class UniversityCardWidget extends StatelessWidget {
  final UniversityModel university;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onVerify;

  const UniversityCardWidget({
    super.key,
    required this.university,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo ou icône par défaut
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: university.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              university.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.school,
                                  size: 30,
                                  color: Colors.grey[600],
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.school,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                university.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (university.isNationalHub)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          university.shortName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(university.status),
                            const SizedBox(width: 8),
                            _buildTypeChip(university.type),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                        case 'toggle_status':
                          onToggleStatus?.call();
                          break;
                        case 'verify':
                          onVerify?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'toggle_status',
                        child: Row(
                          children: [
                            Icon(Icons.toggle_on, size: 20),
                            SizedBox(width: 8),
                            Text('Changer statut'),
                          ],
                        ),
                      ),
                      if (!university.isNationalHub)
                        const PopupMenuItem(
                          value: 'verify',
                          child: Row(
                            children: [
                              Icon(Icons.verified, size: 20),
                              SizedBox(width: 8),
                              Text('Vérifier'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (university.description != null)
                Text(
                  university.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (university.city != null)
                    _buildInfoItem(Icons.location_on, university.city!),
                  if (university.region != null) ...[
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.map, university.region!),
                  ],
                  if (university.totalStudents > 0) ...[
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.people, '${university.totalStudents} étudiants'),
                  ],
                ],
              ),
              if (university.website != null || university.emailOfficial != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (university.website != null)
                      Expanded(
                        child: _buildContactItem(Icons.language, university.website!),
                      ),
                    if (university.emailOfficial != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildContactItem(Icons.email, university.emailOfficial!),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(UniversityStatus status) {
    Color color = Colors.grey;
    String label = 'Inconnu';
    
    switch (status) {
      case UniversityStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case UniversityStatus.inactive:
        color = Colors.grey;
        label = 'Inactive';
        break;
      case UniversityStatus.suspended:
        color = Colors.red;
        label = 'Suspendu';
        break;
      case UniversityStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeChip(UniversityType type) {
    Color color = Colors.blue;
    String label = 'Inconnu';
    
    switch (type) {
      case UniversityType.public:
        color = Colors.blue;
        label = 'Publique';
        break;
      case UniversityType.private:
        color = Colors.purple;
        label = 'Privée';
        break;
      case UniversityType.confessional:
        color = Colors.orange;
        label = 'Confessionnelle';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
