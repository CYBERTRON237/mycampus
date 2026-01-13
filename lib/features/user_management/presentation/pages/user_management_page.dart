import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/institution_department_model.dart';
import '../../providers/user_management_provider.dart';
import '../widgets/create_user_dialog.dart';
import '../widgets/edit_user_dialog.dart';
import '../widgets/advanced_user_filters_widget.dart';
import '../widgets/advanced_user_stats_widget.dart';
import '../widgets/bulk_actions_widget.dart' hide UserSelectionWidget;
import '../widgets/user_view_widgets.dart';
import '../widgets/advanced_search_widget.dart';
import '../widgets/complete_profile_edit_widget.dart';
import '../widgets/user_selection_widget.dart';
import 'user_detail_page.dart';
import 'user_navigation_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // View mode and selection
  ViewMode _viewMode = ViewMode.list;
  final Set<int> _selectedUsers = <int>{};
  bool _isSelectionMode = false;
  
  // Institutions and departments for filters
  List<InstitutionModel>? _institutions;
  List<DepartmentModel>? _departments;
  
  // Quick filter variables
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void initState() {
    print('DEBUG: UserManagementPage - initState début');
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInstitutionsAndDepartments();
    print('DEBUG: UserManagementPage - initState terminé');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = context.read<UserManagementProvider>();
    provider.searchUsers(_searchController.text);
  }
  
  Future<void> _loadInstitutionsAndDepartments() async {
    // Load institutions and departments for advanced filters
    // This would typically come from API calls
    // For now, we'll use empty lists
    setState(() {
      _institutions = [];
      _departments = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: UserManagementPage - build début');
    final provider = context.read<UserManagementProvider>();
    print('DEBUG: UserManagementPage - provider récupéré: ${provider.runtimeType}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Advanced search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showAdvancedSearch,
            tooltip: 'Recherche avancée',
          ),
          // Navigation view
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: _showNavigationView,
            tooltip: 'Navigation par institution',
          ),
          // View mode toggle
          PopupMenuButton<ViewMode>(
            icon: const Icon(Icons.view_list),
            onSelected: (mode) {
              setState(() {
                _viewMode = mode;
                if (!_isSelectionMode) {
                  _selectedUsers.clear();
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ViewMode.list,
                child: Row(
                  children: [
                    Icon(Icons.view_list),
                    SizedBox(width: 8),
                    Text('Liste'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ViewMode.grid,
                child: Row(
                  children: [
                    Icon(Icons.grid_view),
                    SizedBox(width: 8),
                    Text('Grille'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ViewMode.compact,
                child: Row(
                  children: [
                    Icon(Icons.view_list),
                    SizedBox(width: 8),
                    Text('Compact'),
                  ],
                ),
              ),
            ],
          ),
          Consumer<UserManagementProvider>(
            builder: (context, provider, child) {
              if (provider.canCreateUsers) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showCreateUserDialog,
                  tooltip: 'Créer un utilisateur',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<UserManagementProvider>(
            builder: (context, provider, child) {
              if (provider.canViewStats) {
                return IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: _showAdvancedStatsDialog,
                  tooltip: 'Statistiques avancées',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UserManagementProvider>().refreshUsers(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          print('DEBUG: UserManagementPage - Consumer build - loading: ${provider.isLoading}, error: ${provider.error}, users: ${provider.users.length}');
          
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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

          return Column(
            children: [
              // Fixed header with compact filters
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Compact search and filters bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Search field
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Rechercher...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quick filters
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole,
                              hint: const Text('Rôle'),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Tous')),
                                DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                                DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
                                DropdownMenuItem(value: 'staff', child: Text('Personnel')),
                                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                                _applyQuickFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status filter
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              hint: const Text('Statut'),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Tous')),
                                DropdownMenuItem(value: 'active', child: Text('Actif')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactif')),
                                DropdownMenuItem(value: 'pending', child: Text('En attente')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                                _applyQuickFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Advanced filters toggle
                          IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: _showAdvancedFilters,
                            tooltip: 'Filtres avancés',
                          ),
                        ],
                      ),
                    ),
                    
                    // Results counter and actions
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${provider.users.length} utilisateur${provider.users.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          // Selection mode toggle
                          if (provider.users.isNotEmpty)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(_isSelectionMode ? Icons.checklist : Icons.checklist_rtl),
                                  onPressed: _toggleSelectionMode,
                                  tooltip: _isSelectionMode ? 'Désactiver la sélection' : 'Activer la sélection',
                                  iconSize: 20,
                                ),
                                if (_isSelectionMode)
                                  Text(
                                    '${_selectedUsers.length} sélectionné(s)',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          const SizedBox(width: 8),
                          if (provider.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bulk actions (if selection mode)
              if (_isSelectionMode && _selectedUsers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: BulkActionsWidget(
                    selectedUsers: provider.users.where((u) => _selectedUsers.contains(u.id)).toList(),
                    onSelectionChanged: (selectedUsers) {
                      setState(() {
                        _selectedUsers.clear();
                        _selectedUsers.addAll(selectedUsers.map((u) => u.id));
                      });
                    },
                    onExportSelected: _exportSelectedUsers,
                    onActivateSelected: _activateSelectedUsers,
                    onDeactivateSelected: _deactivateSelectedUsers,
                    onDeleteSelected: _deleteSelectedUsers,
                  ),
                ),
              
              // Users list/grid/compact view
              Expanded(
                child: provider.users.isEmpty
                    ? _buildEmptyState()
                    : _buildUsersView(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun utilisateur trouvé',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres de recherche',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<UserManagementProvider>().resetFilters(),
            child: const Text('Réinitialiser les filtres'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersView(UserManagementProvider provider) {
    switch (_viewMode) {
      case ViewMode.grid:
        return UserGridView(
          users: provider.users,
          onTap: (user) => _showUserDetails(user),
          allowSelection: _isSelectionMode,
          onSelectionChanged: (user, selected) {
            setState(() {
              if (selected) {
                _selectedUsers.add(user.id);
              } else {
                _selectedUsers.remove(user.id);
              }
            });
          },
          selectedUsers: _selectedUsers,
        );
      case ViewMode.compact:
        return UserCompactListView(
          users: provider.users,
          onTap: (user) => _showUserDetails(user),
          allowSelection: _isSelectionMode,
          onSelectionChanged: (user, selected) {
            setState(() {
              if (selected) {
                _selectedUsers.add(user.id);
              } else {
                _selectedUsers.remove(user.id);
              }
            });
          },
          selectedUsers: _selectedUsers,
        );
      case ViewMode.list:
        return _buildUsersList(provider);
    }
  }

  Widget _buildUsersList(UserManagementProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshUsers(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.users.length,
        itemBuilder: (context, index) {
          final user = provider.users[index];
          final isSelected = _selectedUsers.contains(user.id);
          
          return UserSelectionWidget(
            user: user,
            onTap: () => _showUserDetails(user),
            isSelected: isSelected,
            compact: false,
            onSelectionChanged: _isSelectionMode ? (selected) {
              setState(() {
                if (selected == true) {
                  _selectedUsers.add(user.id);
                } else {
                  _selectedUsers.remove(user.id);
                }
              });
            } : null,
            onQuickAction: _handleQuickAction,
          );
        },
      ),
    );
  }
  
  void _handleQuickAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'complete_edit':
        _showCompleteProfileEdit(user);
        break;
      case 'toggle':
        _toggleUserStatus(user);
        break;
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedUsers.clear();
      }
    });
  }
  
  void _showAdvancedSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdvancedSearchWidget(
          institutions: _institutions,
          departments: _departments,
          onSearch: (criteria) {
            // Apply advanced search criteria
            final provider = context.read<UserManagementProvider>();
            // Convert AdvancedSearchCriteria to UserFilters
            final filters = UserFilters(
              search: criteria.name,
              role: criteria.role,
              status: criteria.status,
              institutionName: criteria.institution,
              departmentName: criteria.department,
              level: criteria.level,
              region: criteria.region,
              city: criteria.city,
              isActive: criteria.isActive,
              createdAfter: criteria.createdAfter,
              createdBefore: criteria.createdBefore,
              lastLoginAfter: criteria.lastLoginAfter,
              lastLoginBefore: criteria.lastLoginBefore,
              minUserLevel: criteria.minUserLevel,
              maxUserLevel: criteria.maxUserLevel,
            );
            provider.updateFilters(filters);
          },
        ),
      ),
    );
  }
  
  void _showNavigationView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserNavigationPage(),
      ),
    );
  }
  
  void _showAdvancedStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques Avancées'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: Consumer<UserManagementProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingStats) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.userStats.isEmpty) {
                return const Center(child: Text('Aucune statistique disponible'));
              }
              
              // Create a mock UserStatistics from UserRoleStats for now
              return AdvancedUserStatsWidget(stats: UserStatistics(
                totalUsers: provider.userStats.fold(0, (sum, stat) => sum + stat.userCount),
                activeUsers: provider.userStats.fold(0, (sum, stat) => sum + stat.activeCount),
                inactiveUsers: provider.userStats.fold(0, (sum, stat) => sum + (stat.userCount - stat.activeCount)),
                pendingUsers: 0,
                institutionStats: [],
                roleStats: provider.userStats,
                usersByDepartment: {},
                usersByRegion: {},
                usersByRole: {},
                usersByInstitution: {},
              ));
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
  
  void _exportSelectedUsers() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportation en cours...')),
    );
  }
  
  void _activateSelectedUsers() {
    // Implement bulk activation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activation en cours...')),
    );
  }
  
  void _deactivateSelectedUsers() {
    // Implement bulk deactivation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Désactivation en cours...')),
    );
  }
  
  void _deleteSelectedUsers() {
    // Implement bulk deletion
    showDialog(
      context: context,
      builder: (context) => BulkActionDialog(
        title: 'Suppression en masse',
        message: 'Êtes-vous sûr de vouloir supprimer les ${_selectedUsers.length} utilisateurs sélectionnés ?',
        actionLabel: 'Supprimer',
        actionIcon: Icons.delete,
        actionColor: Colors.red,
        onConfirm: () {
          Navigator.of(context).pop();
          // Perform bulk deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Suppression en cours...')),
          );
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        onSubmit: (userData) async {
          final result = await context.read<UserManagementProvider>().createUser(userData);
          if (result.success) {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.message)),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailPage(user: user),
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

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onSubmit: (userData) async {
          final result = await context.read<UserManagementProvider>().updateUser(user.id, userData);
          if (!result.success) {
            throw Exception(result.message);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${user.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await context.read<UserManagementProvider>().deleteUser(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? null : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(UserModel user) async {
    final result = await context.read<UserManagementProvider>().toggleUserStatus(user.id, !user.isActive);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? null : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showCompleteProfileEdit(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => CompleteProfileEditWidget(
        user: user,
        onProfileUpdated: (updatedUser) {
          // Le provider sera automatiquement rafraîchi
          setState(() {});
        },
      ),
    );
  }

  void _showAssignRoleDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _buildAssignRoleDialog(user),
    );
  }

  Widget _buildAssignRoleDialog(UserModel user) {
    final roles = ['student', 'teacher', 'staff', 'moderator', 'leader', 'admin_local', 'admin_national', 'superadmin'];
    
    return AlertDialog(
      title: Text('Assigner un rôle à ${user.fullName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: roles.map((role) {
          return RadioListTile<String>(
            title: Text(role),
            value: role,
            groupValue: user.primaryRole,
            onChanged: (value) async {
              if (value != null) {
                Navigator.of(context).pop();
                final result = await context.read<UserManagementProvider>().assignRole(user.id, value);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success ? null : Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  void _applyQuickFilters() {
    final provider = context.read<UserManagementProvider>();
    final filters = UserFilters(
      search: _searchController.text,
      role: _selectedRole,
      status: _selectedStatus,
    );
    provider.updateFilters(filters);
  }

  void _showAdvancedFilters() {
    final provider = context.read<UserManagementProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres avancés'),
        content: SizedBox(
          width: double.maxFinite,
          child: AdvancedUserFiltersWidget(
            searchController: _searchController,
            onFiltersChanged: (filters) {
              provider.updateFilters(filters);
              Navigator.of(context).pop();
            },
            currentFilters: provider.filters,
            institutions: _institutions,
            departments: _departments,
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
}
