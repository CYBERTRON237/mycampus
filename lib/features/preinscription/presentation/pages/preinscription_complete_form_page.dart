import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycampus/core/constants/colors.dart';
import '../../models/complete_preinscription_model.dart';
import '../../services/preinscription_service.dart';
import '../../models/filiere_model.dart';

class CompletePreinscriptionFormPage extends StatefulWidget {
  final String faculty;
  final String? facultyId;
  final FiliereModel? selectedFiliere;

  const CompletePreinscriptionFormPage({
    Key? key,
    required this.faculty,
    this.facultyId,
    this.selectedFiliere,
  }) : super(key: key);

  @override
  _CompletePreinscriptionFormPageState createState() => _CompletePreinscriptionFormPageState();
}

class _CompletePreinscriptionFormPageState extends State<CompletePreinscriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _preinscriptionService = PreinscriptionService();
  final _scrollController = ScrollController();
  
  String? _uniqueCode;
  bool _isLoading = false;
  int _currentStep = 0;
  PageController _pageController = PageController();

  // Form controllers - Informations personnelles
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _cniNumberController = TextEditingController();
  final _residenceAddressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  // Form controllers - Informations académiques
  final _previousDiplomaController = TextEditingController();
  final _previousInstitutionController = TextEditingController();
  final _desiredProgramController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bacCenterController = TextEditingController();
  final _gpaScoreController = TextEditingController();
  final _rankInClassController = TextEditingController();
  final _graduationMonthController = TextEditingController();

  // Form controllers - Parents
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentOccupationController = TextEditingController();
  final _parentAddressController = TextEditingController();

  // Form controllers - Paiement
  final _paymentReferenceController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _scholarshipTypeController = TextEditingController();
  final _financialAidAmountController = TextEditingController();

  // Form controllers - Notes
  final _notesController = TextEditingController();
  final _specialNeedsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  // Variables de sélection
  DateTime? _dateOfBirth;
  bool _isBirthDateOnCertificate = true;
  String _gender = '';
  String _maritalStatus = '';
  String _firstLanguage = '';
  String _professionalSituation = '';
  int? _graduationYear;
  String _studyLevel = '';
  String _seriesBac = '';
  int? _bacYear;
  String _bacMention = '';
  String _parentRelationship = '';
  String _parentIncomeLevel = '';
  String _paymentMethod = '';
  String _contactPreference = '';
  bool _scholarshipRequested = false;
  bool _marketingConsent = false;
  bool _dataProcessingConsent = false;
  bool _newsletterSubscription = false;

  final List<String> _steps = [
    'Informations\npersonnelles',
    'Parcours\nacadémique',
    'Parents/\nTuteurs',
    'Documents &\nPaiement',
    'Finalisation',
  ];

  @override
  void initState() {
    super.initState();
    _generateUniqueCode();
    _initializeForm();
  }

  void _generateUniqueCode() {
    setState(() {
      _uniqueCode = 'PRE${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';
    });
  }

  void _initializeForm() {
    setState(() {});
  }

  @override
  void dispose() {
    _disposeControllers();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _placeOfBirthController.dispose();
    _cniNumberController.dispose();
    _residenceAddressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _previousDiplomaController.dispose();
    _previousInstitutionController.dispose();
    _desiredProgramController.dispose();
    _specializationController.dispose();
    _bacCenterController.dispose();
    _gpaScoreController.dispose();
    _rankInClassController.dispose();
    _graduationMonthController.dispose();
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
    _specialNeedsController.dispose();
    _medicalConditionsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Formulaire de Préinscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(widget.faculty, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.black12,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Column(
        children: [
          _buildGuestAccountInfo(),
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalInfoStep(),
                  _buildAcademicStep(),
                  _buildParentStep(),
                  _buildDocumentsPaymentStep(),
                  _buildFinalizationStep(),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildGuestAccountInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Création automatique de compte',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Un compte invité sera automatiquement créé avec votre email et numéro de téléphone lors de la soumission.',
            style: TextStyle(
              fontSize: 14.5,
              color: const Color(0xFF475569),
              height: 1.6,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Assurez-vous que vos informations sont exactes',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < _currentStep;
            return Expanded(
              flex: 2,
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == _currentStep;
          final isCompleted = stepIndex < _currentStep;

          return Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFF3B82F6)
                        : isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white,
                    border: Border.all(
                      color: isActive || isCompleted
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                        : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _steps[stepIndex],
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: isActive
                        ? const Color(0xFF3B82F6)
                        : isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Informations personnelles', Icons.person_outline),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: _buildRequiredTextField('Nom', _lastNameController)),
              const SizedBox(width: 14),
              Expanded(child: _buildRequiredTextField('Prénom', _firstNameController)),
            ],
          ),
          const SizedBox(height: 18),
          
          _buildOptionalTextField('Autre prénom', _middleNameController),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: _buildDateSelector('Date de naissance', _dateOfBirth, (date) {
                  setState(() {
                    _dateOfBirth = date;
                  });
                }),
              ),
              const SizedBox(width: 14),
              Expanded(child: _buildRequiredTextField('Lieu de naissance', _placeOfBirthController)),
            ],
          ),
          const SizedBox(height: 18),
          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isBirthDateOnCertificate,
                    onChanged: (value) {
                      setState(() {
                        _isBirthDateOnCertificate = value ?? true;
                      });
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'La date de naissance correspond à celle sur le certificat',
                    style: TextStyle(fontSize: 14, color: Color(0xFF475569), letterSpacing: -0.1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(child: _buildRequiredDropdown('Genre', _gender, CompletePreinscriptionConstants.genders)),
              const SizedBox(width: 14),
              Expanded(child: _buildRequiredDropdown('Situation maritale', _maritalStatus, CompletePreinscriptionConstants.maritalStatuses)),
            ],
          ),
          const SizedBox(height: 18),
          
          _buildOptionalTextField('Numéro CNI/PI', _cniNumberController),
          const SizedBox(height: 18),
          
          _buildRequiredTextField('Adresse de résidence', _residenceAddressController, maxLines: 3),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: _buildRequiredTextField('Téléphone', _phoneNumberController, 
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildRequiredTextField('Email', _emailController, 
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(child: _buildRequiredDropdown('Première langue', _firstLanguage, CompletePreinscriptionConstants.languages)),
              const SizedBox(width: 14),
              Expanded(child: _buildRequiredDropdown('Situation professionnelle', _professionalSituation, CompletePreinscriptionConstants.professionalSituations)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Parcours académique', Icons.school_outlined),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: _buildRequiredDropdown('Diplôme précédent', _previousDiplomaController.text.isEmpty ? '' : _previousDiplomaController.text, CompletePreinscriptionConstants.diplomas, (value) {
                _previousDiplomaController.text = value;
              })),
              const SizedBox(width: 14),
              Expanded(child: _buildOptionalTextField('Établissement précédent', _previousInstitutionController)),
            ],
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: _buildYearSelector('Année d\'obtention', _graduationYear, (year) {
                  setState(() {
                    _graduationYear = year;
                  });
                }),
              ),
              const SizedBox(width: 14),
              Expanded(child: _buildOptionalTextField('Mois d\'obtention', _graduationMonthController)),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildRequiredTextField('Programme souhaité', _desiredProgramController),
          const SizedBox(height: 18),
          
          if (widget.selectedFiliere != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Filière sélectionnée',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.selectedFiliere!.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(widget.selectedFiliere!.code, Icons.tag),
                      _buildInfoChip(widget.selectedFiliere!.degreeLevel, Icons.workspace_premium),
                      _buildInfoChip('${widget.selectedFiliere!.duration} an${widget.selectedFiliere!.duration > 1 ? 's' : ''}', Icons.calendar_today),
                    ],
                  ),
                  if (widget.selectedFiliere!.description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.selectedFiliere!.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.5,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          
          Row(
            children: [
              Expanded(child: _buildRequiredDropdown('Niveau d\'études', _studyLevel, CompletePreinscriptionConstants.studyLevels)),
              const SizedBox(width: 14),
              if (widget.selectedFiliere == null)
                Expanded(child: _buildOptionalTextField('Spécialisation', _specializationController))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 28),
          
          _buildSectionHeader('Informations BAC (si applicable)', Icons.assignment_outlined, optional: true),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: _buildOptionalDropdownWithCallback('Série du BAC', _seriesBac, CompletePreinscriptionConstants.bacSeries, (value) {
                  setState(() {
                    _seriesBac = value ?? '';
                  });
                }),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildYearSelector('Année du BAC', _bacYear, (year) {
                  setState(() {
                    _bacYear = year;
                  });
                }, optional: true),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(child: _buildOptionalTextField('Centre d\'examen', _bacCenterController)),
              const SizedBox(width: 14),
              Expanded(child: _buildOptionalDropdown('Mention', _bacMention, CompletePreinscriptionConstants.bacMentions)),
            ],
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: _buildOptionalTextField('Score GPA', _gpaScoreController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildOptionalTextField('Rang dans la classe', _rankInClassController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParentStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Informations parents/tuteurs', Icons.family_restroom_outlined),
          const SizedBox(height: 24),
          
          _buildRequiredTextField('Nom complet du parent/tuteur', _parentNameController),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(
                child: _buildRequiredTextField('Téléphone', _parentPhoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildOptionalTextField('Email', _parentEmailController, 
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(child: _buildOptionalTextField('Profession', _parentOccupationController)),
              const SizedBox(width: 14),
              Expanded(child: _buildOptionalDropdown('Lien de parenté', _parentRelationship, CompletePreinscriptionConstants.parentRelationships)),
            ],
          ),
          const SizedBox(height: 18),
          
          _buildOptionalTextField('Adresse du parent', _parentAddressController, maxLines: 3),
          const SizedBox(height: 18),
          
          _buildOptionalDropdown('Niveau de revenu', _parentIncomeLevel, CompletePreinscriptionConstants.incomeLevels),
        ],
      ),
    );
  }

  Widget _buildDocumentsPaymentStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Documents requis', Icons.file_upload_outlined),
          const SizedBox(height: 18),
          
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Documents à fournir',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                _buildDocumentItem('Certificat de naissance', true),
                _buildDocumentItem('CNI/PI', true),
                _buildDocumentItem('Diplôme précédent', true),
                _buildDocumentItem('Relevé de notes', true),
                _buildDocumentItem('Photo d\'identité', true),
                _buildDocumentItem('Lettre de motivation', false),
                _buildDocumentItem('Certificat médical', false),
              ],
            ),
          ),
          const SizedBox(height: 28),
          
          _buildSectionHeader('Informations de paiement', Icons.payment_outlined),
          const SizedBox(height: 18),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Frais de préinscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC2410C),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${CompletePreinscriptionConstants.registrationFee} FCFA',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF97316),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildRequiredDropdown('Méthode de paiement', _paymentMethod, CompletePreinscriptionConstants.paymentMethods),
                const SizedBox(height: 16),
                
                _buildOptionalTextField('Référence de paiement', _paymentReferenceController),
                const SizedBox(height: 16),
                
                _buildOptionalTextField('Montant payé', _paymentAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  prefixIcon: Icons.attach_money,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          
          _buildSectionHeader('Aide financière', Icons.savings_outlined, optional: true),
          const SizedBox(height: 14),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _scholarshipRequested,
                        onChanged: (value) {
                          setState(() {
                            _scholarshipRequested = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeColor: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Je souhaite demander une bourse/aide financière',
                        style: TextStyle(fontSize: 14.5, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (_scholarshipRequested) ...[
                  const SizedBox(height: 18),
                  _buildOptionalTextField('Type de bourse demandée', _scholarshipTypeController),
                  const SizedBox(height: 16),
                  _buildOptionalTextField('Montant aide financière', _financialAidAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    prefixIcon: Icons.attach_money,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizationStep() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Préférences de contact', Icons.contact_mail_outlined),
          const SizedBox(height: 18),
          
          _buildOptionalDropdown('Préférence de contact', _contactPreference, CompletePreinscriptionConstants.contactPreferences),
          const SizedBox(height: 28),
          
          _buildSectionHeader('Consentements', Icons.verified_user_outlined),
          const SizedBox(height: 14),
          
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildConsentCheckbox(
                  'J\'accepte de recevoir des informations marketing',
                  _marketingConsent,
                  (value) => setState(() => _marketingConsent = value),
                ),
                const Divider(height: 1),
                _buildConsentCheckbox(
                  'J\'accepte le traitement de mes données personnelles *',
                  _dataProcessingConsent,
                  (value) => setState(() => _dataProcessingConsent = value),
                  required: true,
                ),
                const Divider(height: 1),
                _buildConsentCheckbox(
                  'Je souhaite m\'abonner à la newsletter',
                  _newsletterSubscription,
                  (value) => setState(() => _newsletterSubscription = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          
          _buildSectionHeader('Informations supplémentaires', Icons.note_add_outlined, optional: true),
          const SizedBox(height: 18),
          
          _buildOptionalTextField('Notes générales', _notesController, maxLines: 3),
          const SizedBox(height: 16),
          
          _buildOptionalTextField('Besoins spéciaux', _specialNeedsController, maxLines: 2),
          const SizedBox(height: 16),
          
          _buildOptionalTextField('Conditions médicales', _medicalConditionsController, maxLines: 2),
          const SizedBox(height: 28),
          
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fact_check, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Résumé de la préinscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF065F46),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSummaryItem('Code unique', _uniqueCode, Icons.qr_code),
          _buildSummaryItem('Faculté', widget.faculty, Icons.account_balance),
          if (widget.selectedFiliere != null) ...[
            _buildSummaryItem('Filière', widget.selectedFiliere!.name, Icons.school),
            _buildSummaryItem('Détails', '${widget.selectedFiliere!.code} • ${widget.selectedFiliere!.degreeLevel}', Icons.info_outline),
          ],
          _buildSummaryItem('Nom', '${_firstNameController.text} ${_lastNameController.text}', Icons.person),
          _buildSummaryItem('Email', _emailController.text, Icons.email),
          _buildSummaryItem('Téléphone', _phoneNumberController.text, Icons.phone),
          _buildSummaryItem('Programme', _desiredProgramController.text, Icons.menu_book),
          _buildSummaryItem('Niveau', _studyLevel, Icons.stairs),
          if (widget.selectedFiliere == null && _specializationController.text.isNotEmpty)
            _buildSummaryItem('Spécialisation', _specializationController.text, Icons.category),
          
          if (_paymentMethod.isNotEmpty)
            _buildSummaryItem('Méthode paiement', _paymentMethod, Icons.payment),
          
          if (_scholarshipRequested) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.savings, size: 18, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text('Bourse demandée: Oui', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w600, fontSize: 13.5)),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'En soumettant ce formulaire, vous confirmez que toutes les informations fournies sont exactes.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF059669)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF059669),
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Non renseigné',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String document, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$document${required ? ' *' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF475569),
                fontWeight: required ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 18, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox(String title, bool value, Function(bool) onChanged, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: (val) => onChanged(val ?? false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF475569),
                fontWeight: required ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 8),
                    Text('Précédent', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else
              const SizedBox(width: 100),
            
            if (_currentStep < _steps.length - 1)
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  children: const [
                    Text('Suivant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF10B981).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        children: const [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 10),
                          Text('Soumettre', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateAcademicInfo();
      case 2:
        return _validateParentInfo();
      case 3:
        return _validateDocumentsPayment();
      case 4:
        return _validateFinalization();
      default:
        return true;
    }
  }

  bool _validatePersonalInfo() {
    if (_lastNameController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _placeOfBirthController.text.isEmpty ||
        _dateOfBirth == null ||
        _gender.isEmpty ||
        _maritalStatus.isEmpty ||
        _residenceAddressController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _firstLanguage.isEmpty ||
        _professionalSituation.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs obligatoires');
      return false;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showErrorDialog('Veuillez entrer une adresse email valide');
      return false;
    }

    return true;
  }

  bool _validateAcademicInfo() {
    if (_previousDiplomaController.text.isEmpty ||
        _graduationYear == null ||
        _desiredProgramController.text.isEmpty ||
        _studyLevel.isEmpty) {
      _showErrorDialog('Veuillez remplir les informations académiques obligatoires');
      return false;
    }

    if (_graduationYear! < CompletePreinscriptionConstants.minGraduationYear ||
        _graduationYear! > CompletePreinscriptionConstants.maxGraduationYear) {
      _showErrorDialog('Veuillez entrer une année valide');
      return false;
    }

    return true;
  }

  bool _validateParentInfo() {
    if (_parentNameController.text.isEmpty ||
        _parentPhoneController.text.isEmpty) {
      _showErrorDialog('Veuillez remplir les informations du parent/tuteur');
      return false;
    }

    return true;
  }

  bool _validateDocumentsPayment() {
    if (_paymentMethod.isEmpty) {
      _showErrorDialog('Veuillez sélectionner une méthode de paiement');
      return false;
    }

    return true;
  }

  bool _validateFinalization() {
    if (!_dataProcessingConsent) {
      _showErrorDialog('Vous devez accepter le traitement de vos données personnelles');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final preinscription = CompletePreinscriptionModel(
        uniqueCode: _uniqueCode,
        faculty: widget.faculty,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        middleName: _middleNameController.text.isEmpty ? null : _middleNameController.text,
        dateOfBirth: _dateOfBirth!,
        isBirthDateOnCertificate: _isBirthDateOnCertificate,
        placeOfBirth: _placeOfBirthController.text,
        gender: _gender,
        cniNumber: _cniNumberController.text.isEmpty ? null : _cniNumberController.text,
        residenceAddress: _residenceAddressController.text,
        maritalStatus: _maritalStatus,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        firstLanguage: _firstLanguage,
        professionalSituation: _professionalSituation,

        previousDiploma: _previousDiplomaController.text,
        previousInstitution: _previousInstitutionController.text.isEmpty ? null : _previousInstitutionController.text,
        graduationYear: _graduationYear,
        graduationMonth: _graduationMonthController.text.isEmpty ? null : _graduationMonthController.text,
        desiredProgram: _desiredProgramController.text,
        studyLevel: _studyLevel,
        specialization: _specializationController.text.isEmpty ? null : _specializationController.text,
        seriesBac: _seriesBac.isEmpty ? null : _seriesBac,
        bacYear: _bacYear,
        bacCenter: _bacCenterController.text.isEmpty ? null : _bacCenterController.text,
        bacMention: _bacMention.isEmpty ? null : _bacMention,
        gpaScore: _gpaScoreController.text.isEmpty ? null : double.tryParse(_gpaScoreController.text),
        rankInClass: _rankInClassController.text.isEmpty ? null : int.tryParse(_rankInClassController.text),

        parentName: _parentNameController.text,
        parentPhone: _parentPhoneController.text,
        parentEmail: _parentEmailController.text.isEmpty ? null : _parentEmailController.text,
        parentOccupation: _parentOccupationController.text.isEmpty ? null : _parentOccupationController.text,
        parentAddress: _parentAddressController.text.isEmpty ? null : _parentAddressController.text,
        parentRelationship: _parentRelationship.isEmpty ? null : _parentRelationship,
        parentIncomeLevel: _parentIncomeLevel.isEmpty ? null : _parentIncomeLevel,

        paymentMethod: _paymentMethod,
        paymentReference: _paymentReferenceController.text.isEmpty ? null : _paymentReferenceController.text,
        paymentAmount: _paymentAmountController.text.isEmpty ? null : double.tryParse(_paymentAmountController.text),
        scholarshipRequested: _scholarshipRequested,
        scholarshipType: _scholarshipTypeController.text.isEmpty ? null : _scholarshipTypeController.text,
        financialAidAmount: _financialAidAmountController.text.isEmpty ? null : double.tryParse(_financialAidAmountController.text),

        contactPreference: _contactPreference.isEmpty ? null : _contactPreference,
        marketingConsent: _marketingConsent,
        dataProcessingConsent: _dataProcessingConsent,
        newsletterSubscription: _newsletterSubscription,

        notes: _notesController.text.isEmpty ? null : _notesController.text,
        specialNeeds: _specialNeedsController.text.isEmpty ? null : _specialNeedsController.text,
        medicalConditions: _medicalConditionsController.text.isEmpty ? null : _medicalConditionsController.text,

        ipAddress: '127.0.0.1',
        userAgent: 'Flutter App',
      );

      final result = await _preinscriptionService.submitCompletePreinscription(preinscription);

      if (result['success']) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result['message'] ?? 'Erreur lors de la soumission');
      }
    } catch (e) {
      _showErrorDialog('Une erreur est survenue: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Préinscription réussie!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Votre demande a été soumise avec succès',
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Text('Code de référence', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(
                        _uniqueCode ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6), letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_add_rounded, color: Color(0xFF2563EB), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Compte invité créé',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Votre compte a été créé automatiquement. Vous recevrez une confirmation par email avec les détails de suivi.',
                        style: TextStyle(fontSize: 13, color: const Color(0xFF475569), height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 56),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Erreur',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {bool optional = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (optional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Optionnel',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildRequiredTextField(String label, TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        suffixIcon: const Icon(Icons.star, size: 8, color: Color(0xFFEF4444)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: const Color(0xFF94A3B8)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
    );
  }

  Widget _buildOptionalTextField(String label, TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: const Color(0xFF94A3B8)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildRequiredDropdown(String label, String value, List<String> options, [Function(String)? onChanged]) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        suffixIcon: const Icon(Icons.star, size: 8, color: Color(0xFFEF4444)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          if (label == 'Genre') _gender = newValue ?? '';
          else if (label == 'Situation maritale') _maritalStatus = newValue ?? '';
          else if (label == 'Première langue') _firstLanguage = newValue ?? '';
          else if (label == 'Situation professionnelle') _professionalSituation = newValue ?? '';
          else if (label == 'Niveau d\'études') _studyLevel = newValue ?? '';
          else if (label == 'Méthode de paiement') _paymentMethod = newValue ?? '';
          else if (label == 'Préférence de contact') _contactPreference = newValue ?? '';
        });
        onChanged?.call(newValue ?? '');
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildOptionalDropdown(String label, String value, List<String> options) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          if (label == 'Mention') _bacMention = newValue ?? '';
          else if (label == 'Lien de parenté') _parentRelationship = newValue ?? '';
          else if (label == 'Niveau de revenu') _parentIncomeLevel = newValue ?? '';
        });
      },
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildOptionalDropdownWithCallback(String label, String value, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildDateSelector(String label, DateTime? selectedDate, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF3B82F6),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          suffixIcon: const Icon(Icons.star, size: 8, color: Color(0xFFEF4444)),
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF94A3B8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
              : 'Sélectionner une date',
          style: TextStyle(
            fontSize: 15,
            color: selectedDate != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector(String label, int? selectedYear, Function(int) onChanged, {bool optional = false}) {
    final currentYear = DateTime.now().year;
    final years = List.generate(50, (index) => currentYear - index);

    return DropdownButtonFormField<int>(
      value: selectedYear,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        suffixIcon: optional ? null : const Icon(Icons.star, size: 8, color: Color(0xFFEF4444)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: years.map((int year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString(), style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      validator: optional ? null : (value) {
        if (value == null) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
