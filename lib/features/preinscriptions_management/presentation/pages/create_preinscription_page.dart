import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preinscription_provider.dart';
import '../../models/preinscription_model.dart';

class CreatePreinscriptionPage extends StatefulWidget {
  const CreatePreinscriptionPage({Key? key}) : super(key: key);

  @override
  State<CreatePreinscriptionPage> createState() => _CreatePreinscriptionPageState();
}

class _CreatePreinscriptionPageState extends State<CreatePreinscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _cniNumberController = TextEditingController();
  final _residenceAddressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _previousDiplomaController = TextEditingController();
  final _previousInstitutionController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _desiredProgramController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bacYearController = TextEditingController();
  final _bacCenterController = TextEditingController();
  final _gpaScoreController = TextEditingController();
  final _rankInClassController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentOccupationController = TextEditingController();
  final _parentAddressController = TextEditingController();
  final _paymentReferenceController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _scholarshipTypeController = TextEditingController();
  final _financialAidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _adminNotesController = TextEditingController();

  // Dropdown values
  String _selectedFaculty = 'UY1';
  String _selectedGender = 'MASCULIN';
  String _selectedMaritalStatus = 'CELIBATAIRE';
  String _selectedLanguage = 'FRANÇAIS';
  String _selectedProfessionalSituation = 'SANS EMPLOI';
  String _selectedStudyLevel = 'LICENCE';
  String _selectedBacMention = 'PASSABLE';
  String _selectedSeriesBac = 'C';
  String _selectedPaymentMethod = 'ORANGE_MONEY';
  String _selectedParentRelationship = 'PERE';
  String _selectedParentIncomeLevel = 'MOYEN';
  String _selectedContactPreference = 'EMAIL';

  // Checkbox values
  bool _isBirthDateOnCertificate = true;
  bool _scholarshipRequested = false;
  bool _marketingConsent = false;
  bool _dataProcessingConsent = false;
  bool _newsletterSubscription = false;

  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _dateOfBirthController.dispose();
    _placeOfBirthController.dispose();
    _cniNumberController.dispose();
    _residenceAddressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _previousDiplomaController.dispose();
    _previousInstitutionController.dispose();
    _graduationYearController.dispose();
    _desiredProgramController.dispose();
    _specializationController.dispose();
    _bacYearController.dispose();
    _bacCenterController.dispose();
    _gpaScoreController.dispose();
    _rankInClassController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _parentOccupationController.dispose();
    _parentAddressController.dispose();
    _paymentReferenceController.dispose();
    _paymentAmountController.dispose();
    _scholarshipTypeController.dispose();
    _financialAidAmountController.dispose();
    _notesController.dispose();
    _adminNotesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Préinscription'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveForm,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSection(
                'Informations Personnelles',
                Icons.person,
                _buildPersonalInfoFields(),
              ),
              const SizedBox(height: 24.0),

              // Academic Information Section
              _buildSection(
                'Informations Académiques',
                Icons.school,
                _buildAcademicInfoFields(),
              ),
              const SizedBox(height: 24.0),

              // Parent Information Section
              _buildSection(
                'Informations Parent/Tuteur',
                Icons.family_restroom,
                _buildParentInfoFields(),
              ),
              const SizedBox(height: 24.0),

              // Payment Information Section
              _buildSection(
                'Informations de Paiement',
                Icons.payment,
                _buildPaymentInfoFields(),
              ),
              const SizedBox(height: 24.0),

              // Additional Information Section
              _buildSection(
                'Informations Additionnelles',
                Icons.info,
                _buildAdditionalInfoFields(),
              ),
              const SizedBox(height: 32.0),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Créer la Préinscription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(_firstNameController, 'Prénom*', required: true)),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(_lastNameController, 'Nom*', required: true)),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_middleNameController, 'Autre prénom'),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildDateField(_dateOfBirthController, 'Date de naissance*', required: true),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Date sur certificat'),
                value: _isBirthDateOnCertificate,
                onChanged: (value) => setState(() => _isBirthDateOnCertificate = value ?? true),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_placeOfBirthController, 'Lieu de naissance*', required: true),
        const SizedBox(height: 16.0),
        _buildDropdownField(
          'Genre*',
          _selectedGender,
          PreinscriptionConstants.genders,
          (value) => setState(() => _selectedGender = value!),
          required: true,
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_cniNumberController, 'Numéro CNI/PI'),
        const SizedBox(height: 16.0),
        _buildTextField(_residenceAddressController, 'Adresse de résidence*', required: true, maxLines: 3),
        const SizedBox(height: 16.0),
        _buildDropdownField(
          'Situation maritale*',
          _selectedMaritalStatus,
          PreinscriptionConstants.maritalStatuses,
          (value) => setState(() => _selectedMaritalStatus = value!),
          required: true,
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(_phoneNumberController, 'Téléphone*', required: true)),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(_emailController, 'Email*', required: true, keyboardType: TextInputType.emailAddress)),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildDropdownField(
          'Première langue*',
          _selectedLanguage,
          PreinscriptionConstants.languages,
          (value) => setState(() => _selectedLanguage = value!),
          required: true,
        ),
        const SizedBox(height: 16.0),
        _buildDropdownField(
          'Situation professionnelle*',
          _selectedProfessionalSituation,
          PreinscriptionConstants.professionalSituations,
          (value) => setState(() => _selectedProfessionalSituation = value!),
          required: true,
        ),
      ],
    );
  }

  Widget _buildAcademicInfoFields() {
    return Column(
      children: [
        _buildDropdownField(
          'Faculté visée*',
          _selectedFaculty,
          ['UY1', 'FALSH', 'FS', 'FSE', 'IUT', 'ENSPY', 'Faculté des Sciences', 'Faculté des Lettres', 'Faculté de Médecine'],
          (value) => setState(() => _selectedFaculty = value!),
          required: true,
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_desiredProgramController, 'Programme souhaité'),
        const SizedBox(height: 16.0),
        _buildDropdownField(
          'Niveau d\'études visé',
          _selectedStudyLevel,
          PreinscriptionConstants.studyLevels,
          (value) => setState(() => _selectedStudyLevel = value!),
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_specializationController, 'Spécialisation souhaitée'),
        const SizedBox(height: 16.0),
        _buildTextField(_previousDiplomaController, 'Diplôme précédent'),
        const SizedBox(height: 16.0),
        _buildTextField(_previousInstitutionController, 'Établissement précédent'),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(_graduationYearController, 'Année d\'obtention', keyboardType: TextInputType.number)),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildDropdownField(
                'Série du BAC',
                _selectedSeriesBac,
                PreinscriptionConstants.seriesBac,
                (value) => setState(() => _selectedSeriesBac = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(_bacYearController, 'Année du BAC', keyboardType: TextInputType.number)),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(_bacCenterController, 'Centre d\'examen BAC')),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildDropdownField(
          'Mention au BAC',
          _selectedBacMention,
          PreinscriptionConstants.bacMentions,
          (value) => setState(() => _selectedBacMention = value!),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(_gpaScoreController, 'Score GPA', keyboardType: TextInputType.numberWithOptions(decimal: true))),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(_rankInClassController, 'Rang dans la classe', keyboardType: TextInputType.number)),
          ],
        ),
      ],
    );
  }

  Widget _buildParentInfoFields() {
    return Column(
      children: [
        _buildTextField(_parentNameController, 'Nom complet du parent/tuteur'),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(_parentPhoneController, 'Téléphone du parent')),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(_parentEmailController, 'Email du parent', keyboardType: TextInputType.emailAddress)),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_parentOccupationController, 'Profession du parent'),
        const SizedBox(height: 16.0),
        _buildTextField(_parentAddressController, 'Adresse du parent', maxLines: 2),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                'Lien avec le parent',
                _selectedParentRelationship,
                PreinscriptionConstants.parentRelationships,
                (value) => setState(() => _selectedParentRelationship = value!),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildDropdownField(
                'Niveau de revenu',
                _selectedParentIncomeLevel,
                PreinscriptionConstants.parentIncomeLevels,
                (value) => setState(() => _selectedParentIncomeLevel = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentInfoFields() {
    return Column(
      children: [
        _buildDropdownField(
          'Méthode de paiement',
          _selectedPaymentMethod,
          PreinscriptionConstants.paymentMethods,
          (value) => setState(() => _selectedPaymentMethod = value!),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(child: _buildTextField(_paymentReferenceController, 'Référence de paiement')),
            const SizedBox(width: 16.0),
            Expanded(child: _buildTextField(_paymentAmountController, 'Montant', keyboardType: TextInputType.numberWithOptions(decimal: true))),
          ],
        ),
        const SizedBox(height: 16.0),
        CheckboxListTile(
          title: const Text('Bourse demandée'),
          value: _scholarshipRequested,
          onChanged: (value) => setState(() => _scholarshipRequested = value ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        if (_scholarshipRequested) ...[
          const SizedBox(height: 16.0),
          _buildTextField(_scholarshipTypeController, 'Type de bourse'),
          const SizedBox(height: 16.0),
          _buildTextField(_financialAidAmountController, 'Montant aide financière', keyboardType: TextInputType.numberWithOptions(decimal: true)),
        ],
      ],
    );
  }

  Widget _buildAdditionalInfoFields() {
    return Column(
      children: [
        _buildDropdownField(
          'Préférence de contact',
          _selectedContactPreference,
          PreinscriptionConstants.contactPreferences,
          (value) => setState(() => _selectedContactPreference = value!),
        ),
        const SizedBox(height: 16.0),
        CheckboxListTile(
          title: const Text('Consentement marketing'),
          value: _marketingConsent,
          onChanged: (value) => setState(() => _marketingConsent = value ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('Consentement traitement des données'),
          value: _dataProcessingConsent,
          onChanged: (value) => setState(() => _dataProcessingConsent = value ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('Abonnement newsletter'),
          value: _newsletterSubscription,
          onChanged: (value) => setState(() => _newsletterSubscription = value ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        const SizedBox(height: 16.0),
        _buildTextField(_notesController, 'Notes générales', maxLines: 3),
        const SizedBox(height: 16.0),
        _buildTextField(_adminNotesController, 'Notes administrateur', maxLines: 3),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required
          ? (value) => value?.isEmpty == true ? 'Ce champ est obligatoire' : null
          : null,
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
        );
        if (date != null) {
          controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      },
      validator: required
          ? (value) => value?.isEmpty == true ? 'Ce champ est obligatoire' : null
          : null,
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: required
          ? (value) => value == null ? 'Ce champ est obligatoire' : null
          : null,
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final preinscription = PreinscriptionModel(
        faculty: _selectedFaculty,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        middleName: _middleNameController.text.isEmpty ? null : _middleNameController.text,
        dateOfBirth: DateTime.parse(_dateOfBirthController.text),
        isBirthDateOnCertificate: _isBirthDateOnCertificate,
        placeOfBirth: _placeOfBirthController.text,
        gender: _selectedGender,
        cniNumber: _cniNumberController.text.isEmpty ? null : _cniNumberController.text,
        residenceAddress: _residenceAddressController.text,
        maritalStatus: _selectedMaritalStatus,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        firstLanguage: _selectedLanguage,
        professionalSituation: _selectedProfessionalSituation,
        previousDiploma: _previousDiplomaController.text.isEmpty ? null : _previousDiplomaController.text,
        previousInstitution: _previousInstitutionController.text.isEmpty ? null : _previousInstitutionController.text,
        graduationYear: _graduationYearController.text.isEmpty ? null : int.tryParse(_graduationYearController.text),
        desiredProgram: _desiredProgramController.text.isEmpty ? null : _desiredProgramController.text,
        studyLevel: _selectedStudyLevel.isEmpty ? null : _selectedStudyLevel,
        specialization: _specializationController.text.isEmpty ? null : _specializationController.text,
        seriesBac: _selectedSeriesBac.isEmpty ? null : _selectedSeriesBac,
        bacYear: _bacYearController.text.isEmpty ? null : int.tryParse(_bacYearController.text),
        bacCenter: _bacCenterController.text.isEmpty ? null : _bacCenterController.text,
        bacMention: _selectedBacMention.isEmpty ? null : _selectedBacMention,
        gpaScore: _gpaScoreController.text.isEmpty ? null : double.tryParse(_gpaScoreController.text),
        rankInClass: _rankInClassController.text.isEmpty ? null : int.tryParse(_rankInClassController.text),
        parentName: _parentNameController.text.isEmpty ? null : _parentNameController.text,
        parentPhone: _parentPhoneController.text.isEmpty ? null : _parentPhoneController.text,
        parentEmail: _parentEmailController.text.isEmpty ? null : _parentEmailController.text,
        parentOccupation: _parentOccupationController.text.isEmpty ? null : _parentOccupationController.text,
        parentAddress: _parentAddressController.text.isEmpty ? null : _parentAddressController.text,
        parentRelationship: _selectedParentRelationship.isEmpty ? null : _selectedParentRelationship,
        parentIncomeLevel: _selectedParentIncomeLevel.isEmpty ? null : _selectedParentIncomeLevel,
        paymentMethod: _selectedPaymentMethod.isEmpty ? null : _selectedPaymentMethod,
        paymentReference: _paymentReferenceController.text.isEmpty ? null : _paymentReferenceController.text,
        paymentAmount: _paymentAmountController.text.isEmpty ? null : double.tryParse(_paymentAmountController.text),
        scholarshipRequested: _scholarshipRequested,
        scholarshipType: _scholarshipTypeController.text.isEmpty ? null : _scholarshipTypeController.text,
        financialAidAmount: _financialAidAmountController.text.isEmpty ? null : double.tryParse(_financialAidAmountController.text),
        contactPreference: _selectedContactPreference.isEmpty ? null : _selectedContactPreference,
        marketingConsent: _marketingConsent,
        dataProcessingConsent: _dataProcessingConsent,
        newsletterSubscription: _newsletterSubscription,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        adminNotes: _adminNotesController.text.isEmpty ? null : _adminNotesController.text,
        submissionDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await context.read<PreinscriptionProvider>().createPreinscription(preinscription);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préinscription créée avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
