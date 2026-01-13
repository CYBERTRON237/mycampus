import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_management_provider.dart';
import '../../data/models/user_model.dart';
import '../widgets/user_card_widget.dart';
import '../widgets/user_stats_widget.dart';

class UserNavigationPage extends StatefulWidget {
  const UserNavigationPage({super.key});

  @override
  State<UserNavigationPage> createState() => _UserNavigationPageState();
}

class _UserNavigationPageState extends State<UserNavigationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _viewModeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModeController = TabController(length: 2, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().refreshUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Utilisateurs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Par Institution', icon: Icon(Icons.account_balance)),
            Tab(text: 'Par Département', icon: Icon(Icons.business)),
            Tab(text: 'Par Région', icon: Icon(Icons.location_on)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UserManagementProvider>().refreshUsers(),
            tooltip: 'Actualiser',
          ),
          Consumer<UserManagementProvider>(
            builder: (context, provider, child) {
              if (provider.canViewStats) {
                return IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: _showStatsDialog,
                  tooltip: 'Statistiques',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInstitutionView(),
          _buildDepartmentView(),
          _buildRegionView(),
        ],
      ),
    );
  }

  Widget _buildInstitutionView() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.refreshUsers();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        // Group users by institution
        final Map<String, List<UserModel>> institutionGroups = {};
        for (final user in provider.users) {
          final institution = user.institutionName ?? 'Non spécifié';
          institutionGroups.putIfAbsent(institution, () => []).add(user);
        }
        
        return Column(
          children: [
            // View mode toggle
            Container(
              padding: const EdgeInsets.all(16),
              child: TabBar(
                controller: _viewModeController,
                tabs: const [
                  Tab(text: 'Cartes', icon: Icon(Icons.view_module)),
                  Tab(text: 'Liste', icon: Icon(Icons.view_list)),
                ],
              ),
            ),
            
            // Institution cards
            Expanded(
              child: TabBarView(
                controller: _viewModeController,
                children: [
                  _buildInstitutionCards(provider.users),
                  _buildInstitutionList(provider.users),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstitutionCards(List<UserModel> users) {
    // Group users by institution
    final Map<String, List<UserModel>> institutionGroups = {};
    
    for (final user in users) {
      final institutionName = user.institutionName ?? 'Non spécifié';
      if (!institutionGroups.containsKey(institutionName)) {
        institutionGroups[institutionName] = [];
      }
      institutionGroups[institutionName]!.add(user);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: institutionGroups.keys.length,
      itemBuilder: (context, index) {
        final institutionName = institutionGroups.keys.elementAt(index);
        final institutionUsers = institutionGroups[institutionName]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${institutionUsers.length}',
                    style: const TextStyle(
                      color: Colors.white,
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
                        institutionName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${institutionUsers.where((u) => u.isActive).length} actifs / ${institutionUsers.length} total',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics for this institution
                    _buildInstitutionStats(institutionUsers),
                    
                    const SizedBox(height: 12),
                    
                    // User list for this institution
                    const Text(
                      'Utilisateurs:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...institutionUsers.take(5).map((user) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: UserCardWidget(
                        user: user,
                        onTap: () => _showUserDetails(user),
                      ),
                    )),
                    
                    if (institutionUsers.length > 5)
                      TextButton(
                        onPressed: () => _showAllInstitutionUsers(institutionName, institutionUsers),
                        child: Text('Voir tous les ${institutionUsers.length} utilisateurs'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstitutionList(List<UserModel> users) {
    final Map<String, List<UserModel>> institutionGroups = {};
    
    for (final user in users) {
      final institutionName = user.institutionName ?? 'Non spécifié';
      if (!institutionGroups.containsKey(institutionName)) {
        institutionGroups[institutionName] = [];
      }
      institutionGroups[institutionName]!.add(user);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: institutionGroups.keys.length,
      itemBuilder: (context, index) {
        final institutionName = institutionGroups.keys.elementAt(index);
        final institutionUsers = institutionGroups[institutionName]!;
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              '${institutionUsers.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(institutionName),
          subtitle: Text(
            '${institutionUsers.where((u) => u.isActive).length} actifs / ${institutionUsers.length} total',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showAllInstitutionUsers(institutionName, institutionUsers),
        );
      },
    );
  }

  Widget _buildDepartmentView() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group users by department
        final Map<String, List<UserModel>> departmentGroups = {};
        for (final user in provider.users) {
          final department = user.departmentName ?? 'Non spécifié';
          departmentGroups.putIfAbsent(department, () => []).add(user);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: departmentGroups.keys.length,
          itemBuilder: (context, index) {
            final departmentName = departmentGroups.keys.elementAt(index);
            final departmentUsers = departmentGroups[departmentName]!;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        '${departmentUsers.length}',
                        style: const TextStyle(
                          color: Colors.white,
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
                            departmentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${departmentUsers.where((u) => u.isActive).length} actifs / ${departmentUsers.length} total',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role distribution in this department
                        _buildDepartmentRoleStats(departmentUsers),
                        
                        const SizedBox(height: 12),
                        
                        // User list
                        const Text(
                          'Utilisateurs:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...departmentUsers.take(5).map((user) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: UserCardWidget(
                            user: user,
                            onTap: () => _showUserDetails(user),
                          ),
                        )),
                        
                        if (departmentUsers.length > 5)
                          TextButton(
                            onPressed: () => _showAllDepartmentUsers(departmentName, departmentUsers),
                            child: Text('Voir tous les ${departmentUsers.length} utilisateurs'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRegionView() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group users by region (from institution data)
        final Map<String, List<UserModel>> regionGroups = {};
        
        for (final user in provider.users) {
          // This would need region data from user's institution
          // For now, we'll use a placeholder or extract from institution name
          String region = 'Non spécifié';
          
          // Try to extract region from institution name or use default
          if (user.institutionName != null) {
            if (user.institutionName!.contains('Yaoundé')) region = 'Centre';
            else if (user.institutionName!.contains('Douala')) region = 'Littoral';
            else if (user.institutionName!.contains('Bamenda')) region = 'Nord-Ouest';
            else if (user.institutionName!.contains('Buea')) region = 'Sud-Ouest';
            else if (user.institutionName!.contains('Maroua')) region = 'Extrême-Nord';
            else if (user.institutionName!.contains('Garoua')) region = 'Nord';
            else if (user.institutionName!.contains('Ngaoundéré')) region = 'Adamaoua';
            else if (user.institutionName!.contains('Bertoua')) region = 'Est';
            else if (user.institutionName!.contains('Ebolowa')) region = 'Sud';
            else if (user.institutionName!.contains('Dschang')) region = 'Ouest';
          }
          
          if (!regionGroups.containsKey(region)) {
            regionGroups[region] = [];
          }
          regionGroups[region]!.add(user);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: regionGroups.keys.length,
          itemBuilder: (context, index) {
            final region = regionGroups.keys.elementAt(index);
            final regionUsers = regionGroups[region]!;
            
            return Card(
              child: InkWell(
                onTap: () => _showAllRegionUsers(region, regionUsers),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              region,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${regionUsers.length} utilisateurs',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '${regionUsers.where((u) => u.isActive).length} actifs',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInstitutionStats(List<UserModel> users) {
    final students = users.where((u) => u.primaryRole == 'student').length;
    final teachers = users.where((u) => u.primaryRole == 'teacher').length;
    final staff = users.where((u) => u.primaryRole == 'staff').length;
    
    return Row(
      children: [
        _buildStatChip('Étudiants', students, Colors.blue),
        const SizedBox(width: 8),
        _buildStatChip('Enseignants', teachers, Colors.green),
        const SizedBox(width: 8),
        _buildStatChip('Personnel', staff, Colors.orange),
      ],
    );
  }

  Widget _buildDepartmentRoleStats(List<UserModel> users) {
    final roleCounts = <String, int>{};
    for (final user in users) {
      roleCounts[user.primaryRole] = (roleCounts[user.primaryRole] ?? 0) + 1;
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: roleCounts.entries.map((entry) {
        return Chip(
          label: Text('${_getRoleDisplayName(entry.key)}: ${entry.value}'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        );
      }).toList(),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
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

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _buildUserDetailsDialog(user),
    );
  }

  Widget _buildUserDetailsDialog(UserModel user) {
    return AlertDialog(
      title: Text(user.fullName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Matricule', user.matricule ?? 'N/A'),
            _buildDetailRow('Rôle principal', user.primaryRole),
            _buildDetailRow('Statut', user.accountStatus),
            _buildDetailRow('Institution', user.institutionName ?? 'N/A'),
            _buildDetailRow('Département', user.departmentName ?? 'N/A'),
            _buildDetailRow('Date de création', _formatDate(user.createdAt)),
            _buildDetailRow('Dernière connexion', 
                user.lastLoginAt != null ? _formatDate(user.lastLoginAt!) : 'Jamais'),
            if (user.userRoles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Rôles:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...user.userRoles.map((role) => Text('• $role')),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAllInstitutionUsers(String institutionName, List<UserModel> users) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _UserListPage(
          title: 'Utilisateurs - $institutionName',
          users: users,
        ),
      ),
    );
  }

  void _showAllDepartmentUsers(String departmentName, List<UserModel> users) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _UserListPage(
          title: 'Utilisateurs - $departmentName',
          users: users,
        ),
      ),
    );
  }

  void _showAllRegionUsers(String region, List<UserModel> users) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _UserListPage(
          title: 'Utilisateurs - $region',
          users: users,
        ),
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques des utilisateurs'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<UserManagementProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingStats) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.userStats.isEmpty) {
                return const Center(child: Text('Aucune statistique disponible'));
              }
              
              return UserStatsWidget(stats: provider.userStats);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

class _UserListPage extends StatelessWidget {
  final String title;
  final List<UserModel> users;

  const _UserListPage({
    required this.title,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: UserCardWidget(
              user: user,
              onTap: () => _showUserDetails(context, user),
            ),
          );
        },
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Matricule', user.matricule ?? 'N/A'),
              _buildDetailRow('Rôle principal', user.primaryRole),
              _buildDetailRow('Statut', user.accountStatus),
              _buildDetailRow('Institution', user.institutionName ?? 'N/A'),
              _buildDetailRow('Département', user.departmentName ?? 'N/A'),
              _buildDetailRow('Date de création', _formatDate(user.createdAt)),
              _buildDetailRow('Dernière connexion', 
                  user.lastLoginAt != null ? _formatDate(user.lastLoginAt!) : 'Jamais'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
