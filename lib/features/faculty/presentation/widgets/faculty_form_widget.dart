import 'package:flutter/material.dart';
import '../../domain/models/faculty_model.dart';
import '../../../university/domain/repositories/university_repository.dart';
import '../../../university/data/repositories/university_repository_impl.dart';
import '../../../university/data/datasources/university_remote_datasource.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';

class FacultyFormWidget extends StatefulWidget {
  final FacultyModel? faculty;
  final Function(FacultyModel) onSubmit;

  const FacultyFormWidget({
    super.key,
    this.faculty,
    required this.onSubmit,
  });

  @override
  State<FacultyFormWidget> createState() => _FacultyFormWidgetState();
}

class _FacultyFormWidgetState extends State<FacultyFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deanNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _officeLocationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoUrlController = TextEditingController();

  String? _selectedInstitutionId;
  FacultyStatus _selectedStatus = FacultyStatus.active;
  bool _isLoading = false;
  List<Map<String, dynamic>> _institutions = [];

  late UniversityRepository _universityRepository;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadInstitutions();
    
    if (widget.faculty != null) {
      _populateForm();
    }
  }

  void _initializeRepository() {
    _universityRepository = UniversityRepositoryImpl(
      remoteDataSource: UniversityRemoteDataSource(
        client: http.Client(),
        authService: AuthService(),
      ),
    );
  }

  Future<void> _loadInstitutions() async {
    try {
      final result = await _universityRepository.getUniversities();
      result.fold(
        (error) => debugPrint('Error loading institutions: $error'),
        (institutions) {
          setState(() {
            _institutions = institutions.map((inst) => {
              'id': inst.id,
              'name': inst.name,
              'short_name': inst.shortName,
            }).toList();
            
            if (widget.faculty != null) {
              _selectedInstitutionId = widget.faculty!.institutionId;
            }
          });
        },
      );
    } catch (e) {
      debugPrint('Exception loading institutions: $e');
    }
  }

  void _populateForm() {
    final faculty = widget.faculty!;
    _nameController.text = faculty.name;
    _shortNameController.text = faculty.shortName;
    _codeController.text = faculty.code;
    _descriptionController.text = faculty.description ?? '';
    _deanNameController.text = faculty.deanName ?? '';
    _contactEmailController.text = faculty.contactEmail ?? '';
    _contactPhoneController.text = faculty.contactPhone ?? '';
    _officeLocationController.text = faculty.officeLocation ?? '';
    _websiteController.text = faculty.website ?? '';
    _logoUrlController.text = faculty.logoUrl ?? '';
    _selectedInstitutionId = faculty.institutionId;
    _selectedStatus = faculty.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _deanNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _officeLocationController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedInstitutionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une institution')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final faculty = FacultyModel(
        id: widget.faculty?.id ?? '',
        institutionId: _selectedInstitutionId!,
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        deanName: _deanNameController.text.trim().isEmpty 
            ? null 
            : _deanNameController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty 
            ? null 
            : _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim().isEmpty 
            ? null 
            : _contactPhoneController.text.trim(),
        officeLocation: _officeLocationController.text.trim().isEmpty 
            ? null 
            : _officeLocationController.text.trim(),
        status: _selectedStatus,
        website: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isEmpty 
            ? null 
            : _logoUrlController.text.trim(),
        createdAt: widget.faculty?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(faculty);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.faculty == null 
                  ? 'Faculté créée avec succès' 
                  : 'Faculté mise à jour avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faculty == null ? 'Nouvelle faculté' : 'Modifier la faculté',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations de base
                      _buildSectionTitle('Informations de base'),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedInstitutionId,
                        decoration: const InputDecoration(
                          labelText: 'Institution *',
                          border: OutlineInputBorder(),
                        ),
                        items: _institutions.map((institution) {
                          return DropdownMenuItem<String>(
                            value: institution['id'],
                            child: Text(
                              '${institution['short_name']} - ${institution['name']}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedInstitutionId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une institution';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: 'Code *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le code est requis';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _shortNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom court *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le nom court est requis';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom complet est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      
                      // Contact
                      _buildSectionTitle('Contact'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _deanNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du doyen',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _contactEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email de contact',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _contactPhoneController,
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
                      
                      TextFormField(
                        controller: _officeLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Localisation du bureau',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Informations web
                      _buildSectionTitle('Informations web'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Site web',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.language),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _logoUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL du logo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 24),
                      
                      // Statut
                      _buildSectionTitle('Statut'),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<FacultyStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                        ),
                        items: FacultyStatus.values.map((status) {
                          return DropdownMenuItem<FacultyStatus>(
                            value: status,
                            child: Text(_getStatusDisplayName(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
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
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  String _getStatusDisplayName(FacultyStatus status) {
    switch (status) {
      case FacultyStatus.active:
        return 'Active';
      case FacultyStatus.inactive:
        return 'Inactive';
      case FacultyStatus.suspended:
        return 'Suspendue';
    }
  }
}
