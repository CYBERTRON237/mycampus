import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/enhanced_student_provider.dart';
import '../../data/models/enhanced_student_model.dart';
import '../widgets/enhanced_student_card.dart';
import '../widgets/enhanced_student_filters_widget.dart';
import '../widgets/enhanced_student_stats_widget.dart';
import '../widgets/enhanced_search_widget.dart';
import '../widgets/enhanced_create_student_dialog.dart';
import '../widgets/enhanced_edit_student_dialog.dart';
import '../widgets/enhanced_bulk_actions_widget.dart';
import '../widgets/enhanced_export_widget.dart';
import '../widgets/enhanced_import_widget.dart';
import 'enhanced_student_detail_page.dart';
import '../widgets/university_list_widget.dart';

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({Key? key}) : super(key: key);

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Universités, Étudiants, Statistiques, Outils
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedStudentProvider>().loadStudents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final provider = context.read<EnhancedStudentProvider>();
      if (provider.currentPage < provider.totalPages) {
        provider.loadNextPage();
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<EnhancedStudentProvider>().searchStudents(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Enhanced AppBar with all features
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Gestion des Étudiants'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.school), text: 'Universités'),
          Tab(icon: Icon(Icons.people), text: 'Étudiants'),
          Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
          Tab(icon: Icon(Icons.settings), text: 'Outils'),
        ],
      ),
      actions: [
        // Search toggle
        IconButton(
          icon: Icon(context.watch<EnhancedStudentProvider>().isSearchVisible 
              ? Icons.close : Icons.search),
          onPressed: () {
            context.read<EnhancedStudentProvider>().toggleSearchVisibility();
            if (!context.read<EnhancedStudentProvider>().isSearchVisible) {
              _searchController.clear();
            }
          },
          tooltip: 'Rechercher',
        ),
        
        // Advanced filters
        IconButton(
          icon: Icon(Icons.tune, 
            color: context.watch<EnhancedStudentProvider>().showAdvancedFilters 
                ? Theme.of(context).colorScheme.primary 
                : null),
          onPressed: () {
            context.read<EnhancedStudentProvider>().toggleAdvancedFilters();
          },
          tooltip: 'Filtres avancés',
        ),
        
        // View mode
        PopupMenuButton<StudentViewMode>(
          icon: const Icon(Icons.view_list),
          onSelected: (mode) {
            context.read<EnhancedStudentProvider>().setViewMode(mode);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: StudentViewMode.list,
              child: Row(
                children: [
                  Icon(Icons.view_list),
                  SizedBox(width: 8),
                  Text('Liste'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: StudentViewMode.grid,
              child: Row(
                children: [
                  Icon(Icons.grid_view),
                  SizedBox(width: 8),
                  Text('Grille'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: StudentViewMode.compact,
              child: Row(
                children: [
                  Icon(Icons.view_list),
                  SizedBox(width: 8),
                  Text('Compact'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: StudentViewMode.cards,
              child: Row(
                children: [
                  Icon(Icons.style),
                  SizedBox(width: 8),
                  Text('Cartes'),
                ],
              ),
            ),
          ],
        ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            if (context.watch<EnhancedStudentProvider>().canViewStatistics)
              const PopupMenuItem(
                value: 'statistics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Statistiques'),
                ),
              ),
            if (context.watch<EnhancedStudentProvider>().canExportStudents)
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Exporter'),
                ),
              ),
            if (context.watch<EnhancedStudentProvider>().canImportStudents)
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Importer'),
                ),
              ),
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Actualiser'),
              ),
            ),
            const PopupMenuItem(
              value: 'clear_filters',
              child: ListTile(
                leading: Icon(Icons.clear),
                title: Text('Effacer les filtres'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<EnhancedStudentProvider>(
      builder: (context, provider, child) {
        return TabBarView(
          controller: _tabController,
          children: [
            _buildUniversitiesTab(provider),
            _buildStudentsTab(provider),
            _buildStatisticsTab(provider),
            _buildToolsTab(provider),
          ],
        );
      },
    );
  }

  Widget _buildUniversitiesTab(EnhancedStudentProvider provider) {
    return const UniversityListWidget();
  }
  Widget _buildStudentsTab(EnhancedStudentProvider provider) {
    return Column(
      children: [
        // Search bar
        if (provider.isSearchVisible)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: EnhancedSearchWidget(
              controller: _searchController,
              onClear: () {
                _searchController.clear();
                provider.clearFilters();
              },
            ),
          ),
        
        // Advanced filters
        if (provider.showAdvancedFilters)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: EnhancedStudentFiltersWidget(
              currentFilters: provider.filters,
              onFiltersChanged: (filters) {
                provider.applyFilters(filters);
              },
            ),
          ),
        
        // Bulk actions
        if (provider.isSelectionMode && provider.selectedStudents.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: EnhancedBulkActionsWidget(
              selectedStudents: provider.selectedStudents,
              onSelectionChanged: (students) {
                // Handle selection changes if needed
              },
              onExportSelected: () => _showExportDialog(selectedOnly: true),
              onDeleteSelected: () => _showBulkDeleteConfirmation(),
              onActivateSelected: () => provider.activateSelectedStudents(),
              onDeactivateSelected: () => provider.deactivateSelectedStudents(),
              onVerifySelected: () => provider.verifySelectedStudents(),
            ),
          ),
        
        // Results header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                '${provider.totalCount} étudiant${provider.totalCount > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              // Selection mode toggle
              if (provider.students.isNotEmpty)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(provider.isSelectionMode ? Icons.checklist : Icons.checklist_rtl),
                      onPressed: () => provider.toggleSelectionMode(),
                      tooltip: provider.isSelectionMode ? 'Désactiver la sélection' : 'Activer la sélection',
                      iconSize: 20,
                    ),
                    if (provider.isSelectionMode)
                      Text(
                        '${provider.selectedStudents.length} sélectionné(s)',
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
        
        // Students list
        Expanded(
          child: _buildStudentsList(provider),
        ),
      ],
    );
  }
  Widget _buildStudentsList(EnhancedStudentProvider provider) {
    if (provider.isLoading && provider.students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError && provider.students.isEmpty) {
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
                provider.refreshStudents();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (provider.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun étudiant trouvé',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres de recherche',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => provider.clearFilters(),
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshStudents(),
      child: _buildStudentsView(provider),
    );
  }

  Widget _buildStudentsView(EnhancedStudentProvider provider) {
    switch (provider.viewMode) {
      case StudentViewMode.grid:
        return _buildGridView(provider);
      case StudentViewMode.compact:
        return _buildCompactView(provider);
      case StudentViewMode.cards:
        return _buildCardsView(provider);
      case StudentViewMode.list:
        return _buildListView(provider);
    }
  }

  Widget _buildListView(EnhancedStudentProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.students.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < provider.students.length) {
          final student = provider.students[index];
          final isSelected = provider.selectedStudents.contains(student);
          
          return EnhancedStudentCard(
            student: student,
            viewMode: StudentViewMode.list,
            isSelected: isSelected,
            isSelectionMode: provider.isSelectionMode,
            onTap: () => _handleStudentTap(student),
            onSelectionChanged: (selected) {
              provider.toggleStudentSelection(student);
            },
            onEdit: () => _showEditStudentDialog(student),
            onDelete: () => _showDeleteConfirmation(student),
            onQuickAction: (action) => _handleQuickAction(action, student),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildGridView(EnhancedStudentProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.students.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < provider.students.length) {
          final student = provider.students[index];
          final isSelected = provider.selectedStudents.contains(student);
          
          return EnhancedStudentCard(
            student: student,
            viewMode: StudentViewMode.grid,
            isSelected: isSelected,
            isSelectionMode: provider.isSelectionMode,
            onTap: () => _handleStudentTap(student),
            onSelectionChanged: (selected) {
              provider.toggleStudentSelection(student);
            },
            onEdit: () => _showEditStudentDialog(student),
            onDelete: () => _showDeleteConfirmation(student),
            onQuickAction: (action) => _handleQuickAction(action, student),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildCompactView(EnhancedStudentProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.students.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < provider.students.length) {
          final student = provider.students[index];
          final isSelected = provider.selectedStudents.contains(student);
          
          return EnhancedStudentCard(
            student: student,
            viewMode: StudentViewMode.compact,
            isSelected: isSelected,
            isSelectionMode: provider.isSelectionMode,
            onTap: () => _handleStudentTap(student),
            onSelectionChanged: (selected) {
              provider.toggleStudentSelection(student);
            },
            onEdit: () => _showEditStudentDialog(student),
            onDelete: () => _showDeleteConfirmation(student),
            onQuickAction: (action) => _handleQuickAction(action, student),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildCardsView(EnhancedStudentProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.students.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < provider.students.length) {
          final student = provider.students[index];
          final isSelected = provider.selectedStudents.contains(student);
          
          return EnhancedStudentCard(
            student: student,
            viewMode: StudentViewMode.cards,
            isSelected: isSelected,
            isSelectionMode: provider.isSelectionMode,
            onTap: () => _handleStudentTap(student),
            onSelectionChanged: (selected) {
              provider.toggleStudentSelection(student);
            },
            onEdit: () => _showEditStudentDialog(student),
            onDelete: () => _showDeleteConfirmation(student),
            onQuickAction: (action) => _handleQuickAction(action, student),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildStatisticsTab(EnhancedStudentProvider provider) {
    return Consumer<EnhancedStudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingStatistics) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.statistics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Statistiques non disponibles',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuyez sur le bouton pour charger les statistiques',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadStatistics(),
                  child: const Text('Charger les statistiques'),
                ),
              ],
            ),
          );
        }

        return EnhancedStudentStatsWidget(
          statistics: provider.statistics!,
          onRefresh: () => provider.loadStatistics(),
        );
      },
    );
  }

  Widget _buildToolsTab(EnhancedStudentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Exportation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Exporter les données des étudiants dans différents formats'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showExportDialog(),
                          icon: const Icon(Icons.download),
                          label: const Text('Exporter tout'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: provider.selectedStudents.isNotEmpty 
                              ? () => _showExportDialog(selectedOnly: true)
                              : null,
                          icon: const Icon(Icons.download),
                          label: const Text('Exporter la sélection'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Import section
          if (provider.canImportStudents)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upload, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Importation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Importer des étudiants depuis un fichier CSV ou Excel'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showImportDialog(),
                      icon: const Icon(Icons.upload),
                      label: const Text('Importer des étudiants'),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Bulk operations section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.batch_prediction, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Opérations en masse',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Effectuer des opérations sur plusieurs étudiants à la fois'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showBulkPromotionDialog(),
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Promouvoir'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showBulkGraduationDialog(),
                        icon: const Icon(Icons.school),
                        label: const Text('Diplômer'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showBulkActivationDialog(),
                        icon: const Icon(Icons.check),
                        label: const Text('Activer'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showBulkDeactivationDialog(),
                        icon: const Icon(Icons.block),
                        label: const Text('Désactiver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<EnhancedStudentProvider>(
      builder: (context, provider, child) {
        if (!provider.canCreateStudent) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: () => _showCreateStudentDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un étudiant'),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<EnhancedStudentProvider>(
      builder: (context, provider, child) {
        if (provider.totalPages <= 1) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: provider.currentPage > 1
                    ? () => provider.loadPreviousPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(
                provider.totalPages.clamp(1, 5),
                (index) {
                  final page = index + 1;
                  final isCurrentPage = page == provider.currentPage;
                   
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => provider.goToPage(page),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCurrentPage
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: isCurrentPage
                              ? null
                              : Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                        ),
                        child: Center(
                          child: Text(
                            '$page',
                            style: TextStyle(
                              color: isCurrentPage
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isCurrentPage
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: provider.currentPage < provider.totalPages
                    ? () => provider.loadNextPage()
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
    );
  }

  // Event handlers
  void _handleMenuAction(String action) {
    final provider = context.read<EnhancedStudentProvider>();
    
    switch (action) {
      case 'statistics':
        provider.toggleStatistics();
        break;
      case 'export':
        _showExportDialog();
        break;
      case 'import':
        _showImportDialog();
        break;
      case 'refresh':
        provider.refreshStudents();
        break;
      case 'clear_filters':
        provider.clearFilters();
        break;
    }
  }

  void _handleStudentTap(EnhancedStudentModel student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnhancedStudentDetailPage(student: student),
      ),
    );
  }

  void _handleQuickAction(String action, EnhancedStudentModel student) {
    switch (action) {
      case 'view':
        _handleStudentTap(student);
        break;
      case 'edit':
        _showEditStudentDialog(student);
        break;
      case 'delete':
        _showDeleteConfirmation(student);
        break;
    }
  }

  void _showCreateStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedCreateStudentDialog(
        onStudentCreated: (student) async {
          await context.read<EnhancedStudentProvider>().createStudent(student);
        },
      ),
    );
  }

  void _showEditStudentDialog(EnhancedStudentModel student) {
    showDialog(
      context: context,
      builder: (context) => EnhancedEditStudentDialog(
        student: student,
        onStudentUpdated: (student) async {
          await context.read<EnhancedStudentProvider>().updateStudent(student.id, student);
        },
      ),
    );
  }

  void _showDeleteConfirmation(EnhancedStudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${student.fullName}'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet étudiant? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<EnhancedStudentProvider>().deleteStudent(student.id);
            },
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showExportDialog({bool selectedOnly = false}) {
    showDialog(
      context: context,
      builder: (context) => EnhancedExportWidget(
        selectedOnly: selectedOnly,
        onExport: (format, data) async {
          // Handle export logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export en $format effectué')),
          );
        },
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => EnhancedImportWidget(
        onImport: (data, format) async {
          // Handle import logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import effectué avec succès')),
          );
        },
      ),
    );
  }

  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la sélection'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tous les étudiants sélectionnés? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<EnhancedStudentProvider>().deleteSelectedStudents();
            },
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showBulkPromotionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promouvoir les étudiants'),
        content: const Text(
          'Voulez-vous promouvoir tous les étudiants sélectionnés au niveau supérieur?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Use bulk operations instead
              final provider = context.read<EnhancedStudentProvider>();
              for (final student in provider.selectedStudents) {
                await provider.updateStudentLevel(student.id, AcademicLevel.values[(student.currentLevel.index + 1) % AcademicLevel.values.length]);
              }
            },
            child: const Text('Promouvoir'),
          ),
        ],
      ),
    );
  }

  void _showBulkGraduationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diplômer les étudiants'),
        content: const Text(
          'Voulez-vous diplômer tous les étudiants sélectionnés?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Use bulk operations instead
              final provider = context.read<EnhancedStudentProvider>();
              for (final student in provider.selectedStudents) {
                await provider.updateStudentStatus(student.id, StudentStatus.graduated);
              }
            },
            child: const Text('Diplômer'),
          ),
        ],
      ),
    );
  }

  void _showBulkActivationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activer les étudiants'),
        content: const Text(
          'Voulez-vous activer tous les étudiants sélectionnés?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<EnhancedStudentProvider>().activateSelectedStudents();
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeactivationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Désactiver les étudiants'),
        content: const Text(
          'Voulez-vous désactiver tous les étudiants sélectionnés?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<EnhancedStudentProvider>().deactivateSelectedStudents();
            },
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
  }
}
