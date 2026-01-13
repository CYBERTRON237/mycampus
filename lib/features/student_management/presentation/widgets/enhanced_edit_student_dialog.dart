import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';

class EnhancedEditStudentDialog extends StatefulWidget {
  final EnhancedStudentModel student;
  final Function(EnhancedStudentModel) onStudentUpdated;

  const EnhancedEditStudentDialog({
    super.key,
    required this.student,
    required this.onStudentUpdated,
  });

  @override
  State<EnhancedEditStudentDialog> createState() => _EnhancedEditStudentDialogState();
}

class _EnhancedEditStudentDialogState extends State<EnhancedEditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late EnhancedStudentModel _editedStudent;
  
  // Controllers
  late TextEditingController _matriculeController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _alternativePhoneController;
  late TextEditingController _placeOfBirthController;
  late TextEditingController _nationalityController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _regionController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;
  late TextEditingController _emergencyContactRelationshipController;
  late TextEditingController _emergencyContactEmailController;
  late TextEditingController _bioController;
  
  // Dropdown values
  late String _selectedGender;
  late StudentStatus _selectedStatus;
  late AcademicLevel _selectedLevel;
  late AdmissionType _selectedAdmissionType;
  late ScholarshipStatus _selectedScholarshipStatus;
  late int _selectedInstitutionId;
  late int _selectedFacultyId;
  late int _selectedDepartmentId;
  late int _selectedProgramId;
  
  // Date values
  DateTime? _dateOfBirth;
  DateTime _enrollmentDate = DateTime.now();
  DateTime? _expectedGraduationDate;
  DateTime? _actualGraduationDate;
  DateTime? _thesisDefenseDate;
  
  // Academic values
  double? _gpa;
  int _totalCreditsEarned = 0;
  int? _totalCreditsRequired;
  int? _classRank;
  String? _honors;
  String? _disciplinaryRecords;
  String? _graduationThesisTitle;
  String? _thesisSupervisor;
  
  // Scholarship values
  String? _scholarshipDetails;
  double? _scholarshipAmount;
  
  // Medical values
  String? _bloodGroup;
  String? _medicalConditions;
  String? _allergies;
  String? _dietaryRestrictions;
  String? _physicalDisabilities;
  bool _needsSpecialAccommodation = false;
  
  // Skills and interests
  String? _languages;
  String? _hobbies;
  String? _skills;
  String? _previousEducation;
  String? _workExperience;
  String? _references;
  
  bool _isLoading = false;
  bool _isAdvancedMode = false;

  @override
  void initState() {
    super.initState();
    _editedStudent = widget.student;
    _initializeControllers();
    _initializeValues();
  }

  void _initializeControllers() {
    _matriculeController = TextEditingController(text: widget.student.matricule);
    _firstNameController = TextEditingController(text: widget.student.firstName);
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _middleNameController = TextEditingController(text: widget.student.middleName ?? '');
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phone ?? '');
    _alternativePhoneController = TextEditingController(text: widget.student.alternativePhone ?? '');
    _placeOfBirthController = TextEditingController(text: widget.student.placeOfBirth ?? '');
    _nationalityController = TextEditingController(text: widget.student.nationality);
    _addressController = TextEditingController(text: widget.student.address);
    _cityController = TextEditingController(text: widget.student.city);
    _regionController = TextEditingController(text: widget.student.region);
    _countryController = TextEditingController(text: widget.student.country);
    _postalCodeController = TextEditingController(text: widget.student.postalCode ?? '');
    _emergencyContactNameController = TextEditingController(text: widget.student.emergencyContactName ?? '');
    _emergencyContactPhoneController = TextEditingController(text: widget.student.emergencyContactPhone ?? '');
    _emergencyContactRelationshipController = TextEditingController(text: widget.student.emergencyContactRelationship ?? '');
    _emergencyContactEmailController = TextEditingController(text: widget.student.emergencyContactEmail ?? '');
    _bioController = TextEditingController(text: widget.student.bio ?? '');
  }

  void _initializeValues() {
    _selectedGender = widget.student.gender;
    _selectedStatus = widget.student.status;
    _selectedLevel = widget.student.currentLevel;
    _selectedAdmissionType = widget.student.admissionType;
    _selectedScholarshipStatus = widget.student.scholarshipStatus;
    _selectedInstitutionId = widget.student.institutionId;
    _selectedFacultyId = widget.student.facultyId ?? 1;
    _selectedDepartmentId = widget.student.departmentId ?? 1;
    _selectedProgramId = widget.student.programId ?? 1;
    
    _dateOfBirth = widget.student.dateOfBirth;
    _enrollmentDate = widget.student.enrollmentDate;
    _expectedGraduationDate = widget.student.expectedGraduationDate;
    _actualGraduationDate = widget.student.actualGraduationDate;
    _thesisDefenseDate = widget.student.thesisDefenseDate;
    
    _gpa = widget.student.gpa;
    _totalCreditsEarned = widget.student.totalCreditsEarned;
    _totalCreditsRequired = widget.student.totalCreditsRequired;
    _classRank = widget.student.classRank;
    _honors = widget.student.honors;
    _disciplinaryRecords = widget.student.disciplinaryRecords;
    _graduationThesisTitle = widget.student.graduationThesisTitle;
    _thesisSupervisor = widget.student.thesisSupervisor;
    
    _scholarshipDetails = widget.student.scholarshipDetails;
    _scholarshipAmount = widget.student.scholarshipAmount;
    
    _bloodGroup = widget.student.bloodGroup;
    _medicalConditions = widget.student.medicalConditions;
    _allergies = widget.student.allergies;
    _dietaryRestrictions = widget.student.dietaryRestrictions;
    _physicalDisabilities = widget.student.physicalDisabilities;
    _needsSpecialAccommodation = widget.student.needsSpecialAccommodation ?? false;
    
    _languages = widget.student.languages;
    _hobbies = widget.student.hobbies;
    _skills = widget.student.skills;
    _previousEducation = widget.student.previousEducation;
    _workExperience = widget.student.workExperience;
    _references = widget.student.references;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _matriculeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternativePhoneController.dispose();
    _placeOfBirthController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();
    _emergencyContactEmailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedStudent = widget.student.copyWith(
        matricule: _matriculeController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        alternativePhone: _alternativePhoneController.text.trim().isEmpty ? null : _alternativePhoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
        placeOfBirth: _placeOfBirthController.text.trim().isEmpty ? null : _placeOfBirthController.text.trim(),
        gender: _selectedGender,
        nationality: _nationalityController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        region: _regionController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim().isEmpty ? null : _emergencyContactNameController.text.trim(),
        emergencyContactPhone: _emergencyContactPhoneController.text.trim().isEmpty ? null : _emergencyContactPhoneController.text.trim(),
        emergencyContactRelationship: _emergencyContactRelationshipController.text.trim().isEmpty ? null : _emergencyContactRelationshipController.text.trim(),
        emergencyContactEmail: _emergencyContactEmailController.text.trim().isEmpty ? null : _emergencyContactEmailController.text.trim(),
        status: _selectedStatus,
        currentLevel: _selectedLevel,
        admissionType: _selectedAdmissionType,
        enrollmentDate: _enrollmentDate,
        expectedGraduationDate: _expectedGraduationDate,
        actualGraduationDate: _actualGraduationDate,
        gpa: _gpa,
        totalCreditsEarned: _totalCreditsEarned,
        totalCreditsRequired: _totalCreditsRequired,
        classRank: _classRank,
        honors: _honors,
        disciplinaryRecords: _disciplinaryRecords,
        graduationThesisTitle: _graduationThesisTitle,
        thesisSupervisor: _thesisSupervisor,
        thesisDefenseDate: _thesisDefenseDate,
        scholarshipStatus: _selectedScholarshipStatus,
        scholarshipDetails: _scholarshipDetails,
        scholarshipAmount: _scholarshipAmount,
        institutionId: _selectedInstitutionId,
        facultyId: _selectedFacultyId,
        departmentId: _selectedDepartmentId,
        programId: _selectedProgramId,
        bloodGroup: _bloodGroup,
        medicalConditions: _medicalConditions,
        allergies: _allergies,
        dietaryRestrictions: _dietaryRestrictions,
        physicalDisabilities: _physicalDisabilities,
        needsSpecialAccommodation: _needsSpecialAccommodation,
        languages: _languages,
        hobbies: _hobbies,
        skills: _skills,
        previousEducation: _previousEducation,
        workExperience: _workExperience,
        references: _references,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await widget.onStudentUpdated(updatedStudent);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.student.profilePhotoUrl != null
                      ? NetworkImage(widget.student.profilePhotoUrl!)
                      : null,
                  child: widget.student.profilePhotoUrl == null
                      ? Text(
                          widget.student.firstName.isNotEmpty 
                              ? widget.student.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modifier: ${widget.student.fullName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.student.matricule,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Toggle advanced mode
            Row(
              children: [
                Switch(
                  value: _isAdvancedMode,
                  onChanged: (value) {
                    setState(() {
                      _isAdvancedMode = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Mode avancé',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  _isAdvancedMode ? 'Tous les champs' : 'Champs essentiels',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Basic Information
                      _buildSectionHeader('Informations de base'),
                      _buildBasicInfoSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Academic Information
                      _buildSectionHeader('Informations académiques'),
                      _buildAcademicInfoSection(),
                      
                      if (_isAdvancedMode) ...[
                        const SizedBox(height: 24),
                        
                        // Contact Information
                        _buildSectionHeader('Informations de contact'),
                        _buildContactInfoSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Emergency Contact
                        _buildSectionHeader('Contact d\'urgence'),
                        _buildEmergencyContactSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Scholarship Information
                        _buildSectionHeader('Informations de bourse'),
                        _buildScholarshipSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Medical Information
                        _buildSectionHeader('Informations médicales'),
                        _buildMedicalSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Skills and Interests
                        _buildSectionHeader('Compétences et centres d\'intérêt'),
                        _buildSkillsSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateStudent,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mettre à jour'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(
                  labelText: 'Matricule *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Genre *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Masculin')),
                  DropdownMenuItem(value: 'female', child: Text('Féminin')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
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
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _middleNameController,
          decoration: const InputDecoration(
            labelText: 'Autre prénom',
            border: OutlineInputBorder(),
          ),
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        ListTile(
          title: const Text('Date de naissance'),
          subtitle: Text(_dateOfBirth != null 
              ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
              : 'Non sélectionnée'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _dateOfBirth = date;
              });
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _placeOfBirthController,
          decoration: const InputDecoration(
            labelText: 'Lieu de naissance',
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _nationalityController,
          decoration: const InputDecoration(
            labelText: 'Nationalité',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<StudentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: StudentStatus.values.map((status) {
                  return DropdownMenuItem<StudentStatus>(
                    value: status,
                    child: Text(status.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<AcademicLevel>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Niveau académique *',
                  border: OutlineInputBorder(),
                ),
                items: AcademicLevel.values.map((level) {
                  return DropdownMenuItem<AcademicLevel>(
                    value: level,
                    child: Text(level.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<AdmissionType>(
                value: _selectedAdmissionType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'admission',
                  border: OutlineInputBorder(),
                ),
                items: AdmissionType.values.map((type) {
                  return DropdownMenuItem<AdmissionType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAdmissionType = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ListTile(
                title: const Text('Date d\'inscription'),
                subtitle: Text('${_enrollmentDate.day}/${_enrollmentDate.month}/${_enrollmentDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _enrollmentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _enrollmentDate = date;
                    });
                  }
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
                decoration: const InputDecoration(
                  labelText: 'GPA',
                  border: OutlineInputBorder(),
                  hintText: '0.0 - 4.0',
                ),
                keyboardType: TextInputType.number,
                initialValue: _gpa?.toString(),
                onChanged: (value) {
                  _gpa = double.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Crédits obtenus',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _totalCreditsEarned.toString(),
                onChanged: (value) {
                  _totalCreditsEarned = int.tryParse(value) ?? 0;
                },
              ),
            ),
          ],
        ),
        
        if (_isAdvancedMode) ...[
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Crédits requis',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _totalCreditsRequired?.toString(),
                  onChanged: (value) {
                    _totalCreditsRequired = int.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Classement',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _classRank?.toString(),
                  onChanged: (value) {
                    _classRank = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_selectedLevel == AcademicLevel.doctorat3 || 
              _selectedLevel == AcademicLevel.master2 ||
              _selectedLevel == AcademicLevel.licence3) ...[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Titre du mémoire/thèse',
                border: OutlineInputBorder(),
              ),
              initialValue: _graduationThesisTitle,
              onChanged: (value) {
                _graduationThesisTitle = value.trim().isEmpty ? null : value.trim();
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Superviseur',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _thesisSupervisor,
                    onChanged: (value) {
                      _thesisSupervisor = value.trim().isEmpty ? null : value.trim();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: const Text('Date de soutenance'),
                    subtitle: Text(_thesisDefenseDate != null 
                        ? '${_thesisDefenseDate!.day}/${_thesisDefenseDate!.month}/${_thesisDefenseDate!.year}'
                        : 'Non sélectionnée'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _thesisDefenseDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _thesisDefenseDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Adresse',
            border: OutlineInputBorder(),
          ),
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
    );
  }

  Widget _buildEmergencyContactSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emergencyContactNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du contact d\'urgence',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_emergency),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _emergencyContactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone du contact',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emergencyContactRelationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relation avec l\'étudiant',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _emergencyContactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email du contact',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScholarshipSection() {
    return Column(
      children: [
        DropdownButtonFormField<ScholarshipStatus>(
          value: _selectedScholarshipStatus,
          decoration: const InputDecoration(
            labelText: 'Statut de bourse',
            border: OutlineInputBorder(),
          ),
          items: ScholarshipStatus.values.map((status) {
            return DropdownMenuItem<ScholarshipStatus>(
              value: status,
              child: Text(status.label),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedScholarshipStatus = value!;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: TextEditingController(text: _scholarshipDetails),
          decoration: const InputDecoration(
            labelText: 'Détails de la bourse',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _scholarshipDetails = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Montant de la bourse',
            border: OutlineInputBorder(),
            prefixText: 'FCFA ',
          ),
          keyboardType: TextInputType.number,
          initialValue: _scholarshipAmount?.toString(),
          onChanged: (value) {
            _scholarshipAmount = double.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildMedicalSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Groupe sanguin',
                  border: OutlineInputBorder(),
                ),
                initialValue: _bloodGroup,
                onChanged: (value) {
                  _bloodGroup = value.trim().isEmpty ? null : value.trim();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Besoin d\'aménagement spécial'),
                value: _needsSpecialAccommodation,
                onChanged: (value) {
                  setState(() {
                    _needsSpecialAccommodation = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Conditions médicales',
            border: OutlineInputBorder(),
          ),
          initialValue: _medicalConditions,
          onChanged: (value) {
            _medicalConditions = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Allergies',
            border: OutlineInputBorder(),
          ),
          initialValue: _allergies,
          onChanged: (value) {
            _allergies = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Restrictions alimentaires',
            border: OutlineInputBorder(),
          ),
          initialValue: _dietaryRestrictions,
          onChanged: (value) {
            _dietaryRestrictions = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Handicaps physiques',
            border: OutlineInputBorder(),
          ),
          initialValue: _physicalDisabilities,
          onChanged: (value) {
            _physicalDisabilities = value.trim().isEmpty ? null : value.trim();
          },
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      children: [
        TextFormField(
          controller: TextEditingController(text: _languages),
          decoration: const InputDecoration(
            labelText: 'Langues parlées',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _languages = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: TextEditingController(text: _hobbies),
          decoration: const InputDecoration(
            labelText: 'Centres d\'intérêt',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _hobbies = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: TextEditingController(text: _skills),
          decoration: const InputDecoration(
            labelText: 'Compétences',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _skills = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: TextEditingController(text: _previousEducation),
          decoration: const InputDecoration(
            labelText: 'Éducation précédente',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _previousEducation = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: TextEditingController(text: _workExperience),
          decoration: const InputDecoration(
            labelText: 'Expérience professionnelle',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _workExperience = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: TextEditingController(text: _references),
          decoration: const InputDecoration(
            labelText: 'Références',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _references = value.trim().isEmpty ? null : value.trim();
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Biographie',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
