import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';

class CompleteEditStudentDialog extends StatefulWidget {
  final StudentModel student;
  final Function(Map<String, dynamic>) onStudentUpdated;

  const CompleteEditStudentDialog({
    Key? key,
    required this.student,
    required this.onStudentUpdated,
  }) : super(key: key);

  @override
  State<CompleteEditStudentDialog> createState() => _CompleteEditStudentDialogState();
}

class _CompleteEditStudentDialogState extends State<CompleteEditStudentDialog> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers pour informations personnelles
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _regionController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _placeOfBirthController;
  late TextEditingController _nationalityController;
  late TextEditingController _bioController;
  late TextEditingController _matriculeController;
  
  // Controllers pour contact d'urgence
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelationshipController;
  
  // Controllers pour informations académiques
  late TextEditingController _gpaController;
  late TextEditingController _totalCreditsController;
  late TextEditingController _classRankController;
  late TextEditingController _honorsController;
  late TextEditingController _disciplinaryRecordsController;
  late TextEditingController _scholarshipDetailsController;
  late TextEditingController _thesisTitleController;
  late TextEditingController _thesisSupervisorController;
  
  // Variables sélectionnées
  String? _selectedGender;
  String? _selectedLevel;
  String? _selectedStatus;
  String? _selectedAdmissionType;
  String? _selectedScholarshipStatus;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedEnrollmentDate;
  DateTime? _selectedExpectedGraduationDate;
  DateTime? _selectedActualGraduationDate;
  DateTime? _selectedThesisDefenseDate;

  final List<String> _genders = ['male', 'female', 'other', 'prefer_not_to_say'];
  final List<String> _levels = [
    'licence1', 'licence2', 'licence3',
    'master1', 'master2',
    'doctorat1', 'doctorat2', 'doctorat3'
  ];
  final List<String> _statuses = [
    'active', 'inactive', 'suspended', 'banned', 
    'pending_verification', 'graduated', 'withdrawn'
  ];
  final List<String> _admissionTypes = ['regular', 'transfer', 'exchange', 'special'];
  final List<String> _scholarshipStatuses = ['none', 'partial', 'full', 'government', 'merit'];

  final Map<String, String> _genderLabels = {
    'male': 'Homme',
    'female': 'Femme',
    'other': 'Autre',
    'prefer_not_to_say': 'Préfère ne pas dire',
  };

  final Map<String, String> _levelLabels = {
    'licence1': 'Licence 1',
    'licence2': 'Licence 2',
    'licence3': 'Licence 3',
    'master1': 'Master 1',
    'master2': 'Master 2',
    'doctorat1': 'Doctorat 1',
    'doctorat2': 'Doctorat 2',
    'doctorat3': 'Doctorat 3',
  };

  final Map<String, String> _statusLabels = {
    'active': 'Actif',
    'inactive': 'Inactif',
    'suspended': 'Suspendu',
    'banned': 'Banni',
    'pending_verification': 'En attente',
    'graduated': 'Diplômé',
    'withdrawn': 'Retiré',
  };

  final Map<String, String> _admissionTypeLabels = {
    'regular': 'Régulier',
    'transfer': 'Transfert',
    'exchange': 'Échange',
    'special': 'Spécial',
  };

  final Map<String, String> _scholarshipStatusLabels = {
    'none': 'Aucune',
    'partial': 'Partielle',
    'full': 'Complète',
    'government': 'Gouvernementale',
    'merit': 'Au mérite',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeControllers();
  }

  void _initializeControllers() {
    // Informations personnelles
    _firstNameController = TextEditingController(text: widget.student.firstName);
    _middleNameController = TextEditingController(text: widget.student.middleName ?? '');
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phone ?? '');
    _addressController = TextEditingController(text: widget.student.address ?? '');
    _cityController = TextEditingController(text: widget.student.city ?? '');
    _regionController = TextEditingController(text: widget.student.region ?? '');
    _countryController = TextEditingController(text: widget.student.country ?? 'Cameroun');
    _postalCodeController = TextEditingController(text: widget.student.postalCode ?? '');
    _placeOfBirthController = TextEditingController(text: widget.student.placeOfBirth ?? '');
    _nationalityController = TextEditingController(text: widget.student.nationality ?? 'Camerounaise');
    _bioController = TextEditingController(text: widget.student.bio ?? '');
    _matriculeController = TextEditingController(text: widget.student.matricule);
    
    // Contact d'urgence
    _emergencyNameController = TextEditingController(text: widget.student.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: widget.student.emergencyContactPhone ?? '');
    _emergencyRelationshipController = TextEditingController(text: widget.student.emergencyContactRelationship ?? '');
    
    // Informations académiques
    _gpaController = TextEditingController(text: widget.student.profile.gpa?.toString() ?? '');
    _totalCreditsController = TextEditingController(text: widget.student.profile.totalCreditsRequired?.toString() ?? '');
    _classRankController = TextEditingController(text: widget.student.profile.classRank?.toString() ?? '');
    _honorsController = TextEditingController(text: widget.student.profile.honors ?? '');
    _disciplinaryRecordsController = TextEditingController(text: widget.student.profile.disciplinaryRecords ?? '');
    _scholarshipDetailsController = TextEditingController(text: widget.student.profile.scholarshipDetails ?? '');
    _thesisTitleController = TextEditingController(text: widget.student.profile.graduationThesisTitle ?? '');
    _thesisSupervisorController = TextEditingController(text: widget.student.profile.thesisSupervisor ?? '');
    
    // Variables sélectionnées
    _selectedGender = widget.student.gender;
    _selectedLevel = widget.student.profile.currentLevel;
    _selectedStatus = widget.student.accountStatus;
    _selectedAdmissionType = widget.student.profile.admissionType;
    _selectedScholarshipStatus = widget.student.profile.scholarshipStatus;
    _selectedDateOfBirth = widget.student.dateOfBirth;
    _selectedEnrollmentDate = widget.student.profile.enrollmentDate;
    _selectedExpectedGraduationDate = widget.student.profile.expectedGraduationDate;
    _selectedActualGraduationDate = widget.student.profile.actualGraduationDate;
    _selectedThesisDefenseDate = widget.student.profile.thesisDefenseDate;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    // Informations personnelles
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _placeOfBirthController.dispose();
    _nationalityController.dispose();
    _bioController.dispose();
    _matriculeController.dispose();
    
    // Contact d'urgence
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationshipController.dispose();
    
    // Informations académiques
    _gpaController.dispose();
    _totalCreditsController.dispose();
    _classRankController.dispose();
    _honorsController.dispose();
    _disciplinaryRecordsController.dispose();
    _scholarshipDetailsController.dispose();
    _thesisTitleController.dispose();
    _thesisSupervisorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.95,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modifier le profil étudiant complet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Informations personnelles'),
                Tab(text: 'Contact'),
                Tab(text: 'Académique'),
                Tab(text: 'Statut'),
              ],
              isScrollable: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalInfoTab(),
                  _buildContactTab(),
                  _buildAcademicTab(),
                  _buildStatusTab(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Identité'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le prénom est requis';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _middleNameController,
                          decoration: const InputDecoration(
                            labelText: 'Second prénom',
                            border: OutlineInputBorder(),
                          ),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le nom est requis';
                            }
                            return null;
                          },
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
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'L\'email est requis';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Veuillez entrer un email valide';
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
                            prefixIcon: Icon(Icons.badge),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _genders.contains(_selectedGender) ? _selectedGender : null,
                          decoration: const InputDecoration(
                            labelText: 'Sexe',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: _genders.map((gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(_genderLabels[gender] ?? gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectDateOfBirth,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de naissance',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDateOfBirth != null
                                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                  : 'Sélectionner une date',
                              style: TextStyle(
                                color: _selectedDateOfBirth != null 
                                    ? Colors.black 
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _placeOfBirthController,
                    decoration: const InputDecoration(
                      labelText: 'Lieu de naissance',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nationalityController,
                    decoration: const InputDecoration(
                      labelText: 'Nationalité',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Adresse'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse complète',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _regionController,
                          decoration: const InputDecoration(
                            labelText: 'Région',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Pays',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Code postal',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Biographie'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Biographie',
                  border: OutlineInputBorder(),
                  hintText: 'Parlez brièvement de vous...',
                ),
                maxLines: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Contact principal'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Contact d\'urgence'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emergencyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du contact d\'urgence',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone du contact d\'urgence',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyRelationshipController,
                    decoration: InputDecoration(
                      labelText: 'Relation avec le contact',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.family_restroom),
                      hintText: 'Ex: Père, Mère, Frère, Sœur, Ami...',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informations académiques'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _levels.contains(_selectedLevel) ? _selectedLevel : null,
                    decoration: const InputDecoration(
                      labelText: 'Niveau d\'étude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _levels.map((level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(_levelLabels[level] ?? level),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _admissionTypes.contains(_selectedAdmissionType) ? _selectedAdmissionType : null,
                    decoration: const InputDecoration(
                      labelText: 'Type d\'admission',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.how_to_reg),
                    ),
                    items: _admissionTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(_admissionTypeLabels[type] ?? type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAdmissionType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectEnrollmentDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date d\'inscription',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedEnrollmentDate != null
                                  ? '${_selectedEnrollmentDate!.day}/${_selectedEnrollmentDate!.month}/${_selectedEnrollmentDate!.year}'
                                  : 'Sélectionner une date',
                              style: TextStyle(
                                color: _selectedEnrollmentDate != null 
                                    ? Colors.black 
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectExpectedGraduationDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de fin prévue',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event),
                            ),
                            child: Text(
                              _selectedExpectedGraduationDate != null
                                  ? '${_selectedExpectedGraduationDate!.day}/${_selectedExpectedGraduationDate!.month}/${_selectedExpectedGraduationDate!.year}'
                                  : 'Sélectionner une date',
                              style: TextStyle(
                                color: _selectedExpectedGraduationDate != null 
                                    ? Colors.black 
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Performance académique'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _gpaController,
                          decoration: const InputDecoration(
                            labelText: 'Moyenne (GPA)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.grade),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _totalCreditsController,
                          decoration: const InputDecoration(
                            labelText: 'Crédits requis',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.credit_score),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _classRankController,
                          decoration: const InputDecoration(
                            labelText: 'Rang dans la classe',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.leaderboard),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _honorsController,
                    decoration: InputDecoration(
                      labelText: 'Distinctions et honneurs',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.emoji_events),
                      hintText: 'Liste des distinctions, prix, etc.',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Bourse et financement'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _scholarshipStatuses.contains(_selectedScholarshipStatus) ? _selectedScholarshipStatus : null,
                    decoration: const InputDecoration(
                      labelText: 'Statut de bourse',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: _scholarshipStatuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(_scholarshipStatusLabels[status] ?? status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedScholarshipStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _scholarshipDetailsController,
                    decoration: InputDecoration(
                      labelText: 'Détails de la bourse',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                      hintText: 'Description de la bourse, montant, conditions, etc.',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Thèse/Mémoire'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _thesisTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre de la thèse/mémoire',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _thesisSupervisorController,
                    decoration: const InputDecoration(
                      labelText: 'Superviseur de thèse',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectThesisDefenseDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de soutenance',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_available),
                      ),
                      child: Text(
                        _selectedThesisDefenseDate != null
                            ? '${_selectedThesisDefenseDate!.day}/${_selectedThesisDefenseDate!.month}/${_selectedThesisDefenseDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _selectedThesisDefenseDate != null 
                              ? Colors.black 
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Records disciplinaires'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _disciplinaryRecordsController,
                decoration: InputDecoration(
                  labelText: 'Records disciplinaires',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.gavel),
                  hintText: 'Historique des sanctions, avertissements, etc.',
                ),
                maxLines: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Statut du compte'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _statuses.contains(_selectedStatus) ? _selectedStatus : null,
                    decoration: const InputDecoration(
                      labelText: 'Statut du compte',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(_statusLabels[status] ?? status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectActualGraduationDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de fin d\'études réelle',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      child: Text(
                        _selectedActualGraduationDate != null
                            ? '${_selectedActualGraduationDate!.day}/${_selectedActualGraduationDate!.month}/${_selectedActualGraduationDate!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _selectedActualGraduationDate != null 
                              ? Colors.black 
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveStudent,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _selectEnrollmentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEnrollmentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 50)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedEnrollmentDate) {
      setState(() {
        _selectedEnrollmentDate = picked;
      });
    }
  }

  Future<void> _selectExpectedGraduationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpectedGraduationDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _selectedExpectedGraduationDate) {
      setState(() {
        _selectedExpectedGraduationDate = picked;
      });
    }
  }

  Future<void> _selectActualGraduationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedActualGraduationDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 50)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedActualGraduationDate) {
      setState(() {
        _selectedActualGraduationDate = picked;
      });
    }
  }

  Future<void> _selectThesisDefenseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedThesisDefenseDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _selectedThesisDefenseDate) {
      setState(() {
        _selectedThesisDefenseDate = picked;
      });
    }
  }

  void _saveStudent() {
    if (_firstNameController.text.isEmpty || 
        _lastNameController.text.isEmpty || 
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final studentData = {
      'id': widget.student.id,
      // Informations personnelles
      'first_name': _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'region': _regionController.text.trim().isEmpty ? null : _regionController.text.trim(),
      'country': _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
      'postal_code': _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
      'place_of_birth': _placeOfBirthController.text.trim().isEmpty ? null : _placeOfBirthController.text.trim(),
      'nationality': _nationalityController.text.trim().isEmpty ? null : _nationalityController.text.trim(),
      'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      'matricule': _matriculeController.text.trim().isEmpty ? null : _matriculeController.text.trim(),
      'gender': _selectedGender,
      'date_of_birth': _selectedDateOfBirth?.toIso8601String(),
      
      // Contact d'urgence
      'emergency_contact_name': _emergencyNameController.text.trim().isEmpty ? null : _emergencyNameController.text.trim(),
      'emergency_contact_phone': _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
      'emergency_contact_relationship': _emergencyRelationshipController.text.trim().isEmpty ? null : _emergencyRelationshipController.text.trim(),
      
      // Statut du compte
      'account_status': _selectedStatus,
      
      // Informations académiques
      'current_level': _selectedLevel,
      'admission_type': _selectedAdmissionType,
      'enrollment_date': _selectedEnrollmentDate?.toIso8601String(),
      'expected_graduation_date': _selectedExpectedGraduationDate?.toIso8601String(),
      'actual_graduation_date': _selectedActualGraduationDate?.toIso8601String(),
      
      // Performance académique
      'gpa': _gpaController.text.trim().isEmpty ? null : double.tryParse(_gpaController.text.trim()),
      'total_credits_required': _totalCreditsController.text.trim().isEmpty ? null : int.tryParse(_totalCreditsController.text.trim()),
      'class_rank': _classRankController.text.trim().isEmpty ? null : int.tryParse(_classRankController.text.trim()),
      'honors': _honorsController.text.trim().isEmpty ? null : _honorsController.text.trim(),
      'disciplinary_records': _disciplinaryRecordsController.text.trim().isEmpty ? null : _disciplinaryRecordsController.text.trim(),
      
      // Bourse
      'scholarship_status': _selectedScholarshipStatus,
      'scholarship_details': _scholarshipDetailsController.text.trim().isEmpty ? null : _scholarshipDetailsController.text.trim(),
      
      // Thèse
      'graduation_thesis_title': _thesisTitleController.text.trim().isEmpty ? null : _thesisTitleController.text.trim(),
      'thesis_supervisor': _thesisSupervisorController.text.trim().isEmpty ? null : _thesisSupervisorController.text.trim(),
      'thesis_defense_date': _selectedThesisDefenseDate?.toIso8601String(),
    };

    widget.onStudentUpdated(studentData);
    Navigator.of(context).pop();
  }
}
