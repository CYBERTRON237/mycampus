import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';

class EnhancedStudentDetailPage extends StatefulWidget {
  final EnhancedStudentModel student;

  const EnhancedStudentDetailPage({
    super.key,
    required this.student,
  });

  @override
  State<EnhancedStudentDetailPage> createState() => _EnhancedStudentDetailPageState();
}

class _EnhancedStudentDetailPageState extends State<EnhancedStudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.student.fullName),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(icon: Icon(Icons.person), text: 'Profil'),
          Tab(icon: Icon(Icons.school), text: 'Académique'),
          Tab(icon: Icon(Icons.contact_page), text: 'Contact'),
          Tab(icon: Icon(Icons.medical_services), text: 'Médical'),
          Tab(icon: Icon(Icons.history), text: 'Historique'),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Edit student
          },
          icon: const Icon(Icons.edit),
          tooltip: 'Modifier',
        ),
        PopupMenuButton<String>(
          onSelected: (action) => _handleMenuAction(action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'print',
              child: ListTile(
                leading: Icon(Icons.print),
                title: Text('Imprimer'),
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Exporter'),
              ),
            ),
            const PopupMenuItem(
              value: 'message',
              child: ListTile(
                leading: Icon(Icons.message),
                title: Text('Envoyer un message'),
              ),
            ),
            const PopupMenuItem(
              value: 'documents',
              child: ListTile(
                leading: Icon(Icons.folder),
                title: Text('Documents'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildProfileTab(),
        _buildAcademicTab(),
        _buildContactTab(),
        _buildMedicalTab(),
        _buildHistoryTab(),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(),
          
          const SizedBox(height: 24),
          
          // Basic information
          _buildBasicInformation(),
          
          const SizedBox(height: 24),
          
          // Personal details
          _buildPersonalDetails(),
          
          const SizedBox(height: 24),
          
          // Emergency contact
          if (widget.student.emergencyContactName != null)
            _buildEmergencyContact(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: widget.student.profilePhotoUrl != null
                  ? NetworkImage(widget.student.profilePhotoUrl!)
                  : null,
              backgroundColor: Colors.white,
              child: widget.student.profilePhotoUrl == null
                  ? Text(
                      widget.student.firstName.isNotEmpty 
                          ? widget.student.firstName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.student.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.student.matricule,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(widget.student.status),
                      const SizedBox(width: 8),
                      if (widget.student.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Vérifié',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return _buildSection(
      'Informations de base',
      Icons.person,
      [
        _buildInfoRow('Matricule', widget.student.matricule),
        _buildInfoRow('Nom', widget.student.lastName),
        _buildInfoRow('Prénom', widget.student.firstName),
        if (widget.student.middleName != null)
          _buildInfoRow('Autre prénom', widget.student.middleName!),
        _buildInfoRow('Email', widget.student.email),
        if (widget.student.phone != null)
          _buildInfoRow('Téléphone', widget.student.phone!),
        if (widget.student.alternativePhone != null)
          _buildInfoRow('Téléphone alternatif', widget.student.alternativePhone!),
      ],
    );
  }

  Widget _buildPersonalDetails() {
    return _buildSection(
      'Détails personnels',
      Icons.info,
      [
        if (widget.student.dateOfBirth != null)
          _buildInfoRow('Date de naissance', '${widget.student.dateOfBirth!.day}/${widget.student.dateOfBirth!.month}/${widget.student.dateOfBirth!.year}'),
        if (widget.student.placeOfBirth != null)
          _buildInfoRow('Lieu de naissance', widget.student.placeOfBirth!),
        _buildInfoRow('Genre', _getGenderLabel(widget.student.gender)),
        _buildInfoRow('Nationalité', widget.student.nationality),
        if (widget.student.bio != null)
          _buildInfoRow('Biographie', widget.student.bio!),
      ],
    );
  }

  Widget _buildEmergencyContact() {
    return _buildSection(
      'Contact d\'urgence',
      Icons.emergency,
      [
        _buildInfoRow('Nom', widget.student.emergencyContactName!),
        if (widget.student.emergencyContactPhone != null)
          _buildInfoRow('Téléphone', widget.student.emergencyContactPhone!),
        if (widget.student.emergencyContactRelationship != null)
          _buildInfoRow('Relation', widget.student.emergencyContactRelationship!),
        if (widget.student.emergencyContactEmail != null)
          _buildInfoRow('Email', widget.student.emergencyContactEmail!),
      ],
    );
  }

  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Academic summary
          _buildAcademicSummary(),
          
          const SizedBox(height: 24),
          
          // Academic details
          _buildAcademicDetails(),
          
          const SizedBox(height: 24),
          
          // Performance metrics
          _buildPerformanceMetrics(),
          
          const SizedBox(height: 24),
          
          // Scholarship information
          if (widget.student.scholarshipStatus != ScholarshipStatus.none)
            _buildScholarshipInfo(),
        ],
      ),
    );
  }

  Widget _buildAcademicSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Résumé académique',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Niveau',
                    widget.student.levelLabel,
                    Icons.school,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Statut',
                    widget.student.statusLabel,
                    Icons.info,
                    _getStatusColor(widget.student.status),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'GPA',
                    widget.student.gpaDisplay,
                    Icons.grade,
                    _getGpaColor(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Progression',
                    '${widget.student.progressPercentage.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    _getProgressColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicDetails() {
    return _buildSection(
      'Détails académiques',
      Icons.school,
      [
        _buildInfoRow('Statut', widget.student.statusLabel),
        _buildInfoRow('Niveau actuel', widget.student.levelLabel),
        _buildInfoRow('Type d\'admission', widget.student.admissionTypeLabel),
        _buildInfoRow('Date d\'inscription', '${widget.student.enrollmentDate.day}/${widget.student.enrollmentDate.month}/${widget.student.enrollmentDate.year}'),
        if (widget.student.expectedGraduationDate != null)
          _buildInfoRow('Date de diplomation prévue', '${widget.student.expectedGraduationDate!.day}/${widget.student.expectedGraduationDate!.month}/${widget.student.expectedGraduationDate!.year}'),
        if (widget.student.actualGraduationDate != null)
          _buildInfoRow('Date de diplomation réelle', '${widget.student.actualGraduationDate!.day}/${widget.student.actualGraduationDate!.month}/${widget.student.actualGraduationDate!.year}'),
        _buildInfoRow('Institution', widget.student.institutionDisplay),
        _buildInfoRow('Crédits obtenus', '${widget.student.totalCreditsEarned}'),
        if (widget.student.totalCreditsRequired != null)
          _buildInfoRow('Crédits requis', '${widget.student.totalCreditsRequired}'),
        if (widget.student.classRank != null)
          _buildInfoRow('Classement', '${widget.student.classRank}'),
        if (widget.student.honors != null)
          _buildInfoRow('Distinctions', widget.student.honors!),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return _buildSection(
      'Indicateurs de performance',
      Icons.analytics,
      [
        if (widget.student.gpa != null)
          _buildInfoRow('GPA', widget.student.gpaDisplay),
        _buildInfoRow('Crédits obtenus', '${widget.student.totalCreditsEarned}'),
        if (widget.student.totalCreditsRequired != null)
          _buildInfoRow('Crédits requis', '${widget.student.totalCreditsRequired}'),
        _buildInfoRow('Progression', '${widget.student.progressPercentage.toStringAsFixed(1)}%'),
        if (widget.student.classRank != null)
          _buildInfoRow('Classement', '${widget.student.classRank}'),
      ],
    );
  }

  Widget _buildScholarshipInfo() {
    return _buildSection(
      'Information de bourse',
      Icons.card_giftcard,
      [
        _buildInfoRow('Statut', widget.student.scholarshipStatusLabel),
        if (widget.student.scholarshipDetails != null)
          _buildInfoRow('Détails', widget.student.scholarshipDetails!),
        if (widget.student.scholarshipAmount != null)
          _buildInfoRow('Montant', '${widget.student.scholarshipAmount!.toStringAsFixed(0)} FCFA'),
      ],
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact information
          _buildContactInformation(),
          
          const SizedBox(height: 24),
          
          // Address information
          _buildAddressInformation(),
        ],
      ),
    );
  }

  Widget _buildContactInformation() {
    return _buildSection(
      'Coordonnées',
      Icons.contact_page,
      [
        _buildInfoRow('Email', widget.student.email),
        if (widget.student.phone != null)
          _buildInfoRow('Téléphone', widget.student.phone!),
        if (widget.student.alternativePhone != null)
          _buildInfoRow('Téléphone alternatif', widget.student.alternativePhone!),
      ],
    );
  }

  Widget _buildAddressInformation() {
    return _buildSection(
      'Adresse',
      Icons.location_on,
      [
        _buildInfoRow('Adresse', widget.student.address),
        _buildInfoRow('Ville', widget.student.city),
        _buildInfoRow('Région', widget.student.region),
        _buildInfoRow('Pays', widget.student.country),
        if (widget.student.postalCode != null)
          _buildInfoRow('Code postal', widget.student.postalCode!),
      ],
    );
  }

  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medical information
          if (widget.student.bloodGroup != null || 
              widget.student.medicalConditions != null ||
              widget.student.allergies != null ||
              widget.student.dietaryRestrictions != null ||
              widget.student.physicalDisabilities != null ||
              widget.student.needsSpecialAccommodation == true)
            _buildMedicalInformation()
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune information médicale disponible',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalInformation() {
    return _buildSection(
      'Informations médicales',
      Icons.medical_services,
      [
        if (widget.student.bloodGroup != null)
          _buildInfoRow('Groupe sanguin', widget.student.bloodGroup!),
        if (widget.student.medicalConditions != null)
          _buildInfoRow('Conditions médicales', widget.student.medicalConditions!),
        if (widget.student.allergies != null)
          _buildInfoRow('Allergies', widget.student.allergies!),
        if (widget.student.dietaryRestrictions != null)
          _buildInfoRow('Restrictions alimentaires', widget.student.dietaryRestrictions!),
        if (widget.student.physicalDisabilities != null)
          _buildInfoRow('Handicaps physiques', widget.student.physicalDisabilities!),
        if (widget.student.needsSpecialAccommodation != null)
          _buildInfoRow('Besoin d\'aménagement spécial', widget.student.needsSpecialAccommodation! ? 'Oui' : 'Non'),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          _buildTimeline(),
          
          const SizedBox(height: 24),
          
          // Skills and interests
          if (widget.student.languages != null || 
              widget.student.hobbies != null ||
              widget.student.skills != null ||
              widget.student.previousEducation != null ||
              widget.student.workExperience != null ||
              widget.student.references != null)
            _buildSkillsAndInterests(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return _buildSection(
      'Chronologie',
      Icons.timeline,
      [
        _buildInfoRow('Date de création', '${widget.student.createdAt.day}/${widget.student.createdAt.month}/${widget.student.createdAt.year} à ${widget.student.createdAt.hour}:${widget.student.createdAt.minute}'),
        if (widget.student.updatedAt != null)
          _buildInfoRow('Dernière mise à jour', '${widget.student.updatedAt!.day}/${widget.student.updatedAt!.month}/${widget.student.updatedAt!.year} à ${widget.student.updatedAt!.hour}:${widget.student.updatedAt!.minute}'),
        if (widget.student.actualGraduationDate != null)
          _buildInfoRow('Date de diplomation', '${widget.student.actualGraduationDate!.day}/${widget.student.actualGraduationDate!.month}/${widget.student.actualGraduationDate!.year}'),
        if (widget.student.thesisDefenseDate != null)
          _buildInfoRow('Date de soutenance', '${widget.student.thesisDefenseDate!.day}/${widget.student.thesisDefenseDate!.month}/${widget.student.thesisDefenseDate!.year}'),
      ],
    );
  }

  Widget _buildSkillsAndInterests() {
    return _buildSection(
      'Compétences et centres d\'intérêt',
      Icons.psychology,
      [
        if (widget.student.languages != null)
          _buildInfoRow('Langues', widget.student.languages!),
        if (widget.student.hobbies != null)
          _buildInfoRow('Centres d\'intérêt', widget.student.hobbies!),
        if (widget.student.skills != null)
          _buildInfoRow('Compétences', widget.student.skills!),
        if (widget.student.previousEducation != null)
          _buildInfoRow('Éducation précédente', widget.student.previousEducation!),
        if (widget.student.workExperience != null)
          _buildInfoRow('Expérience professionnelle', widget.student.workExperience!),
        if (widget.student.references != null)
          _buildInfoRow('Références', widget.student.references!),
      ],
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...children,
          ],
        ),
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
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StudentStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case StudentStatus.enrolled:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case StudentStatus.graduated:
        color = Colors.blue;
        icon = Icons.school;
        break;
      case StudentStatus.suspended:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case StudentStatus.withdrawn:
        color = Colors.red;
        icon = Icons.exit_to_app;
        break;
      case StudentStatus.deferred:
        color = Colors.purple;
        icon = Icons.schedule;
        break;
      case StudentStatus.onLeave:
        color = Colors.teal;
        icon = Icons.beach_access;
        break;
      case StudentStatus.expelled:
        color = Colors.red.shade900;
        icon = Icons.block;
        break;
      case StudentStatus.deceased:
        color = Colors.grey;
        icon = Icons.memory;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            widget.student.statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Send message to student
      },
      icon: const Icon(Icons.message),
      label: const Text('Envoyer un message'),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'print':
        // Handle print
        break;
      case 'export':
        // Handle export
        break;
      case 'message':
        // Handle message
        break;
      case 'documents':
        // Handle documents
        break;
    }
  }

  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'male':
        return 'Masculin';
      case 'female':
        return 'Féminin';
      case 'other':
        return 'Autre';
      default:
        return gender;
    }
  }

  Color _getStatusColor(StudentStatus status) {
    switch (status) {
      case StudentStatus.enrolled:
        return Colors.green;
      case StudentStatus.graduated:
        return Colors.blue;
      case StudentStatus.suspended:
        return Colors.orange;
      case StudentStatus.withdrawn:
        return Colors.red;
      case StudentStatus.deferred:
        return Colors.purple;
      case StudentStatus.onLeave:
        return Colors.teal;
      case StudentStatus.expelled:
        return Colors.red.shade900;
      case StudentStatus.deceased:
        return Colors.grey;
    }
  }

  Color _getGpaColor() {
    if (widget.student.gpa == null) return Colors.grey;
    
    final gpa = widget.student.gpa!;
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.blue;
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }

  Color _getProgressColor() {
    final progress = widget.student.progressPercentage;
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.blue;
    if (progress >= 40) return Colors.orange;
    return Colors.red;
  }
}
