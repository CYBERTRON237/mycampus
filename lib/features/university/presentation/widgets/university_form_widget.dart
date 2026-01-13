import 'package:flutter/material.dart';
import '../../domain/models/university_model.dart';

class UniversityFormWidget extends StatefulWidget {
  final UniversityModel? university;
  final Function(UniversityModel) onSubmit;
  final bool isLoading;

  const UniversityFormWidget({
    super.key,
    this.university,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<UniversityFormWidget> createState() => _UniversityFormWidgetState();
}

class _UniversityFormWidgetState extends State<UniversityFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailOfficialController = TextEditingController();
  final _phonePrimaryController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryController = TextEditingController();
  final _studentCountController = TextEditingController();
  final _facultyCountController = TextEditingController();

  UniversityType _selectedType = UniversityType.public;
  UniversityStatus _selectedStatus = UniversityStatus.active;
  DateTime? _foundedAt;

  @override
  void initState() {
    super.initState();
    if (widget.university != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final university = widget.university!;
    _nameController.text = university.name;
    _shortNameController.text = university.shortName;
    _descriptionController.text = university.description ?? '';
    _websiteController.text = university.website ?? '';
    _emailOfficialController.text = university.emailOfficial ?? '';
    _phonePrimaryController.text = university.phonePrimary ?? '';
    _addressController.text = university.address ?? '';
    _cityController.text = university.city;
    _regionController.text = university.region;
    _countryController.text = university.country;
    _studentCountController.text = university.totalStudents.toString();
    _facultyCountController.text = university.totalStaff.toString();
    _selectedType = university.type;
    _selectedStatus = university.status;
    _foundedAt = university.foundedYear != null ? DateTime(university.foundedYear!) : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailOfficialController.dispose();
    _phonePrimaryController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    _studentCountController.dispose();
    _facultyCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _foundedAt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _foundedAt) {
      setState(() {
        _foundedAt = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _foundedAt != null) {
      final university = UniversityModel(
        id: widget.university?.id ?? '',
        uuid: widget.university?.uuid ?? '',
        code: widget.university?.code ?? _shortNameController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        country: _countryController.text.trim().isEmpty 
            ? 'Cameroun' 
            : _countryController.text.trim(),
        region: _regionController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        postalCode: null,
        phonePrimary: _phonePrimaryController.text.trim().isEmpty 
            ? null 
            : _phonePrimaryController.text.trim(),
        phoneSecondary: null,
        emailOfficial: _emailOfficialController.text.trim().isEmpty 
            ? null 
            : _emailOfficialController.text.trim(),
        emailAdmin: null,
        website: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        logoUrl: widget.university?.logoUrl,
        bannerUrl: widget.university?.bannerUrl,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        foundedYear: _foundedAt?.year,
        rectorName: widget.university?.rectorName,
        totalStudents: _studentCountController.text.trim().isEmpty 
            ? 0 
            : int.tryParse(_studentCountController.text.trim()) ?? 0,
        totalStaff: _facultyCountController.text.trim().isEmpty 
            ? 0 
            : int.tryParse(_facultyCountController.text.trim()) ?? 0,
        isNationalHub: widget.university?.isNationalHub ?? false,
        isActive: widget.university?.isActive ?? true,
        syncEnabled: widget.university?.syncEnabled ?? true,
        lastSyncAt: widget.university?.lastSyncAt,
        metadata: widget.university?.metadata,
        createdAt: widget.university?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(university);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations de base
            _buildSectionTitle('Informations de base'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'université *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shortNameController,
              decoration: const InputDecoration(
                labelText: 'Nom court *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ce champ est obligatoire';
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<UniversityType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: UniversityType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeLabel(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<UniversityStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut *',
                      border: OutlineInputBorder(),
                    ),
                    items: UniversityStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _foundedAt != null
                    ? 'Date de fondation: ${_foundedAt!.day}/${_foundedAt!.month}/${_foundedAt!.year}'
                    : 'Sélectionner la date de fondation *',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            if (_foundedAt == null)
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  'Ce champ est obligatoire',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 24),

            // Contact
            _buildSectionTitle('Contact'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Site web',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailOfficialController,
              decoration: const InputDecoration(
                labelText: 'Email officiel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phonePrimaryController,
              decoration: const InputDecoration(
                labelText: 'Téléphone principal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Localisation
            _buildSectionTitle('Localisation'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
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
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Pays',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),

            const SizedBox(height: 24),

            // Statistiques
            _buildSectionTitle('Statistiques'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _studentCountController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre d\'étudiants',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _facultyCountController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de facultés',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.university == null ? 'Créer' : 'Mettre à jour',
                      style: const TextStyle(fontSize: 16),
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
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[600],
      ),
    );
  }

  String _getTypeLabel(UniversityType type) {
    switch (type) {
      case UniversityType.public:
        return 'Publique';
      case UniversityType.private:
        return 'Privée';
      case UniversityType.confessional:
        return 'Confessionnelle';
    }
  }

  String _getStatusLabel(UniversityStatus status) {
    switch (status) {
      case UniversityStatus.active:
        return 'Active';
      case UniversityStatus.inactive:
        return 'Inactive';
      case UniversityStatus.suspended:
        return 'Suspendu';
      case UniversityStatus.pending:
        return 'En attente';
    }
  }
}
