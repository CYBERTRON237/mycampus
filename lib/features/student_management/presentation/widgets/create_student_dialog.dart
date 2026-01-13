import 'package:flutter/material.dart';

class CreateStudentDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onStudentCreated;

  const CreateStudentDialog({
    Key? key,
    required this.onStudentCreated,
  }) : super(key: key);

  @override
  State<CreateStudentDialog> createState() => _CreateStudentDialogState();
}

class _CreateStudentDialogState extends State<CreateStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  DateTime? _dateOfBirth;
  String? _selectedInstitution;
  String? _selectedProgram;
  String? _selectedLevel;
  String? _selectedAdmissionType;
  String? _selectedScholarshipStatus;
  DateTime? _enrollmentDate = DateTime.now();

  bool _isLoading = false;

  final List<String> _genders = ['Homme', 'Femme'];
  final List<String> _levels = [
    'licence1',
    'licence2', 
    'licence3',
    'master1',
    'master2',
    'doctorat1',
    'doctorat2',
    'doctorat3',
  ];
  final List<String> _admissionTypes = ['regular', 'transfer', 'exchange', 'special'];
  final List<String> _scholarshipStatuses = ['none', 'partial', 'full', 'government', 'merit'];

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
    'government': 'Gouvernement',
    'merit': 'Mérite',
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nouvel étudiant',
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
            const Divider(),
            const SizedBox(height: 16),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 24),
                      _buildAcademicInfoSection(),
                      const SizedBox(height: 24),
                      _buildAdditionalInfoSection(),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations personnelles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
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
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
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
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
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
              child: InkWell(
                onTap: _selectDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Sélectionner une date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (value.length < 6) {
                    return 'Minimum 6 caractères';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations académiques',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedInstitution,
          decoration: const InputDecoration(
            labelText: 'Institution *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
          items: [
            'Université de Yaoundé I',
            'Université de Douala',
            'Université de Dschang',
            'Université de Buéa',
            'Université de Maroua',
          ].map((institution) {
            return DropdownMenuItem<String>(
              value: institution,
              child: Text(institution),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedInstitution = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedProgram,
          decoration: const InputDecoration(
            labelText: 'Programme *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.book),
          ),
          items: [
            'Licence Mathématiques',
            'Licence Physique',
            'Licence Chimie',
            'Licence Informatique',
            'Master Informatique',
            'Doctorat Physique',
          ].map((program) {
            return DropdownMenuItem<String>(
              value: program,
              child: Text(program),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProgram = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Niveau *',
                  border: OutlineInputBorder(),
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
                validator: (value) {
                  if (value == null) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedAdmissionType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'admission',
                  border: OutlineInputBorder(),
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _selectEnrollmentDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date d\'inscription *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _enrollmentDate != null
                  ? '${_enrollmentDate!.day}/${_enrollmentDate!.month}/${_enrollmentDate!.year}'
                  : 'Sélectionner une date',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations additionnelles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedScholarshipStatus,
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
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 70)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _selectEnrollmentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _enrollmentDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final studentData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'date_of_birth': _dateOfBirth?.toIso8601String(),
        'gender': _selectedGender?.toLowerCase(),
        'address': _addressController.text.trim(),
        'password': _passwordController.text,
        'institution_id': 1, // TODO: Récupérer l'ID réel de l'institution
        'program_id': 1, // TODO: Récupérer l'ID réel du programme
        'academic_year_id': 1, // TODO: Récupérer l'ID réel de l'année académique
        'level': _selectedLevel,
        'admission_type': _selectedAdmissionType ?? 'regular',
        'scholarship_status': _selectedScholarshipStatus ?? 'none',
        'enrollment_date': _enrollmentDate?.toIso8601String(),
      };

      await widget.onStudentCreated(studentData);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
