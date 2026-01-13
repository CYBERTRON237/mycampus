import 'package:flutter/material.dart';
import '../../data/models/simple_student_model.dart';

class EditStudentDialog extends StatefulWidget {
  final SimpleStudentModel student;
  final Function(Map<String, dynamic>) onStudentUpdated;

  const EditStudentDialog({
    Key? key,
    required this.student,
    required this.onStudentUpdated,
  }) : super(key: key);

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _matriculeController;
  
  String? _selectedGender;
  String? _selectedLevel;
  String? _selectedStatus;

  final List<String> _genders = ['Homme', 'Femme'];
  final List<String> _levels = [
    'licence1', 'licence2', 'licence3',
    'master1', 'master2',
    'doctorat1', 'doctorat2', 'doctorat3'
  ];
  final List<String> _statuses = [
    'active', 'inactive', 'suspended', 'banned', 
    'pending_verification', 'graduated', 'withdrawn'
  ];

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

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student.firstName);
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phone ?? '');
    _matriculeController = TextEditingController(text: widget.student.matricule ?? '');
    _selectedGender = null; // gender property doesn't exist in SimpleStudentModel
    _selectedLevel = widget.student.currentLevel; // use currentLevel instead of level
    _selectedStatus = widget.student.studentStatus;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modifier le profil étudiant',
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
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informations personnelles'),
                    const SizedBox(height: 16),
                    _buildPersonalInfo(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Informations académiques'),
                    const SizedBox(height: 16),
                    _buildAcademicInfo(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Statut du compte'),
                    const SizedBox(height: 16),
                    _buildAccountStatus(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
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

  Widget _buildPersonalInfo() {
    return Card(
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
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
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
                const SizedBox(width: 16),
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
    );
  }

  Widget _buildAcademicInfo() {
    return Card(
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
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
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


  void _saveStudent() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty) {
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
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'matricule': _matriculeController.text.trim().isEmpty ? null : _matriculeController.text.trim(),
      'gender': _selectedGender,
      'level': _selectedLevel,
      'account_status': _selectedStatus,
    };

    widget.onStudentUpdated(studentData);
    Navigator.of(context).pop();
  }
}
