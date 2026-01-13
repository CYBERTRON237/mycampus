import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/institutions/presentation/providers/institution_provider.dart';
import 'package:mycampus/core/widgets/loading_widget.dart';
import 'package:mycampus/core/widgets/error_widget.dart' as custom_error;
import 'package:mycampus/features/auth/presentation/widgets/app_bar.dart';
import '../widgets/institution_card.dart';

class InstitutionsListPage extends StatefulWidget {
  const InstitutionsListPage({super.key});

  @override
  _InstitutionsListPageState createState() => _InstitutionsListPageState();
}

class _InstitutionsListPageState extends State<InstitutionsListPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // On utilise addPostFrameCallback pour s'assurer que le build est terminé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstitutions();
    });
  }

  Future<void> _loadInstitutions() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<InstitutionProvider>(context, listen: false);
      await provider.loadInstitutions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des institutions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _searchInstitutions(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un établissement...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _searchInstitutions,
            ),
          ),
          Expanded(
            child: _buildInstitutionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Naviguer vers la page de création d'institution
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const CreateInstitutionPage(),
          //   ),
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInstitutionsList() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return Consumer<InstitutionProvider>(
      builder: (context, provider, _) {
        if (provider.error != null) {
          return custom_error.ErrorWidget(
            message: 'Impossible de charger les établissements',
            onRetry: _loadInstitutions,
          );
        }

        final institutions = _searchQuery.isEmpty
            ? provider.institutions
            : provider.institutions
                .where((institution) =>
                    institution.name.toLowerCase().contains(_searchQuery) ||
                    (institution.city?.toLowerCase().contains(_searchQuery) ??
                        false))
                .toList();

        if (institutions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'Aucun établissement trouvé'
                      : 'Aucun résultat pour "$_searchQuery"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Appuyez sur + pour en ajouter un'),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadInstitutions,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: institutions.length,
            itemBuilder: (context, index) {
              final institution = institutions[index];
              return InstitutionCard(
                institution: institution,
                onTap: () {
                  // TODO: Naviguer vers la page de détail
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         InstitutionDetailPage(institutionId: institution.id),
                  //   ),
                  // );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
