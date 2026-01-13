import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';
import 'package:mycampus/features/user_management/data/models/institution_department_model.dart';
import 'package:mycampus/features/faculty/domain/models/faculty_model.dart';

class EnhancedStudentFiltersWidget extends StatefulWidget {
  final StudentFilters currentFilters;
  final Function(StudentFilters) onFiltersChanged;

  const EnhancedStudentFiltersWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<EnhancedStudentFiltersWidget> createState() => _EnhancedStudentFiltersWidgetState();
}

class _EnhancedStudentFiltersWidgetState extends State<EnhancedStudentFiltersWidget> {
  late TextEditingController _searchController;
  late StudentStatus? _selectedStatus;
  late AcademicLevel? _selectedLevel;
  late AdmissionType? _selectedAdmissionType;
  late ScholarshipStatus? _selectedScholarshipStatus;
  late String? _selectedGender;
  late int? _selectedInstitutionId;
  late int? _selectedFacultyId;
  late int? _selectedDepartmentId;
  late int? _selectedProgramId;
  late String? _selectedRegion;
  late String? _selectedCity;
  late bool? _isActive;
  late bool? _isVerified;
  late bool? _hasScholarship;
  late bool? _needsSpecialAccommodation;
  late double? _gpaMin;
  late double? _gpaMax;
  late DateTime? _dateOfBirthFrom;
  late DateTime? _dateOfBirthTo;
  late DateTime? _enrollmentDateFrom;
  late DateTime? _enrollmentDateTo;

  // Mock data for institutions, faculties, etc.
  final List<InstitutionModel> _institutions = [
    InstitutionModel(
      id: 1,
      uuid: 'uuid-1',
      name: 'Université de Yaoundé I',
      shortName: 'UY1',
      type: 'public',
      status: 'active',
      region: 'Centre',
      city: 'Yaoundé',
      address: 'BP 337 Yaoundé',
      phone: '+237 222 22 34 56',
      email: 'info@uy1.cm',
      website: 'www.uy1.cm',
      description: 'Première université du Cameroun',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    InstitutionModel(
      id: 2,
      uuid: 'uuid-2',
      name: 'Université de Douala',
      shortName: 'UD',
      type: 'public',
      status: 'active',
      region: 'Littoral',
      city: 'Douala',
      address: 'BP 2701 Douala',
      phone: '+237 233 42 32 12',
      email: 'info@ud.cm',
      website: 'www.ud.cm',
      description: 'Université de la région littorale',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    InstitutionModel(
      id: 3,
      uuid: 'uuid-3',
      name: 'Université de Dschang',
      shortName: 'UDS',
      type: 'public',
      status: 'active',
      region: 'Ouest',
      city: 'Dschang',
      address: 'BP 96 Dschang',
      phone: '+237 233 45 12 34',
      email: 'info@uds.cm',
      website: 'www.uds.cm',
      description: 'Université de la région Ouest',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<FacultyModel> _faculties = [
    FacultyModel(
      id: '1',
      institutionId: '1',
      code: 'FS',
      name: 'Faculté des Sciences',
      shortName: 'FS',
      status: FacultyStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FacultyModel(
      id: '2',
      institutionId: '1',
      code: 'FALSH',
      name: 'Faculté des Lettres et Sciences Humaines',
      shortName: 'FALSH',
      status: FacultyStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FacultyModel(
      id: '3',
      institutionId: '1',
      code: 'FM',
      name: 'Faculté de Médecine',
      shortName: 'FM',
      status: FacultyStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<DepartmentModel> _departments = [
    DepartmentModel(
      id: 1,
      uuid: 'dept-uuid-1',
      name: 'Informatique',
      shortName: 'Info',
      code: 'INF',
      description: 'Département d\'informatique',
      headOfDepartment: 'Dr. Martin',
      hodEmail: 'martin@uy1.cm',
      hodPhone: '+237 123 456 789',
      level: 'LMD',
      status: 'active',
      isActive: true,
      facultyId: 1,
      facultyName: 'Faculté des Sciences',
      institutionId: 1,
      institutionName: 'Université de Yaoundé I',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DepartmentModel(
      id: 2,
      uuid: 'dept-uuid-2',
      name: 'Mathématiques',
      shortName: 'Math',
      code: 'MAT',
      description: 'Département de mathématiques',
      headOfDepartment: 'Dr. Tchamba',
      hodEmail: 'tchamba@uy1.cm',
      hodPhone: '+237 123 456 790',
      level: 'LMD',
      status: 'active',
      isActive: true,
      facultyId: 1,
      facultyName: 'Faculté des Sciences',
      institutionId: 1,
      institutionName: 'Université de Yaoundé I',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DepartmentModel(
      id: 3,
      uuid: 'dept-uuid-3',
      name: 'Physique',
      shortName: 'Phys',
      code: 'PHY',
      description: 'Département de physique',
      headOfDepartment: 'Dr. Ngono',
      hodEmail: 'ngono@uy1.cm',
      hodPhone: '+237 123 456 791',
      level: 'LMD',
      status: 'active',
      isActive: true,
      facultyId: 1,
      facultyName: 'Faculté des Sciences',
      institutionId: 1,
      institutionName: 'Université de Yaoundé I',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<String> _regions = [
    'Centre', 'Littoral', 'Ouest', 'Nord', 'Adamaoua', 'Est', 'Sud', 'Nord-Ouest', 'Sud-Ouest', 'Extrême-Nord'
  ];

  final List<String> _cities = [
    'Yaoundé', 'Douala', 'Bafoussam', 'Garoua', 'Maroua', 'Bamenda', 'Buea', 'Kumba', 'Ngaoundéré', 'Bertoua'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    _searchController = TextEditingController(text: widget.currentFilters.search);
    _selectedStatus = widget.currentFilters.status;
    _selectedLevel = widget.currentFilters.level;
    _selectedAdmissionType = widget.currentFilters.admissionType;
    _selectedScholarshipStatus = widget.currentFilters.scholarshipStatus;
    _selectedGender = widget.currentFilters.gender;
    _selectedInstitutionId = widget.currentFilters.institutionId;
    _selectedFacultyId = widget.currentFilters.facultyId;
    _selectedDepartmentId = widget.currentFilters.departmentId;
    _selectedProgramId = widget.currentFilters.programId;
    _selectedRegion = widget.currentFilters.region;
    _selectedCity = widget.currentFilters.city;
    _isActive = widget.currentFilters.isActive;
    _isVerified = widget.currentFilters.isVerified;
    _hasScholarship = widget.currentFilters.hasScholarship;
    _needsSpecialAccommodation = widget.currentFilters.needsSpecialAccommodation;
    _gpaMin = widget.currentFilters.gpaMin;
    _gpaMax = widget.currentFilters.gpaMax;
    _dateOfBirthFrom = widget.currentFilters.dateOfBirthFrom;
    _dateOfBirthTo = widget.currentFilters.dateOfBirthTo;
    _enrollmentDateFrom = widget.currentFilters.enrollmentDateFrom;
    _enrollmentDateTo = widget.currentFilters.enrollmentDateTo;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = StudentFilters(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      status: _selectedStatus,
      level: _selectedLevel,
      admissionType: _selectedAdmissionType,
      scholarshipStatus: _selectedScholarshipStatus,
      gender: _selectedGender,
      institutionId: _selectedInstitutionId,
      facultyId: _selectedFacultyId,
      departmentId: _selectedDepartmentId,
      programId: _selectedProgramId,
      region: _selectedRegion,
      city: _selectedCity,
      isActive: _isActive,
      isVerified: _isVerified,
      hasScholarship: _hasScholarship,
      needsSpecialAccommodation: _needsSpecialAccommodation,
      gpaMin: _gpaMin,
      gpaMax: _gpaMax,
      dateOfBirthFrom: _dateOfBirthFrom,
      dateOfBirthTo: _dateOfBirthTo,
      enrollmentDateFrom: _enrollmentDateFrom,
      enrollmentDateTo: _enrollmentDateTo,
    );

    widget.onFiltersChanged(filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedLevel = null;
      _selectedAdmissionType = null;
      _selectedScholarshipStatus = null;
      _selectedGender = null;
      _selectedInstitutionId = null;
      _selectedFacultyId = null;
      _selectedDepartmentId = null;
      _selectedProgramId = null;
      _selectedRegion = null;
      _selectedCity = null;
      _isActive = null;
      _isVerified = null;
      _hasScholarship = null;
      _needsSpecialAccommodation = null;
      _gpaMin = null;
      _gpaMax = null;
      _dateOfBirthFrom = null;
      _dateOfBirthTo = null;
      _enrollmentDateFrom = null;
      _enrollmentDateTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Filtres avancés',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Effacer tout'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Recherche',
                hintText: 'Nom, matricule, email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filters in expansion panels
            ExpansionTile(
              title: const Text('Informations académiques'),
              initiallyExpanded: true,
              children: [
                _buildAcademicFilters(),
              ],
            ),
            
            ExpansionTile(
              title: const Text('Informations personnelles'),
              children: [
                _buildPersonalFilters(),
              ],
            ),
            
            ExpansionTile(
              title: const Text('Dates et performances'),
              children: [
                _buildDateAndPerformanceFilters(),
              ],
            ),
            
            ExpansionTile(
              title: const Text('Statuts et permissions'),
              children: [
                _buildStatusFilters(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_list),
                label: const Text('Appliquer les filtres'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Institution dropdown
          DropdownButtonFormField<int>(
            value: _selectedInstitutionId,
            decoration: const InputDecoration(
              labelText: 'Institution',
              border: OutlineInputBorder(),
            ),
            items: _institutions.map((institution) {
              return DropdownMenuItem<int>(
                value: institution.id,
                child: Text(institution.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedInstitutionId = value;
                _selectedFacultyId = null; // Reset faculty when institution changes
                _selectedDepartmentId = null; // Reset department
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Faculty dropdown
          DropdownButtonFormField<int>(
            value: _selectedFacultyId,
            decoration: const InputDecoration(
              labelText: 'Faculté',
              border: OutlineInputBorder(),
            ),
            items: _selectedInstitutionId != null
                ? _faculties
                    .where((f) => int.tryParse(f.institutionId) == _selectedInstitutionId)
                    .map((faculty) {
              return DropdownMenuItem<int>(
                value: int.tryParse(faculty.id) ?? 0,
                child: Text(faculty.name),
              );
            }).toList()
                : [],
            onChanged: (value) {
              setState(() {
                _selectedFacultyId = value;
                _selectedDepartmentId = null; // Reset department when faculty changes
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Department dropdown
          DropdownButtonFormField<int>(
            value: _selectedDepartmentId,
            decoration: const InputDecoration(
              labelText: 'Département',
              border: OutlineInputBorder(),
            ),
            items: _selectedFacultyId != null
                ? _departments
                    .where((d) {
                      final facultyId = int.tryParse(d.facultyId.toString());
                      return facultyId != null && facultyId == _selectedFacultyId;
                    })
                    .map((department) {
              return DropdownMenuItem<int>(
                value: int.tryParse(department.id.toString()) ?? 0,
                child: Text(department.name),
              );
            }).toList()
                : [],
            onChanged: (value) {
              setState(() {
                _selectedDepartmentId = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Academic level
          DropdownButtonFormField<AcademicLevel>(
            value: _selectedLevel,
            decoration: const InputDecoration(
              labelText: 'Niveau académique',
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
                _selectedLevel = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Admission type
          DropdownButtonFormField<AdmissionType>(
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
                _selectedAdmissionType = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Gender dropdown
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Genre',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<String>(value: 'male', child: Text('Masculin')),
              DropdownMenuItem<String>(value: 'female', child: Text('Féminin')),
              DropdownMenuItem<String>(value: 'other', child: Text('Autre')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Region dropdown
          DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              labelText: 'Région',
              border: OutlineInputBorder(),
            ),
            items: _regions.map((region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRegion = value;
                _selectedCity = null; // Reset city when region changes
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // City dropdown
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              labelText: 'Ville',
              border: OutlineInputBorder(),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Scholarship status
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
                _selectedScholarshipStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndPerformanceFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Date of birth range
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Date de naissance (début)'),
                  subtitle: Text(_dateOfBirthFrom != null 
                      ? '${_dateOfBirthFrom!.day}/${_dateOfBirthFrom!.month}/${_dateOfBirthFrom!.year}'
                      : 'Non sélectionnée'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirthFrom ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateOfBirthFrom = date;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  title: const Text('Date de naissance (fin)'),
                  subtitle: Text(_dateOfBirthTo != null 
                      ? '${_dateOfBirthTo!.day}/${_dateOfBirthTo!.month}/${_dateOfBirthTo!.year}'
                      : 'Non sélectionnée'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirthTo ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateOfBirthTo = date;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Enrollment date range
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Date d\'inscription (début)'),
                  subtitle: Text(_enrollmentDateFrom != null 
                      ? '${_enrollmentDateFrom!.day}/${_enrollmentDateFrom!.month}/${_enrollmentDateFrom!.year}'
                      : 'Non sélectionnée'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _enrollmentDateFrom ?? DateTime.now().subtract(const Duration(days: 365)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _enrollmentDateFrom = date;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  title: const Text('Date d\'inscription (fin)'),
                  subtitle: Text(_enrollmentDateTo != null 
                      ? '${_enrollmentDateTo!.day}/${_enrollmentDateTo!.month}/${_enrollmentDateTo!.year}'
                      : 'Non sélectionnée'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _enrollmentDateTo ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _enrollmentDateTo = date;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // GPA range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'GPA minimum',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _gpaMin?.toString(),
                  onChanged: (value) {
                    setState(() {
                      _gpaMin = double.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'GPA maximum',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _gpaMax?.toString(),
                  onChanged: (value) {
                    setState(() {
                      _gpaMax = double.tryParse(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Student status
          DropdownButtonFormField<StudentStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Statut de l\'étudiant',
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
                _selectedStatus = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Active status
          DropdownButtonFormField<bool>(
            value: _isActive,
            decoration: const InputDecoration(
              labelText: 'Statut actif',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool>(value: true, child: Text('Actif')),
              DropdownMenuItem<bool>(value: false, child: Text('Inactif')),
            ],
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Verified status
          DropdownButtonFormField<bool>(
            value: _isVerified,
            decoration: const InputDecoration(
              labelText: 'Statut vérifié',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool>(value: true, child: Text('Vérifié')),
              DropdownMenuItem<bool>(value: false, child: Text('Non vérifié')),
            ],
            onChanged: (value) {
              setState(() {
                _isVerified = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Has scholarship
          DropdownButtonFormField<bool>(
            value: _hasScholarship,
            decoration: const InputDecoration(
              labelText: 'Bourse d\'études',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool>(value: true, child: Text('Avec bourse')),
              DropdownMenuItem<bool>(value: false, child: Text('Sans bourse')),
            ],
            onChanged: (value) {
              setState(() {
                _hasScholarship = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Needs special accommodation
          DropdownButtonFormField<bool>(
            value: _needsSpecialAccommodation,
            decoration: const InputDecoration(
              labelText: 'Besoin d\'aménagement spécial',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool>(value: true, child: Text('Oui')),
              DropdownMenuItem<bool>(value: false, child: Text('Non')),
            ],
            onChanged: (value) {
              setState(() {
                _needsSpecialAccommodation = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
