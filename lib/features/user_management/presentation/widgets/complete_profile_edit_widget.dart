import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../providers/user_management_provider.dart';

class CompleteProfileEditWidget extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onProfileUpdated;

  const CompleteProfileEditWidget({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<CompleteProfileEditWidget> createState() => _CompleteProfileEditWidgetState();
}

class _CompleteProfileEditWidgetState extends State<CompleteProfileEditWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _matriculeController = TextEditingController();

  // Dropdown values
  String? _selectedPrimaryRole;
  String? _selectedAccountStatus;

  // Password change
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _changePassword = false;

  // Roles management
  List<Map<String, dynamic>> _allRoles = [];
  List<Map<String, dynamic>> _userRoles = [];
  List<Map<String, dynamic>> _availableRoles = [];
  bool _isLoadingRoles = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFields();
    _loadRoles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _matriculeController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _initializeFields() {
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _emailController.text = widget.user.email;
    _matriculeController.text = widget.user.matricule ?? '';
    
    _selectedPrimaryRole = widget.user.primaryRole;
    _selectedAccountStatus = widget.user.accountStatus;
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
    });

    try {
      // Simuler le chargement des rôles depuis l'API
      // En réalité, vous appelleriez votre API ici
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Rôles complets basés sur la base de données
      _allRoles = [
        // National Institutional
        {'id': 1, 'code': 'MINESUP_MINISTER', 'name': 'Ministre de l\'Enseignement Supérieur', 'category': 'national_institutional', 'level': 100},
        {'id': 2, 'code': 'MINESUP_SECRETARY', 'name': 'Secrétaire Général MINESUP', 'category': 'national_institutional', 'level': 95},
        {'id': 3, 'code': 'MINRESIP_DIRECTOR', 'name': 'Directeur MINRESI', 'category': 'national_institutional', 'level': 90},
        {'id': 4, 'code': 'CNES_PRESIDENT', 'name': 'Président CNES', 'category': 'national_institutional', 'level': 88},
        {'id': 5, 'code': 'CAAQES_DIRECTOR', 'name': 'Directeur CAAQES', 'category': 'national_institutional', 'level': 85},
        {'id': 6, 'code': 'INSPECTOR_GENERAL', 'name': 'Inspecteur Général', 'category': 'national_institutional', 'level': 87},
        
        // University Hierarchy
        {'id': 7, 'code': 'UNIV_RECTOR', 'name': 'Recteur d\'Université', 'category': 'university_hierarchy', 'level': 92},
        {'id': 8, 'code': 'UNIV_VICE_RECTOR', 'name': 'Vice-Recteur', 'category': 'university_hierarchy', 'level': 88},
        {'id': 9, 'code': 'UNIV_SECRETARY', 'name': 'Secrétaire Général', 'category': 'university_hierarchy', 'level': 85},
        {'id': 10, 'code': 'FACULTY_DEAN', 'name': 'Doyen de Faculté', 'category': 'university_hierarchy', 'level': 80},
        {'id': 11, 'code': 'SCHOOL_DIRECTOR', 'name': 'Directeur d\'École', 'category': 'university_hierarchy', 'level': 78},
        {'id': 12, 'code': 'DEPARTMENT_HEAD', 'name': 'Chef de Département', 'category': 'university_hierarchy', 'level': 75},
        {'id': 13, 'code': 'SECTION_HEAD', 'name': 'Chef de Section', 'category': 'university_hierarchy', 'level': 70},
        {'id': 14, 'code': 'PROGRAM_COORD', 'name': 'Coordonnateur de Programme', 'category': 'university_hierarchy', 'level': 68},
        
        // Teaching Staff
        {'id': 15, 'code': 'PROF_TITULAR', 'name': 'Professeur Titulaire', 'category': 'teaching_staff', 'level': 72},
        {'id': 16, 'code': 'PROF_ASSOCIATE', 'name': 'Professeur Associé', 'category': 'teaching_staff', 'level': 70},
        {'id': 17, 'code': 'MASTER_CONFERENCE', 'name': 'Maître de Conférences', 'category': 'teaching_staff', 'level': 68},
        {'id': 18, 'code': 'COURSE_HOLDER', 'name': 'Titulaire de Cours', 'category': 'teaching_staff', 'level': 65},
        {'id': 19, 'code': 'ASSISTANT', 'name': 'Assistant', 'category': 'teaching_staff', 'level': 60},
        {'id': 20, 'code': 'MONITOR', 'name': 'Moniteur', 'category': 'teaching_staff', 'level': 55},
        {'id': 21, 'code': 'TEMPORARY_TEACHER', 'name': 'Enseignant Temporaire', 'category': 'teaching_staff', 'level': 58},
        {'id': 22, 'code': 'VISITING_PROFESSOR', 'name': 'Professeur Visiteur', 'category': 'teaching_staff', 'level': 66},
        {'id': 23, 'code': 'POSTDOC_RESEARCHER', 'name': 'Chercheur Postdoc', 'category': 'teaching_staff', 'level': 62},
        
        // Administrative Technical
        {'id': 24, 'code': 'ADMINISTRATIVE_AGENT', 'name': 'Agent Administratif', 'category': 'administrative_technical', 'level': 50},
        {'id': 25, 'code': 'SECRETARY', 'name': 'Secrétaire', 'category': 'administrative_technical', 'level': 45},
        {'id': 26, 'code': 'ACCOUNTANT', 'name': 'Comptable', 'category': 'administrative_technical', 'level': 48},
        {'id': 27, 'code': 'LIBRARIAN', 'name': 'Bibliothécaire', 'category': 'administrative_technical', 'level': 52},
        {'id': 28, 'code': 'LAB_TECHNICIAN', 'name': 'Technicien de Labo', 'category': 'administrative_technical', 'level': 54},
        {'id': 29, 'code': 'MAINTENANCE_ENGINEER', 'name': 'Ingénieur Maintenance', 'category': 'administrative_technical', 'level': 56},
        {'id': 30, 'code': 'SECURITY_AGENT', 'name': 'Agent de Sécurité', 'category': 'administrative_technical', 'level': 40},
        {'id': 31, 'code': 'CLEANING_STAFF', 'name': 'Personnel de Nettoyage', 'category': 'administrative_technical', 'level': 35},
        {'id': 32, 'code': 'DRIVER', 'name': 'Chauffeur', 'category': 'administrative_technical', 'level': 38},
        {'id': 33, 'code': 'IT_SUPPORT', 'name': 'Support IT', 'category': 'administrative_technical', 'level': 58},
        
        // Student Representation
        {'id': 34, 'code': 'STUDENT_EXECUTIVE', 'name': 'Exécutif Étudiant', 'category': 'student_representation', 'level': 42},
        {'id': 35, 'code': 'CLASS_DELEGATE', 'name': 'Délégué de Classe', 'category': 'student_representation', 'level': 30},
        {'id': 36, 'code': 'FACULTY_DELEGATE', 'name': 'Délégué de Faculté', 'category': 'student_representation', 'level': 35},
        {'id': 37, 'code': 'RESIDENCE_DELEGATE', 'name': 'Délégué de Résidence', 'category': 'student_representation', 'level': 32},
        {'id': 38, 'code': 'CULTURAL_ASSOCIATION_LEADER', 'name': 'Leader Association Culturelle', 'category': 'student_representation', 'level': 38},
        {'id': 39, 'code': 'CLUB_PRESIDENT', 'name': 'Président de Club', 'category': 'student_representation', 'level': 36},
        {'id': 40, 'code': 'PROMOTION_COORDINATOR', 'name': 'Coordonnateur de Promotion', 'category': 'student_representation', 'level': 34},
        
        // Basic roles
        {'id': 41, 'code': 'STUDENT', 'name': 'Étudiant', 'category': 'academic', 'level': 25},
        {'id': 42, 'code': 'TEACHER', 'name': 'Enseignant', 'category': 'academic', 'level': 55},
        {'id': 43, 'code': 'STAFF', 'name': 'Personnel', 'category': 'administrative', 'level': 45},
        {'id': 44, 'code': 'ALUMNI', 'name': 'Ancien Étudiant', 'category': 'academic', 'level': 30},
        {'id': 45, 'code': 'MODERATOR', 'name': 'Modérateur', 'category': 'administrative', 'level': 60},
        {'id': 46, 'code': 'GUEST', 'name': 'Invité', 'category': 'academic', 'level': 10},
        {'id': 47, 'code': 'INVITE', 'name': 'Invité', 'category': 'academic', 'level': 15},
        
        // Administrative roles
        {'id': 48, 'code': 'ADMIN_LOCAL', 'name': 'Admin Local', 'category': 'administrative', 'level': 70},
        {'id': 49, 'code': 'ADMIN_NATIONAL', 'name': 'Admin National', 'category': 'administrative', 'level': 85},
        {'id': 50, 'code': 'SUPERADMIN', 'name': 'Super Admin', 'category': 'administrative', 'level': 95},
        {'id': 51, 'code': 'LEADER', 'name': 'Leader', 'category': 'administrative', 'level': 65},
        
        // Partners & Social
        {'id': 52, 'code': 'ECONOMIC_PARTNER', 'name': 'Partenaire Économique', 'category': 'partners_social', 'level': 20},
        {'id': 53, 'code': 'CHAMBER_COMMERCE', 'name': 'Chambre de Commerce', 'category': 'partners_social', 'level': 25},
        {'id': 54, 'code': 'EMPLOYER_ORGANIZATION', 'name': 'Organisation Employeur', 'category': 'partners_social', 'level': 22},
        {'id': 55, 'code': 'BANK_REPRESENTATIVE', 'name': 'Représentant Banque', 'category': 'partners_social', 'level': 28},
        {'id': 56, 'code': 'INSURANCE_REPRESENTATIVE', 'name': 'Représentant Assurance', 'category': 'partners_social', 'level': 26},
        {'id': 57, 'code': 'INTERNATIONAL_PARTNER', 'name': 'Partenaire International', 'category': 'partners_social', 'level': 32},
        {'id': 58, 'code': 'FOREIGN_EMBASSY', 'name': 'Ambassade Étrangère', 'category': 'partners_social', 'level': 40},
        {'id': 59, 'code': 'INTERNATIONAL_ORGANIZATION', 'name': 'Organisation Internationale', 'category': 'partners_social', 'level': 38},
        {'id': 60, 'code': 'NGO_REPRESENTATIVE', 'name': 'Représentant ONG', 'category': 'partners_social', 'level': 24},
        {'id': 61, 'code': 'SYNDICATE_REPRESENTATIVE', 'name': 'Représentant Syndicat', 'category': 'partners_social', 'level': 30},
        {'id': 62, 'code': 'PARENTS_ASSOCIATION', 'name': 'Association des Parents', 'category': 'partners_social', 'level': 18},
        {'id': 63, 'code': 'ALUMNI_REPRESENTATIVE', 'name': 'Représentant Anciens', 'category': 'partners_social', 'level': 28},
        {'id': 64, 'code': 'DEVELOPMENT_ASSOCIATION', 'name': 'Association de Développement', 'category': 'partners_social', 'level': 20},
        {'id': 65, 'code': 'CIVIL_SOCIETY_ORGANIZATION', 'name': 'Organisation Société Civile', 'category': 'partners_social', 'level': 22},
        
        // Support Services
        {'id': 66, 'code': 'DOCUMENTATION_CENTER', 'name': 'Centre de Documentation', 'category': 'support_services', 'level': 48},
        {'id': 67, 'code': 'ORIENTATION_COUNSELOR', 'name': 'Conseiller Orientation', 'category': 'support_services', 'level': 52},
        {'id': 68, 'code': 'MEDICAL_SERVICE', 'name': 'Service Médical', 'category': 'support_services', 'level': 56},
        {'id': 69, 'code': 'PSYCHOLOGICAL_SERVICE', 'name': 'Service Psychologique', 'category': 'support_services', 'level': 54},
        {'id': 70, 'code': 'RESTAURANT_SERVICE', 'name': 'Service Restaurant', 'category': 'support_services', 'level': 42},
        {'id': 71, 'code': 'HOUSING_SERVICE', 'name': 'Service Logement', 'category': 'support_services', 'level': 46},
        {'id': 72, 'code': 'SPORTS_SERVICE', 'name': 'Service Sport', 'category': 'support_services', 'level': 44},
        {'id': 73, 'code': 'CULTURAL_SERVICE', 'name': 'Service Culturel', 'category': 'support_services', 'level': 40},
        
        // Infrastructure & Logistics
        {'id': 74, 'code': 'BUILDING_SERVICE', 'name': 'Service Bâtiment', 'category': 'infrastructure_logistics', 'level': 50},
        {'id': 75, 'code': 'TRANSPORT_SERVICE', 'name': 'Service Transport', 'category': 'infrastructure_logistics', 'level': 45},
        {'id': 76, 'code': 'TELECOMMUNICATION_SERVICE', 'name': 'Service Télécommunication', 'category': 'infrastructure_logistics', 'level': 55},
        {'id': 77, 'code': 'ENERGY_SERVICE', 'name': 'Service Énergie', 'category': 'infrastructure_logistics', 'level': 52},
        {'id': 78, 'code': 'FIRE_SAFETY_SERVICE', 'name': 'Service Sécurité Incendie', 'category': 'infrastructure_logistics', 'level': 48},
        
        // Legal & Regulatory
        {'id': 79, 'code': 'PARLIAMENT_MEMBER', 'name': 'Membre Parlement', 'category': 'legal_regulatory', 'level': 85},
        {'id': 80, 'code': 'CONSTITUTIONAL_COUNCIL', 'name': 'Conseil Constitutionnel', 'category': 'legal_regulatory', 'level': 88},
        {'id': 81, 'code': 'SUPREME_COURT', 'name': 'Cour Suprême', 'category': 'legal_regulatory', 'level': 87},
        {'id': 82, 'code': 'ADMINISTRATIVE_TRIBUNAL', 'name': 'Tribunal Administratif', 'category': 'legal_regulatory', 'level': 75},
        {'id': 83, 'code': 'ACCOUNT_COMMISSARY', 'name': 'Commissaire aux Comptes', 'category': 'legal_regulatory', 'level': 70},
        {'id': 84, 'code': 'LEGAL_ADVISOR', 'name': 'Conseiller Juridique', 'category': 'legal_regulatory', 'level': 65},
        {'id': 85, 'code': 'STATE_CONTROL', 'name': 'Contrôle d\'État', 'category': 'legal_regulatory', 'level': 80},
        {'id': 86, 'code': 'FINANCE_INSPECTION', 'name': 'Inspection des Finances', 'category': 'legal_regulatory', 'level': 78},
        {'id': 87, 'code': 'ANTI_CORRUPTION_COMMISSION', 'name': 'Commission Anti-corruption', 'category': 'legal_regulatory', 'level': 82},
        {'id': 88, 'code': 'GOOD_GOVERNANCE_OBSERVATORY', 'name': 'Observatoire Bonne Gouvernance', 'category': 'legal_regulatory', 'level': 68},
        
        // Research & Innovation
        {'id': 89, 'code': 'RESEARCH_CENTER_DIRECTOR', 'name': 'Directeur Centre Recherche', 'category': 'research_innovation', 'level': 76},
        {'id': 90, 'code': 'RESEARCH_LABORATORY_HEAD', 'name': 'Chef Laboratoire Recherche', 'category': 'research_innovation', 'level': 74},
        {'id': 91, 'code': 'SPECIALIZED_INSTITUTE_DIRECTOR', 'name': 'Directeur Institut Spécialisé', 'category': 'research_innovation', 'level': 72},
        {'id': 92, 'code': 'EXCELLENCE_POLE_DIRECTOR', 'name': 'Directeur Pôle d\'Excellence', 'category': 'research_innovation', 'level': 70},
        {'id': 93, 'code': 'BUSINESS_INCUBATOR_MANAGER', 'name': 'Manager Incubateur Entreprise', 'category': 'research_innovation', 'level': 64},
        {'id': 94, 'code': 'TECHNOLOGY_PARK_MANAGER', 'name': 'Manager Parc Technologique', 'category': 'research_innovation', 'level': 66},
        {'id': 95, 'code': 'SCIENTIFIC_COMMUNITY_MEMBER', 'name': 'Membre Communauté Scientifique', 'category': 'research_innovation', 'level': 60},
        {'id': 96, 'code': 'ACADEMY_MEMBER', 'name': 'Membre Académie', 'category': 'research_innovation', 'level': 68},
        {'id': 97, 'code': 'LEARNED_SOCIETY_MEMBER', 'name': 'Membre Société Savante', 'category': 'research_innovation', 'level': 62},
        {'id': 98, 'code': 'EDITORIAL_BOARD_MEMBER', 'name': 'Membre Comité Éditorial', 'category': 'research_innovation', 'level': 56},
        {'id': 99, 'code': 'SCIENTIFIC_EVALUATOR', 'name': 'Évaluateur Scientifique', 'category': 'research_innovation', 'level': 58},
      ];

      // Simuler les rôles actuels de l'utilisateur
      _userRoles = _allRoles.where((role) => 
        role['code']?.toLowerCase() == widget.user.primaryRole.toLowerCase()
      ).toList();

      _updateAvailableRoles();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des rôles: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoadingRoles = false;
      });
    }
  }

  void _updateAvailableRoles() {
    final assignedRoleIds = _userRoles.map((role) => role['id']).toSet();
    setState(() {
      _availableRoles = _allRoles.where((role) => !assignedRoleIds.contains(role['id'])).toList();
    });
  }

  void _addRole(Map<String, dynamic> role) {
    setState(() {
      _userRoles.add(role);
      _updateAvailableRoles();
    });
  }

  void _removeRole(Map<String, dynamic> role) {
    setState(() {
      _userRoles.removeWhere((r) => r['id'] == role['id']);
      _updateAvailableRoles();
    });
  }

  List<Map<String, dynamic>> _getRolesByCategory(String category) {
    return _availableRoles.where((role) => role['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Modifier le profil de ${widget.user.fullName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Informations', icon: Icon(Icons.person)),
                Tab(text: 'Rôles', icon: Icon(Icons.admin_panel_settings)),
                Tab(text: 'Sécurité', icon: Icon(Icons.security)),
                Tab(text: 'Préférences', icon: Icon(Icons.settings)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalInfoTab(),
                  _buildRolesTab(),
                  _buildSecurityTab(),
                  _buildPreferencesTab(),
                ],
              ),
            ),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Sauvegarder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information
            const Text('Informations de base', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ obligatoire' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ obligatoire' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Champ obligatoire';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _matriculeController,
                    decoration: const InputDecoration(
                      labelText: 'Matricule',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Account Information
            const Text('Informations du compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedPrimaryRole,
              decoration: const InputDecoration(
                labelText: 'Rôle principal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              items: _allRoles.map<DropdownMenuItem<String>>((role) {
                return DropdownMenuItem<String>(
                  value: role['code']?.toString(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(role['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        '${role['category']} • Niveau ${role['level']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPrimaryRole = value),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedAccountStatus,
              decoration: const InputDecoration(
                labelText: 'Statut du compte',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Actif')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactif')),
                DropdownMenuItem(value: 'suspended', child: Text('Suspendu')),
                DropdownMenuItem(value: 'banned', child: Text('Banni')),
                DropdownMenuItem(value: 'pending_verification', child: Text('En attente de vérification')),
                DropdownMenuItem(value: 'graduated', child: Text('Diplômé')),
                DropdownMenuItem(value: 'withdrawn', child: Text('Retiré')),
              ],
              onChanged: (value) => setState(() => _selectedAccountStatus = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesTab() {
    if (_isLoadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Role
          const Text('Rôle principal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedPrimaryRole,
            decoration: const InputDecoration(
              labelText: 'Rôle principal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.admin_panel_settings),
            ),
            items: _allRoles.map<DropdownMenuItem<String>>((role) {
              return DropdownMenuItem<String>(
                value: role['code']?.toString(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(role['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      '${role['category']} • Niveau ${role['level']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedPrimaryRole = value),
          ),
          const SizedBox(height: 24),
          
          // Additional Roles
          const Text('Rôles additionnels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Assignez des rôles supplémentaires à cet utilisateur',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          
          // Current Roles
          if (_userRoles.isNotEmpty) ...[
            const Text('Rôles actuels', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ..._userRoles.map((role) => Card(
              child: ListTile(
                title: Text(role['name']),
                subtitle: Text('${role['category']} • Niveau ${role['level']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeRole(role),
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
          
          // Available Roles by Category
          const Text('Rôles disponibles', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          
          ...['national_institutional', 'university_hierarchy', 'teaching_staff', 'administrative_technical', 'student_representation', 'partners_social', 'support_services', 'infrastructure_logistics', 'legal_regulatory', 'research_innovation', 'academic', 'administrative'].map((category) {
            final categoryRoles = _getRolesByCategory(category);
            if (categoryRoles.isEmpty) return const SizedBox.shrink();
            
            return ExpansionTile(
              title: Text(_getCategoryDisplayName(category)),
              children: categoryRoles.map((role) => ListTile(
                title: Text(role['name']),
                subtitle: Text('Niveau ${role['level']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _addRole(role),
                ),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'national_institutional': return 'Institutionnel National';
      case 'university_hierarchy': return 'Hiérarchie Universitaire';
      case 'teaching_staff': return 'Personnel Enseignant';
      case 'administrative_technical': return 'Administratif et Technique';
      case 'student_representation': return 'Représentation Étudiante';
      case 'partners_social': return 'Partenaires et Social';
      case 'support_services': return 'Services de Support';
      case 'infrastructure_logistics': return 'Infrastructure et Logistique';
      case 'legal_regulatory': return 'Juridique et Réglementaire';
      case 'research_innovation': return 'Recherche et Innovation';
      case 'academic': return 'Académique';
      case 'administrative': return 'Administratif';
      default: return category;
    }
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Password Change
          const Text('Changement de mot de passe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Changer le mot de passe'),
            value: _changePassword,
            onChanged: (value) => setState(() => _changePassword = value ?? false),
          ),
          
          if (_changePassword) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) => _changePassword && (value?.isEmpty ?? true) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (_changePassword && (value?.isEmpty ?? true)) return 'Champ obligatoire';
                if (_changePassword && value != null && value.length < 8) {
                  return 'Le mot de passe doit contenir au moins 8 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (_changePassword && (value?.isEmpty ?? true)) return 'Champ obligatoire';
                if (_changePassword && value != _newPasswordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],
          
          // Account Status
          const Text('Statut du compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Compte actif'),
            subtitle: const Text('Un compte inactif ne peut pas se connecter'),
            value: widget.user.isActive,
            onChanged: (value) {
              // Vous pouvez implémenter la logique pour activer/désactiver le compte
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Préférences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          const Text('Cette section sera disponible prochainement avec les préférences utilisateur.'),
          const SizedBox(height: 16),
          
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.settings, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Fonctionnalités à venir:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Langue et région'),
                  Text('• Fuseau horaire'),
                  Text('• Paramètres de confidentialité'),
                  Text('• Notifications'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Appeler l'API pour mettre à jour l'utilisateur
      final provider = Provider.of<UserManagementProvider>(context, listen: false);
      
      // Créer un map avec les données à mettre à jour
      final userData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'matricule': _matriculeController.text,
      };
      
      final result = await provider.updateUser(
        widget.user.id, 
        userData
      );

      if (result.success) {
        widget.onProfileUpdated(widget.user);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
