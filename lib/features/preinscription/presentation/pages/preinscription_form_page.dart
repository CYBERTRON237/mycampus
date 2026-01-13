import 'package:flutter/material.dart';
import 'package:mycampus/core/constants/colors.dart';

class PreinscriptionFormPage extends StatefulWidget {
  final String formationType;

  const PreinscriptionFormPage({
    Key? key,
    required this.formationType,
  }) : super(key: key);

  @override
  _PreinscriptionFormPageState createState() => _PreinscriptionFormPageState();
}

class _PreinscriptionFormPageState extends State<PreinscriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'nom': '',
    'prenom': '',
    'email': '',
    'telephone': '',
    'dateNaissance': null,
    'lieuNaissance': '',
    'adresse': '',
    'ville': '',
    'pays': '',
    'niveauEtude': '',
    'dernierDiplome': '',
    'filiereSouhaitee': '',
  };

  final List<String> _niveauxEtude = [
    'Bac',
    'Bac+1',
    'Bac+2',
    'Licence',
    'Master',
    'Doctorat',
    'Autre',
  ];

  final List<String> _filieres = [
    'Informatique',
    'Gestion',
    'Droit',
    'Médecine',
    'Ingénierie',
    'Lettres',
    'Sciences',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Préinscription - ${widget.formationType}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextFormField('Nom', 'nom'),
              const SizedBox(height: 12),
              _buildTextFormField('Prénom', 'prenom'),
              const SizedBox(height: 12),
              _buildTextFormField('Email', 'email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextFormField('Téléphone', 'telephone', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildDatePicker('Date de naissance', 'dateNaissance'),
              const SizedBox(height: 12),
              _buildTextFormField('Lieu de naissance', 'lieuNaissance'),
              
              const SizedBox(height: 24),
              const Text(
                'Adresse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextFormField('Adresse', 'adresse'),
              const SizedBox(height: 12),
              _buildTextFormField('Ville', 'ville'),
              const SizedBox(height: 12),
              _buildTextFormField('Pays', 'pays'),
              
              const SizedBox(height: 24),
              const Text(
                'Informations académiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown('Niveau d\'étude', 'niveauEtude', _niveauxEtude),
              const SizedBox(height: 12),
              _buildTextFormField('Dernier diplôme obtenu', 'dernierDiplome'),
              const SizedBox(height: 12),
              _buildDropdown('Filière souhaitée', 'filiereSouhaitee', _filieres),
              
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, String field, {TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        if (field == 'email' && !value.contains('@')) {
          return 'Veuillez entrer une adresse email valide';
        }
        return null;
      },
      onSaved: (value) {
        _formData[field] = value!;
      },
    );
  }

  Widget _buildDatePicker(String label, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.labelLarge?.color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, field),
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formData[field] != null
                      ? '${_formData[field].day}/${_formData[field].month}/${_formData[field].year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _formData[field] != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    
    if (picked != null) {
      setState(() {
        _formData[field] = picked;
      });
    }
  }

  Widget _buildDropdown(String label, String field, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.labelLarge?.color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _formData[field].isNotEmpty ? _formData[field] : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _formData[field] = newValue!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une option';
            }
            return null;
          },
          isExpanded: true,
          hint: const Text('Sélectionner'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Soumettre ma préinscription',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Afficher un dialogue de confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Voulez-vous soumettre votre préinscription ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implémenter la soumission du formulaire
                  Navigator.of(context).pop();
                  _showSuccessDialog();
                },
                child: const Text('Confirmer'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Demande enregistrée'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre demande de préinscription a été enregistrée avec succès !',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Numéro de dossier: ${DateTime.now().millisecondsSinceEpoch}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
