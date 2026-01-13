import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/preinscription_validation/providers/preinscription_validation_provider.dart';
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';
import 'package:mycampus/features/preinscription_validation/presentation/widgets/preinscription_validation_card_redesigned.dart';
import 'package:mycampus/features/preinscription_validation/presentation/widgets/preinscription_validation_filters_redesigned.dart';
import 'package:mycampus/features/preinscription_validation/presentation/widgets/preinscription_validation_stats_redesigned.dart';
import 'package:mycampus/features/preinscription_validation/presentation/pages/preinscription_detail_page.dart';

class PreinscriptionValidationRedesignedPage extends StatefulWidget {
  const PreinscriptionValidationRedesignedPage({super.key});

  @override
  State<PreinscriptionValidationRedesignedPage> createState() => _PreinscriptionValidationRedesignedPageState();
}

class _PreinscriptionValidationRedesignedPageState extends State<PreinscriptionValidationRedesignedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreinscriptionValidationProvider>().refresh();
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Validation des Préinscriptions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<PreinscriptionValidationProvider>().refresh(),
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _exportData(),
            tooltip: 'Exporter',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barre de recherche simplifiée dans l'AppBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: TextEditingController(text: _searchQuery),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() => _searchQuery = '');
                              context.read<PreinscriptionValidationProvider>().setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear_rounded, size: 20),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    context.read<PreinscriptionValidationProvider>().setSearchQuery(value);
                  },
                ),
              ),
              
              // Onglets
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.pending_actions_rounded),
                      text: 'À Valider',
                    ),
                    Tab(
                      icon: Icon(Icons.analytics_rounded),
                      text: 'Statistiques',
                    ),
                    Tab(
                      icon: Icon(Icons.history_rounded),
                      text: 'Historique',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres complets dans le corps de la page
          PreinscriptionValidationFiltersRedesigned(
            searchQuery: _searchQuery,
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
              context.read<PreinscriptionValidationProvider>().setSearchQuery(value);
            },
          ),
          
          // Statistiques rapides compactes
          Consumer<PreinscriptionValidationProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatCard(
                        context,
                        'En attente',
                        provider.pendingCount.toString(),
                        Icons.pending_rounded,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactStatCard(
                        context,
                        'Validées',
                        provider.allPreinscriptions.where((p) => p.status == 'accepted').length.toString(),
                        Icons.check_circle_rounded,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactStatCard(
                        context,
                        'Rejetées',
                        provider.allPreinscriptions.where((p) => p.status == 'rejected').length.toString(),
                        Icons.cancel_rounded,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Contenu principal
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildValidationTab(),
                _buildStatsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return Consumer<PreinscriptionValidationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.preinscriptions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
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
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
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

        if (provider.preinscriptions.isEmpty) {
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
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.preinscriptions.length,
            itemBuilder: (context, index) {
              final preinscription = provider.preinscriptions[index];
              return PreinscriptionValidationCardRedesigned(
                preinscription: preinscription,
                isProcessing: provider.isProcessing,
                onValidate: (comments) => _validatePreinscription(preinscription, comments),
                onReject: (reason) => _rejectPreinscription(preinscription, reason),
                onTap: () => _showPreinscriptionDetails(preinscription),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return const PreinscriptionValidationStatsRedesigned();
  }

  Widget _buildHistoryTab() {
    return Consumer<PreinscriptionValidationProvider>(
      builder: (context, provider, child) {
        final historyPreinscriptions = provider.allPreinscriptions
            .where((p) => p.status != 'pending' && p.status != 'under_review')
            .toList();

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
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyPreinscriptions.length,
          itemBuilder: (context, index) {
            final preinscription = historyPreinscriptions[index];

        return PreinscriptionValidationCardRedesigned(
          preinscription: preinscription,
          isProcessing: false,
          onValidate: null,
          onReject: null,
          onTap: () => _showPreinscriptionDetails(
            preinscription,
          ),
        );
          },
        );
      },
    );
  }

  void _validatePreinscription(
    PreinscriptionValidationModel preinscription,
    String comments,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la validation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous valider cette préinscription ?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Commentaires (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => comments = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<PreinscriptionValidationProvider>()
          .validatePreinscription(
            preinscription.id,
            comments,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préinscription validée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _rejectPreinscription(
    PreinscriptionValidationModel preinscription,
    String reason,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le rejet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous rejeter cette préinscription ?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Motif du rejet',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => reason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<PreinscriptionValidationProvider>()
          .rejectPreinscription(
            preinscription.id,
            reason,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préinscription rejetée'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPreinscriptionDetails(
    PreinscriptionValidationModel preinscription,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreinscriptionDetailPage(
          preinscription: preinscription,
        ),
      ),
    );
  }

  void _exportData() {
    // TODO: Implémenter l'exportation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'export bientôt disponible'),
      ),
    );
  }
}
