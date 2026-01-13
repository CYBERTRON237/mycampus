import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import '../models/navigation_item_model.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/models/user_model.dart';

class ComprehensiveNavigationDrawer extends StatefulWidget {
  final String? currentRoute;
  final Function(NavigationItem)? onItemSelected;

  const ComprehensiveNavigationDrawer({
    Key? key,
    this.currentRoute,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<ComprehensiveNavigationDrawer> createState() => _ComprehensiveNavigationDrawerState();
}

class _ComprehensiveNavigationDrawerState extends State<ComprehensiveNavigationDrawer> {
  String? _expandedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final userRole = user?.role ?? 'user';
    
    // Obtenir les items de navigation selon le rôle
    final navigationItems = NavigationService.getNavigationItemsForRole(userRole);
    final categories = NavigationService.getAllCategories();
    final categoryLabels = NavigationService.getCategoryLabels();

    return Drawer(
      child: Column(
        children: [
          // Header avec info utilisateur
          _buildUserHeader(user),
          
          // Barre de recherche
          _buildSearchBar(),
          
          // Liste de navigation
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryItems = navigationItems
                    .where((item) => item.category != null && item.category == category)
                    .toList();
                
                if (categoryItems.isEmpty) return const SizedBox.shrink();
                
                return _buildCategorySection(
                  category,
                  categoryLabels[category] ?? category,
                  categoryItems,
                );
              },
            ),
          ),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(UserModel? user) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        user?.firstName != null && user?.lastName != null
            ? '${user!.firstName} ${user.lastName}'
            : 'Utilisateur',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        user?.email ?? 'user@example.com',
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: user?.avatarUrl != null
            ? ClipOval(
                child: Image.network(
                  user!.avatarUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, size: 30, color: Colors.blue.shade800);
                  },
                ),
              )
            : Icon(Icons.person, size: 30, color: Colors.blue.shade800),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un module...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) {
          // Implémenter la recherche
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, String title, List<NavigationItem> items) {
    return ExpansionTile(
      key: PageStorageKey<String>(category),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
          fontSize: 14,
        ),
      ),
      leading: Icon(
        _getCategoryIcon(category),
        color: Colors.blue.shade600,
      ),
      initiallyExpanded: category == 'principal' || category == 'academique',
      onExpansionChanged: (expanded) {
        setState(() {
          _expandedCategory = expanded ? category : null;
        });
      },
      children: items.map((item) => _buildNavigationItem(item)).toList(),
    );
  }

  Widget _buildNavigationItem(NavigationItem item) {
    final isSelected = widget.currentRoute == item.route;
    
    return ListTile(
      leading: Icon(
        _getIconData(item.icon),
        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
        size: 20,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: isSelected ? Colors.blue.shade800 : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: item.subItems != null && item.subItems!.isNotEmpty
          ? Icon(Icons.arrow_drop_down, color: Colors.grey.shade400)
          : null,
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      onTap: () {
        Navigator.pop(context);
        if (widget.onItemSelected != null) {
          widget.onItemSelected!(item);
        }
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Paramètres', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/support');
                },
                icon: const Icon(Icons.help, size: 16),
                label: const Text('Aide', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'MyCampus v1.0.0',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard': return Icons.dashboard;
      case 'book': return Icons.book;
      case 'school': return Icons.school;
      case 'business': return Icons.business;
      case 'account_balance': return Icons.account_balance;
      case 'how_to_reg': return Icons.how_to_reg;
      case 'chat': return Icons.chat;
      case 'notifications': return Icons.notifications;
      case 'campaign': return Icons.campaign;
      case 'people': return Icons.people;
      case 'apartment': return Icons.apartment;
      case 'person': return Icons.person;
      case 'settings': return Icons.settings;
      case 'analytics': return Icons.analytics;
      case 'assessment': return Icons.assessment;
      case 'security': return Icons.security;
      case 'fact_check': return Icons.fact_check;
      case 'support_agent': return Icons.support_agent;
      case 'help': return Icons.help;
      case 'folder': return Icons.folder;
      case 'backup': return Icons.backup;
      case 'swap_vert': return Icons.swap_vert;
      default: return Icons.apps;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'principal': return Icons.home;
      case 'academique': return Icons.school;
      case 'communication': return Icons.chat;
      case 'administration': return Icons.admin_panel_settings;
      case 'utilisateur': return Icons.person;
      case 'rapports': return Icons.analytics;
      case 'support': return Icons.support_agent;
      case 'utilitaires': return Icons.build;
      default: return Icons.category;
    }
  }
}
