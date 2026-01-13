import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/notifications/providers/notification_provider.dart';
import 'package:mycampus/features/notifications/domain/entities/notification.dart' as notif_entity;
import 'package:mycampus/core/providers/theme_provider.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  String? _selectedType;
  bool? _isReadFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Delay provider access to after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final provider = context.read<NotificationProvider>();
          provider.refresh();
          print('DEBUG: NotificationListPage - Provider accessed successfully');
        } catch (e) {
          print('ERROR: NotificationListPage - Failed to access provider: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDarkTheme = themeProvider.isDarkTheme;
        
        return Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return Scaffold(
              backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : Colors.grey.shade50,
              appBar: AppBar(
                title: Row(
                  children: [
                    const Text('Notifications'),
                    if (provider.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          provider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkTheme 
                        ? [Colors.cyan, Colors.blue]
                        : [Colors.blue, Colors.cyan],
                    ),
                  ),
                ),
                actions: [
                  if (provider.unreadCount > 0)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'mark_all_read') {
                          provider.markAllAsRead();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'mark_all_read',
                          child: Text('Marquer tout comme lu'),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.refresh(),
                  ),
                ],
              ),
              body: Builder(
                builder: (context) {
                  print('DEBUG: NotificationListPage - Consumer build - provider found successfully');
                  
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.error != null && provider.notifications.isEmpty) {
                    return Center(
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
                            'Erreur',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.refresh(),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Filters
                      _buildFilters(context, provider, isDarkTheme),
                      
                      // Results
                      Expanded(
                        child: provider.notifications.isEmpty
                            ? _buildEmptyState(context, isDarkTheme)
                            : _buildNotificationsList(context, provider, isDarkTheme),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, NotificationProvider provider, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey.shade800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter chips row
          Wrap(
            spacing: 8,
            children: [
              // Read status filter
              FilterChip(
                label: const Text('Non lus'),
                selected: _isReadFilter == false,
                onSelected: (selected) {
                  setState(() => _isReadFilter = selected ? false : null);
                  provider.filterByReadStatus(_isReadFilter);
                },
              ),
              
              // Category filters
              FilterChip(
                label: const Text('System'),
                selected: _selectedCategory == 'system',
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? 'system' : null);
                  provider.filterByCategory(_selectedCategory);
                },
              ),
              
              FilterChip(
                label: const Text('Messages'),
                selected: _selectedCategory == 'message',
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? 'message' : null);
                  provider.filterByCategory(_selectedCategory);
                },
              ),
              
              FilterChip(
                label: const Text('Académique'),
                selected: _selectedCategory == 'academic',
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? 'academic' : null);
                  provider.filterByCategory(_selectedCategory);
                },
              ),
              
              FilterChip(
                label: const Text('Annonces'),
                selected: _selectedCategory == 'announcement',
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? 'announcement' : null);
                  provider.filterByCategory(_selectedCategory);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Clear filters button
          if (_selectedCategory != null || _selectedType != null || _isReadFilter != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedType = null;
                      _isReadFilter = null;
                    });
                    provider.clearFilters();
                  },
                  child: const Text('Effacer les filtres'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez aucune notification pour le moment',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationProvider provider, bool isDarkTheme) {
    return RefreshIndicator(
      onRefresh: () async => provider.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.notifications.length && provider.hasMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final notification = provider.notifications[index];
          return _buildNotificationCard(context, notification, isDarkTheme);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, notif_entity.Notification notification, bool isDarkTheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 4,
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationProvider>().markAsRead(notification.id!);
          }
          _showNotificationDetails(context, notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead 
              ? Border.all(color: Colors.grey.shade300)
              : Border.all(color: Colors.blue.shade300, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    _buildPriorityChip(notification.priority),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Content
                Text(
                  notification.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Footer with actor, category and time
                Row(
                  children: [
                    if (notification.actorName != null) ...[
                      Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        notification.actorName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      notification.category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                if (!notification.isRead) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.read<NotificationProvider>().markAsRead(notification.id!),
                        child: const Text('Marquer comme lu'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(notif_entity.NotificationPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case notif_entity.NotificationPriority.urgent:
        color = Colors.red;
        label = 'Urgent';
        break;
      case notif_entity.NotificationPriority.high:
        color = Colors.orange;
        label = 'Important';
        break;
      case notif_entity.NotificationPriority.normal:
        color = Colors.blue;
        label = 'Normal';
        break;
      case notif_entity.NotificationPriority.low:
        color = Colors.grey;
        label = 'Faible';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showNotificationDetails(BuildContext context, notif_entity.Notification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (notification.actorName != null) ...[
                Text('De: ${notification.actorName}'),
                const SizedBox(height: 8),
              ],
              Text(notification.content),
              if (notification.actionUrl != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to action URL
                  },
                  child: const Text('Voir les détails'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!notification.isRead)
            TextButton(
              onPressed: () {
                context.read<NotificationProvider>().markAsRead(notification.id!);
                Navigator.pop(context);
              },
              child: const Text('Marquer comme lu'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
