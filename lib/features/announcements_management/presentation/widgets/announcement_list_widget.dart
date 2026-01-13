import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../providers/announcement_provider.dart';

class AnnouncementListWidget extends StatelessWidget {
  const AnnouncementListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.announcements.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.announcements.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune annonce',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez par créer votre première annonce',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            _buildFilters(context, provider),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = provider.announcements[index];
                    return _buildAnnouncementCard(context, announcement, provider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, AnnouncementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une annonce...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => provider.searchAnnouncements(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => provider.searchAnnouncements(value),
          ),
          const SizedBox(height: 12),
          
          // Filtres
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: provider.selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Toutes')),
                    DropdownMenuItem(value: 'academic', child: Text('Académique')),
                    DropdownMenuItem(value: 'administrative', child: Text('Administrative')),
                    DropdownMenuItem(value: 'event', child: Text('Événement')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.filterByCategory(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: provider.selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priorité',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Toutes')),
                    DropdownMenuItem(value: 'low', child: Text('Basse')),
                    DropdownMenuItem(value: 'normal', child: Text('Normale')),
                    DropdownMenuItem(value: 'high', child: Text('Haute')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.filterByPriority(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: provider.resetFilters,
                icon: const Icon(Icons.refresh),
                tooltip: 'Réinitialiser les filtres',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementModel announcement, AnnouncementProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAnnouncementDetail(context, announcement),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPriorityIcon(announcement.priority),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCategoryChip(announcement.category),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                announcement.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.authorName ?? 'Admin',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(announcement.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.viewsCount}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(AnnouncementPriority? priority) {
    IconData icon;
    Color color;
    
    switch (priority) {
      case AnnouncementPriority.urgent:
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      case AnnouncementPriority.high:
        icon = Icons.arrow_upward;
        color = Colors.orange;
        break;
      case AnnouncementPriority.normal:
        icon = Icons.remove;
        color = Colors.yellow.shade700;
        break;
      case AnnouncementPriority.low:
        icon = Icons.arrow_downward;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildCategoryChip(AnnouncementCategory? category) {
    Color color;
    String label;
    
    switch (category) {
      case AnnouncementCategory.academic:
        color = Colors.blue;
        label = 'Académique';
        break;
      case AnnouncementCategory.administrative:
        color = Colors.purple;
        label = 'Administrative';
        break;
      case AnnouncementCategory.event:
        color = Colors.green;
        label = 'Événement';
        break;
      case AnnouncementCategory.urgent:
        color = Colors.red;
        label = 'Urgent';
        break;
      case AnnouncementCategory.exam:
        color = Colors.orange;
        label = 'Examen';
        break;
      case AnnouncementCategory.registration:
        color = Colors.teal;
        label = 'Inscription';
        break;
      case AnnouncementCategory.scholarship:
        color = Colors.amber;
        label = 'Bourse';
        break;
      case AnnouncementCategory.alert:
        color = Colors.red;
        label = 'Alerte';
        break;
      case AnnouncementCategory.general:
        color = Colors.blueGrey;
        label = 'Général';
        break;
      case AnnouncementCategory.emergency:
        color = Colors.red;
        label = 'Urgence';
        break;
      default:
        color = Colors.grey;
        label = 'Autre';
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
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  void _showAnnouncementDetail(BuildContext context, AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => _buildSimpleDetailDialog(context, announcement),
    );
  }

  Widget _buildSimpleDetailDialog(BuildContext context, AnnouncementModel announcement) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.campaign,
                    color: Colors.blue.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  announcement.content,
                  style: const TextStyle(height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(announcement.authorName ?? 'Admin'),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(_formatDate(announcement.createdAt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
