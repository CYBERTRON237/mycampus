import 'package:flutter/material.dart';
import 'package:mycampus/constants/app_colors.dart';

class EditPreinscriptionDialog extends StatefulWidget {
  final String section;
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onSave;

  const EditPreinscriptionDialog({
    Key? key,
    required this.section,
    required this.data,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditPreinscriptionDialogState createState() => _EditPreinscriptionDialogState();
}

class _EditPreinscriptionDialogState extends State<EditPreinscriptionDialog> {
  late Map<String, TextEditingController> _controllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    
    // Initialize controllers based on section
    switch (widget.section) {
      case 'personnelles':
        _initializePersonalControllers();
        break;
      case 'académiques':
        _initializeAcademicControllers();
        break;
      case 'parents':
        _initializeParentsControllers();
        break;
      case 'paiement':
        _initializePaymentControllers();
        break;
    }
  }

  void _initializePersonalControllers() {
    final fields = [
      'first_name', 'last_name', 'middle_name', 'date_of_birth',
      'place_of_birth', 'gender', 'marital_status', 'phone_number',
      'email', 'first_language', 'professional_situation', 'residence_address'
    ];
    
    for (String field in fields) {
      _controllers[field] = TextEditingController(
        text: widget.data[field]?.toString() ?? '',
      );
    }
  }

  void _initializeAcademicControllers() {
    final fields = [
      'faculty', 'previous_diploma', 'previous_institution', 'graduation_year',
      'graduation_month', 'desired_program', 'study_level', 'specialization',
      'gpa_score', 'rank_in_class'
    ];
    
    for (String field in fields) {
      _controllers[field] = TextEditingController(
        text: widget.data[field]?.toString() ?? '',
      );
    }
  }

  void _initializeParentsControllers() {
    final fields = [
      'parent_name', 'parent_phone', 'parent_email', 'parent_occupation',
      'parent_relationship', 'parent_income_level', 'parent_address'
    ];
    
    for (String field in fields) {
      _controllers[field] = TextEditingController(
        text: widget.data[field]?.toString() ?? '',
      );
    }
  }

  void _initializePaymentControllers() {
    final fields = [
      'payment_method', 'payment_reference', 'payment_amount', 'payment_status',
      'scholarship_type'
    ];
    
    for (String field in fields) {
      _controllers[field] = TextEditingController(
        text: widget.data[field]?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Widget> _buildFormFields() {
    switch (widget.section) {
      case 'personnelles':
        return _buildPersonalFields();
      case 'académiques':
        return _buildAcademicFields();
      case 'parents':
        return _buildParentsFields();
      case 'paiement':
        return _buildPaymentFields();
      default:
        return [];
    }
  }

  List<Widget> _buildPersonalFields() {
    return [
      _buildTextField('first_name', 'Prénom'),
      _buildTextField('last_name', 'Nom'),
      _buildTextField('middle_name', 'Post-nom'),
      _buildTextField('date_of_birth', 'Date de naissance', hint: 'YYYY-MM-DD'),
      _buildTextField('place_of_birth', 'Lieu de naissance'),
      _buildDropdownField('gender', 'Sexe', ['Masculin', 'Féminin', 'Autre']),
      _buildTextField('marital_status', 'Situation matrimoniale'),
      _buildTextField('phone_number', 'Téléphone'),
      _buildTextField('email', 'Email'),
      _buildTextField('first_language', 'Langue maternelle'),
      _buildTextField('professional_situation', 'Situation professionnelle'),
      _buildTextField('residence_address', 'Adresse', maxLines: 3),
    ];
  }

  List<Widget> _buildAcademicFields() {
    return [
      _buildTextField('faculty', 'Faculté'),
      _buildTextField('previous_diploma', 'Dernier diplôme'),
      _buildTextField('previous_institution', 'Établissement précédent'),
      _buildTextField('graduation_year', 'Année d\'obtention', hint: 'YYYY'),
      _buildTextField('graduation_month', 'Mois d\'obtention'),
      _buildTextField('desired_program', 'Programme désiré'),
      _buildTextField('study_level', 'Niveau d\'étude'),
      _buildTextField('specialization', 'Spécialisation'),
      _buildTextField('gpa_score', 'Score GPA'),
      _buildTextField('rank_in_class', 'Rang dans la classe'),
    ];
  }

  List<Widget> _buildParentsFields() {
    return [
      _buildTextField('parent_name', 'Nom du parent'),
      _buildTextField('parent_phone', 'Téléphone parent'),
      _buildTextField('parent_email', 'Email parent'),
      _buildTextField('parent_occupation', 'Occupation parent'),
      _buildTextField('parent_relationship', 'Relation'),
      _buildTextField('parent_income_level', 'Niveau de revenu'),
      _buildTextField('parent_address', 'Adresse parent', maxLines: 3),
    ];
  }

  List<Widget> _buildPaymentFields() {
    return [
      _buildDropdownField('payment_method', 'Méthode de paiement', 
        ['Espèces', 'Carte bancaire', 'Mobile Money', 'Virement bancaire']),
      _buildTextField('payment_reference', 'Référence paiement'),
      _buildTextField('payment_amount', 'Montant'),
      _buildDropdownField('payment_status', 'Statut paiement', 
        ['En attente', 'Payé', 'Partiellement payé', 'Annulé']),
      _buildTextField('scholarship_type', 'Type bourse'),
    ];
  }

  Widget _buildTextField(String key, String label, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[key]!,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        maxLines: maxLines,
        keyboardType: key.contains('email') ? TextInputType.emailAddress : 
                   key.contains('phone') ? TextInputType.phone :
                   key.contains('amount') || key.contains('year') || key.contains('gpa') || key.contains('rank') 
                     ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildDropdownField(String key, String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _controllers[key]!.text.isNotEmpty ? _controllers[key]!.text : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            _controllers[key]!.text = value;
          }
        },
      ),
    );
  }

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> updatedData = {};
    for (String key in _controllers.keys) {
      if (_controllers[key]!.text.isNotEmpty) {
        updatedData[key] = _controllers[key]!.text;
      }
    }

    try {
      await widget.onSave(updatedData);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSectionIcon(),
                    color: _getSectionColor(),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modifier ${_getSectionTitle()}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getSectionColor(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFormFields(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getSectionColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSectionIcon() {
    switch (widget.section) {
      case 'personnelles':
        return Icons.person;
      case 'académiques':
        return Icons.school;
      case 'parents':
        return Icons.family_restroom;
      case 'paiement':
        return Icons.payment;
      default:
        return Icons.edit;
    }
  }

  Color _getSectionColor() {
    switch (widget.section) {
      case 'personnelles':
        return AppColors.primary;
      case 'académiques':
        return AppColors.secondary;
      case 'parents':
        return Colors.purple;
      case 'paiement':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _getSectionTitle() {
    switch (widget.section) {
      case 'personnelles':
        return 'les informations personnelles';
      case 'académiques':
        return 'les informations académiques';
      case 'parents':
        return 'les informations parents';
      case 'paiement':
        return 'les informations de paiement';
      default:
        return 'les informations';
    }
  }
}
