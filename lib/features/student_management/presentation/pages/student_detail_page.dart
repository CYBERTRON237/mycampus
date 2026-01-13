import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../data/models/student_model_simple.dart';
import '../../data/models/simple_student_model.dart';

class StudentDetailPage extends StatefulWidget {
  final SimpleStudentModel student;

  const StudentDetailPage({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudentModelSimple? _detailedStudent;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStudentDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Chargement des détails pour l\'étudiant ID: ${widget.student.id}');
      final provider = context.read<StudentProvider>();
      final detailedStudent = await provider.getStudentById(widget.student.id);
      
      print('Résultat du chargement: ${detailedStudent != null ? "Succès" : "Échec"}');
      if (detailedStudent != null) {
        print('Nom de l\'étudiant: ${detailedStudent.firstName} ${detailedStudent.lastName}');
      }

      setState(() {
        _detailedStudent = detailedStudent;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadStudentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.fullName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editStudent();
                  break;
                case 'contact':
                  _contactStudent();
                  break;
                case 'export':
                  _exportStudentData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 8),
                    Text('Contacter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Exporter'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Informations'),
            Tab(icon: Icon(Icons.school), text: 'Académique'),
            Tab(icon: Icon(Icons.contact_mail), text: 'Contact'),
            Tab(icon: Icon(Icons.history), text: 'Historique'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Chargement des détails...'),
                  ],
                ),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _detailedStudent != null
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPersonalInfoTab(),
                        _buildAcademicTab(),
                        _buildContactTab(),
                        _buildHistoryTab(),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune information détaillée disponible',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editStudent,
        icon: const Icon(Icons.edit),
        label: const Text('Modifier'),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    if (_detailedStudent == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Informations personnelles',
            icon: Icons.person,
            child: Column(
              children: [
                _buildInfoRow('Nom complet', _detailedStudent!.fullName),
                _buildInfoRow('Matricule', _detailedStudent!.matricule ?? 'Non défini'),
                _buildInfoRow('Email', _detailedStudent!.email ?? 'Non renseigné'),
                _buildInfoRow('Téléphone', _detailedStudent!.phone ?? 'Non renseigné'),
                _buildInfoRow('Date de naissance', 
                    _detailedStudent!.dateOfBirth != null 
                        ? _detailedStudent!.dateOfBirth!
                        : 'Non renseignée'),
                _buildInfoRow('Genre', _detailedStudent!.gender ?? 'Non renseigné'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Statut du compte',
            icon: Icons.account_circle,
            child: Column(
              children: [
                _buildInfoRow('Statut', _detailedStudent!.status),
                _buildInfoRow('Dernière connexion', 
                    _detailedStudent!.lastLoginAt != null 
                        ? _detailedStudent!.lastLoginAt!
                        : 'Jamais'),
                _buildInfoRow('Date de création', 
                    _detailedStudent!.createdAt ?? 'Non renseignée'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTab() {
    if (_detailedStudent == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Informations académiques',
            icon: Icons.school,
            child: Column(
              children: [
                _buildInfoRow('Niveau actuel', _detailedStudent!.levelDisplay ?? _detailedStudent!.level ?? 'Non défini'),
                _buildInfoRow('Rôle principal', _detailedStudent!.primaryRole),
                _buildInfoRow('Vérifié', _detailedStudent!.isVerified ? 'Oui' : 'Non'),
                _buildInfoRow('Actif', _detailedStudent!.isActive ? 'Oui' : 'Non'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Institution',
            icon: Icons.account_balance,
            child: Column(
              children: [
                _buildInfoRow('Institution', _detailedStudent!.institutionName ?? 'Non définie'),
                _buildInfoRow('Niveau', _detailedStudent!.levelDisplay ?? _detailedStudent!.level ?? 'Non défini'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    if (_detailedStudent == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Coordonnées',
            icon: Icons.contact_mail,
            child: Column(
              children: [
                _buildInfoRow('Email', _detailedStudent!.email ?? 'Non renseigné'),
                _buildInfoRow('Téléphone', _detailedStudent!.phone ?? 'Non renseigné'),
                _buildInfoRow('Adresse', _detailedStudent!.address ?? 'Non renseignée'),
                _buildInfoRow('Ville', _detailedStudent!.city ?? 'Non renseignée'),
                _buildInfoRow('Pays', _detailedStudent!.country ?? 'Non renseigné'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Contact d\'urgence',
            icon: Icons.emergency,
            child: Column(
              children: [
                _buildInfoRow('Contact d\'urgence', 'Non renseigné'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Historique académique',
            icon: Icons.history,
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Inscription initiale'),
                  subtitle: Text('L1 - Année académique 2023-2024'),
                ),
                ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text('Progression'),
                  subtitle: Text('L1 → L2 - Promotion réussie'),
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Distinctions'),
                  subtitle: Text('Mention: Assez Bien'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Activités récentes',
            icon: Icons.history,
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Dernière connexion'),
                  subtitle: Text('Il y a 2 jours'),
                ),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Dernière modification'),
                  subtitle: Text('Il y a 1 semaine'),
                ),
                ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Dernier paiement'),
                  subtitle: Text('Il y a 2 semaines'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            titleTextStyle: Theme.of(context).textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _contactStudent(),
                    icon: const Icon(Icons.email),
                    label: const Text('Envoyer un email'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callStudent(),
                    icon: const Icon(Icons.phone),
                    label: const Text('Appeler'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _exportStudentData(),
                icon: const Icon(Icons.download),
                label: const Text('Exporter les données'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void _editStudent() {
    // TODO: Implémenter la modification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction de modification bientôt disponible')),
    );
  }

  void _contactStudent() {
    // TODO: Implémenter le contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction de contact bientôt disponible')),
    );
  }

  void _callStudent() {
    // TODO: Implémenter l'appel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction d\'appel bientôt disponible')),
    );
  }

  void _exportStudentData() {
    // TODO: Implémenter l'export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction d\'export bientôt disponible')),
    );
  }
}
