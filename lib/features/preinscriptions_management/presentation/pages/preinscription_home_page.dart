import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/preinscription_provider.dart';
import '../../models/preinscription_model.dart';
import '../widgets/preinscription_list_widget.dart';
import '../widgets/preinscription_stats_widget.dart';
import 'preinscription_detail_page.dart';
import 'create_preinscription_page.dart';
import '../../../preinscription/presentation/pages/preinscription_home_page.dart' as preinscription_module;
// Import complete validation module
import '../../../preinscription_validation/providers/preinscription_validation_provider.dart';
import '../../../preinscription_validation/presentation/widgets/preinscription_validation_card_redesigned.dart';
import '../../../preinscription_validation/presentation/widgets/preinscription_validation_filters_redesigned.dart';
import '../../../preinscription_validation/presentation/widgets/preinscription_validation_stats_redesigned.dart';
import '../../../preinscription_validation/presentation/pages/preinscription_detail_page.dart' as validation_detail;
import '../../../preinscription_validation/services/preinscription_validation_remote_datasource.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';

class PreinscriptionHomePage extends StatefulWidget {
  final int? initialTab;
  final Map<String, String>? initialFilters;

  const PreinscriptionHomePage({
    Key? key,
    this.initialTab,
    this.initialFilters,
  }) : super(key: key);

  @override
  State<PreinscriptionHomePage> createState() => _PreinscriptionHomePageState();
}

class _PreinscriptionHomePageState extends State<PreinscriptionHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Ensure the TabController length matches exactly the number of tabs and children
    _tabController = TabController(length: 4, vsync: this);
    
    if (kDebugMode) {
      print('🏠 [PAGE DEBUG] PreinscriptionHomePage initState appelé');
    }
    
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print('🏠 [PAGE DEBUG] Initialisation du provider depuis PreinscriptionHomePage');
      }
      context.read<PreinscriptionProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gestion des Préinscriptions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Liste'),
            Tab(icon: Icon(Icons.pending_actions), text: 'À Valider'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
            Tab(icon: Icon(Icons.history), text: 'Historique'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PreinscriptionProvider>().initialize();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePreinscriptionPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.app_registration),
            tooltip: 'Aller aux préinscriptions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const preinscription_module.PreinscriptionHomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PreinscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorWidget(provider.error!, provider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildListView(provider),
              _buildToValidateView(),
              _buildStatsView(provider),
              _buildHistoryView(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView(PreinscriptionProvider provider) {
    return Column(
      children: [
        // Compact search and filters header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Search bar with clear button
              TextField(
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => provider.setSearchQuery(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8.0),
              
              // Compact filters row
              Row(
                children: [
                  // Faculty filter
                  Expanded(
                    child: _buildCompactDropdown(
                      context: context,
                      label: 'Faculté',
                      value: provider.selectedFaculty,
                      items: const [
                        'UY1', 'FALSH', 'FS', 'FSE', 'IUT', 'ENSPY',
                        'Faculté des Sciences', 'Faculté des Lettres', 'Faculté de Médecine',
                      ],
                      onChanged: provider.setFacultyFilter,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  
                  // Status filter
                  Expanded(
                    child: _buildCompactDropdown(
                      context: context,
                      label: 'Statut',
                      value: provider.selectedStatus,
                      items: PreinscriptionConstants.statuses,
                      onChanged: provider.setStatusFilter,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  
                  // Payment status filter
                  Expanded(
                    child: _buildCompactDropdown(
                      context: context,
                      label: 'Paiement',
                      value: provider.selectedPaymentStatus,
                      items: PreinscriptionConstants.paymentStatuses,
                      onChanged: provider.setPaymentStatusFilter,
                    ),
                  ),
                  
                  // Clear filters button
                  if (provider.selectedFaculty != null || 
                      provider.selectedStatus != null || 
                      provider.selectedPaymentStatus != null) ...[
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.clear_all, size: 20),
                      onPressed: provider.clearFilters,
                      tooltip: 'Effacer les filtres',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // List content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.fetchPreinscriptions(refresh: true),
            child: PreinscriptionListWidget(
              preinscriptions: provider.preinscriptions,
              isLoading: provider.isLoading,
              onTap: (preinscription) {
                if (preinscription.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreinscriptionDetailPage(
                        preinscriptionId: preinscription.id!,
                      ),
                    ),
                  );
                } else {
                  // Afficher un message d'erreur si l'ID est manquant
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID de préinscription manquant'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onLoadMore: provider.loadMore,
              hasMore: provider.currentPage < provider.totalPages,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsView(PreinscriptionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Carte d'action pour aller aux préinscriptions
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.app_registration,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  'Module de Préinscriptions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accédez au formulaire de préinscription pour les étudiants',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const preinscription_module.PreinscriptionHomePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text('Aller aux préinscriptions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PreinscriptionStatsWidget(
            stats: provider.stats,
            facultyStats: provider.facultyStats,
            isLoading: provider.isLoading,
            onRefresh: () async {
              await Future.wait([
                provider.fetchStats(),
                provider.fetchFacultyStats(),
              ]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentView(PreinscriptionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Préinscriptions Récentes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16.0),
          if (provider.recentPreinscriptions.isEmpty)
            const Center(
              child: Text('Aucune préinscription récente'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.recentPreinscriptions.length,
              itemBuilder: (context, index) {
                final recent = provider.recentPreinscriptions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      '${recent['first_name']} ${recent['last_name']}' ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recent['faculty'] ?? ''),
                        Text(recent['email'] ?? ''),
                        Text(
                          'Soumis: ${_formatDate(recent['submission_date'])}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: _buildStatusChip(recent['status'] ?? ''),
                    onTap: () {
                      final id = recent['id'];
                      if (id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PreinscriptionDetailPage(
                              preinscriptionId: id as int,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID de préinscription manquant'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'under_review':
        color = Colors.blue;
        icon = Icons.visibility;
        break;
      case 'accepted':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.block;
        break;
      case 'deferred':
        color = Colors.purple;
        icon = Icons.schedule;
        break;
      case 'waitlisted':
        color = Colors.amber;
        icon = Icons.hourglass_empty;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: color.withOpacity(0.2),
      avatar: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildErrorWidget(String error, PreinscriptionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.initialize();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildCompactDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2.0),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            isDense: true,
          ),
          isDense: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Tous', style: TextStyle(fontSize: 12)),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                _formatDisplayValue(item),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _formatDisplayValue(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En révision';
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Rejeté';
      case 'cancelled':
        return 'Annulé';
      case 'deferred':
        return 'Reporté';
      case 'waitlisted':
        return 'Liste d\'attente';
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'refunded':
        return 'Remboursé';
      case 'partial':
        return 'Partiel';
      default:
        return value;
    }
  }

  Widget _buildToValidateView() {
    return ChangeNotifierProvider(
      create: (context) {
        // Créer le repository et le datasource pour la validation
        final authService = AuthService();
        final repository = PreinscriptionValidationRemoteDataSource(
          client: http.Client(),
          authService: authService,
        );
        
        // Créer et retourner le provider de validation
        final provider = PreinscriptionValidationProvider(repository);
        
        // Initialiser les données automatiquement
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.refresh();
        });
        
        return provider;
      },
      child: Consumer<PreinscriptionValidationProvider>(
        builder: (context, validationProvider, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header avec statistiques et actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Statistiques de validation
                    PreinscriptionValidationStatsRedesigned(),
                    const SizedBox(height: 16),
                    
                    // Barre de recherche et filtres
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              validationProvider.setSearchQuery(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Rechercher une préinscription...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: validationProvider.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        validationProvider.setSearchQuery('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.filter_list_rounded),
                          onPressed: () => _showValidationFilters(context, validationProvider),
                          tooltip: 'Filtres',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () => validationProvider.refresh(),
                          tooltip: 'Actualiser',
                        ),
                      ],
                    ),
                    
                    // Filtres actifs
                    if (validationProvider.hasActiveFilters)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (validationProvider.selectedFaculty != 'Toutes')
                              Chip(
                                label: Text(validationProvider.selectedFaculty),
                                onDeleted: () => validationProvider.setFacultyFilter('Toutes'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            if (validationProvider.selectedStatus != 'Toutes')
                              Chip(
                                label: Text(validationProvider.selectedStatus),
                                onDeleted: () => validationProvider.setStatusFilter('Toutes'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            if (validationProvider.selectedPaymentStatus != 'Toutes')
                              Chip(
                                label: Text(validationProvider.selectedPaymentStatus),
                                onDeleted: () => validationProvider.setPaymentStatusFilter('Toutes'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            Chip(
                              label: const Text('Tout effacer'),
                              onDeleted: () => validationProvider.clearFilters(),
                              deleteIcon: const Icon(Icons.clear_all, size: 16),
                              backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Liste des préinscriptions
              SizedBox(
                height: 400,
                child: _buildValidationContent(validationProvider),
              ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryView() {
    return ChangeNotifierProvider(
      create: (context) {
        // Créer le repository et le datasource pour la validation
        final authService = AuthService();
        final repository = PreinscriptionValidationRemoteDataSource(
          client: http.Client(),
          authService: authService,
        );
        
        // Créer et retourner le provider de validation
        final provider = PreinscriptionValidationProvider(repository);
        
        // Initialiser les données automatiquement
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.refresh();
        });
        
        return provider;
      },
      child: Consumer<PreinscriptionValidationProvider>(
        builder: (context, validationProvider, child) {
          final historyPreinscriptions = validationProvider.allPreinscriptions
              .where((p) => p.status != 'pending' && p.status != 'under_review')
              .toList();

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header avec statistiques de l'historique
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Historique des validations',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${historyPreinscriptions.length} traitements',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Statistiques rapides de l'historique
                    Row(
                      children: [
                        Expanded(
                          child: _buildHistoryStatCard(
                            context,
                            'Validées',
                            validationProvider.allPreinscriptions
                                .where((p) => p.status == 'accepted')
                                .length
                                .toString(),
                            Icons.check_circle_rounded,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildHistoryStatCard(
                            context,
                            'Rejetées',
                            validationProvider.allPreinscriptions
                                .where((p) => p.status == 'rejected')
                                .length
                                .toString(),
                            Icons.cancel_rounded,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildHistoryStatCard(
                            context,
                            'Total',
                            historyPreinscriptions.length.toString(),
                            Icons.analytics_rounded,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Liste de l'historique
              SizedBox(
                height: 400,
                child: _buildHistoryContent(validationProvider, historyPreinscriptions),
              ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(PreinscriptionValidationProvider validationProvider, List historyPreinscriptions) {
    if (validationProvider.isLoading && validationProvider.allPreinscriptions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (validationProvider.error != null) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
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
                validationProvider.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => validationProvider.refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (historyPreinscriptions.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun historique',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aucune préinscription n\'a encore été traitée',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => validationProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyPreinscriptions.length,
        itemBuilder: (context, index) {
          final preinscription = historyPreinscriptions[index];
          return PreinscriptionValidationCardRedesigned(
            preinscription: preinscription,
            isProcessing: false, // Historique, pas de traitement en cours
            onValidate: null, // Pas de validation dans l'historique
            onReject: null, // Pas de rejet dans l'historique
            onTap: () => _showPreinscriptionDetails(preinscription),
          );
        },
      ),
    );
  }

  void _validatePreinscription(PreinscriptionValidationProvider provider, dynamic preinscription, String comments) {
    // Implémenter la logique de validation
    provider.validatePreinscription(preinscription.id, comments);
  }

  void _rejectPreinscription(PreinscriptionValidationProvider provider, dynamic preinscription, String reason) {
    // Implémenter la logique de rejet
    provider.rejectPreinscription(preinscription.id, reason);
  }

  Widget _buildValidationContent(PreinscriptionValidationProvider validationProvider) {
    if (validationProvider.isLoading && validationProvider.preinscriptions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (validationProvider.error != null) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
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
                validationProvider.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => validationProvider.refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (validationProvider.preinscriptions.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune préinscription à valider',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toutes les préinscriptions sont traitées',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => validationProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: validationProvider.preinscriptions.length,
        itemBuilder: (context, index) {
          final preinscription = validationProvider.preinscriptions[index];
          return PreinscriptionValidationCardRedesigned(
            preinscription: preinscription,
            isProcessing: validationProvider.isProcessing,
            onValidate: (comments) => _validatePreinscription(validationProvider, preinscription, comments),
            onReject: (reason) => _rejectPreinscription(validationProvider, preinscription, reason),
            onTap: () => _showPreinscriptionDetails(preinscription),
          );
        },
      ),
    );
  }

  void _showValidationFilters(BuildContext context, PreinscriptionValidationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.filter_list_rounded, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Filtres de validation',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Filtres
              Expanded(
                child: PreinscriptionValidationFiltersRedesigned(
                  searchQuery: provider.searchQuery,
                  onSearchChanged: (value) => provider.setSearchQuery(value),
                ),
              ),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Effacer tout'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreinscriptionDetails(dynamic preinscription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => validation_detail.PreinscriptionDetailPage(
          preinscription: preinscription,
        ),
      ),
    );
  }
}
