import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mycampus/constants/app_colors.dart';
import 'package:mycampus/features/preinscription/presentation/widgets/edit_preinscription_dialog.dart';

class PreinscriptionFichePage extends StatefulWidget {
  const PreinscriptionFichePage({Key? key}) : super(key: key);

  @override
  _PreinscriptionFichePageState createState() => _PreinscriptionFichePageState();
}

class _PreinscriptionFichePageState extends State<PreinscriptionFichePage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _preinscriptionData;
  String? _errorMessage;

  Future<void> _updatePreinscription(Map<String, dynamic> updatedData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1/mycampus/api/preinscriptions/update_preinscription.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'unique_code': _preinscriptionData!['unique_code'],
          ...updatedData,
        }),
      );

      final result = jsonDecode(response.body);
      
      if (result['success'] == true) {
        setState(() {
          _preinscriptionData = result['data'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations mises à jour avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _searchPreinscription() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un code de préinscription'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _preinscriptionData = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'unique_code': _codeController.text.trim().toUpperCase(),
        }),
      );

      final result = jsonDecode(response.body);
      
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _preinscriptionData = result['data'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Préinscription non trouvée';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditDialog(String section, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPreinscriptionDialog(
          section: section,
          data: data,
          onSave: (updatedData) {
            _updatePreinscription(updatedData);
          },
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Consulter ma fiche de préinscription',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Code unique de préinscription',
                  hintText: 'Ex: PRE2025123456',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  labelStyle: const TextStyle(color: AppColors.primary),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _searchPreinscription(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchPreinscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Rechercher ma préinscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreinscriptionCard() {
    if (_preinscriptionData == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec statut
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: _getStatusGradient(_preinscriptionData!['status']),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'FICHE DE PRÉINSCRIPTION',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _preinscriptionData!['status']?.toString().toUpperCase() ?? 'INCONNU',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Code: ${_preinscriptionData!['unique_code']}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Informations personnelles
                _buildSectionCard(
                  title: 'INFORMATIONS PERSONNELLES',
                  icon: Icons.person,
                  color: AppColors.primary,
                  children: [
                    _buildInfoGrid([
                      {'label': 'Nom', 'value': _preinscriptionData!['last_name']},
                      {'label': 'Prénom', 'value': _preinscriptionData!['first_name']},
                      if (_preinscriptionData!['middle_name'] != null)
                        {'label': 'Post-nom', 'value': _preinscriptionData!['middle_name']},
                      {'label': 'Date de naissance', 'value': _formatDate(_preinscriptionData!['date_of_birth'])},
                      {'label': 'Lieu de naissance', 'value': _preinscriptionData!['place_of_birth']},
                      {'label': 'Sexe', 'value': _preinscriptionData!['gender']},
                      {'label': 'Situation matrimoniale', 'value': _preinscriptionData!['marital_status']},
                      {'label': 'Téléphone', 'value': _preinscriptionData!['phone_number']},
                      {'label': 'Email', 'value': _preinscriptionData!['email']},
                      {'label': 'Langue maternelle', 'value': _preinscriptionData!['first_language']},
                      {'label': 'Situation professionnelle', 'value': _preinscriptionData!['professional_situation']},
                    ]),
                    if (_preinscriptionData!['residence_address'] != null)
                      _buildFullWidthInfo('Adresse', _preinscriptionData!['residence_address']),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showEditDialog('personnelles', {
                        'first_name': _preinscriptionData!['first_name'],
                        'last_name': _preinscriptionData!['last_name'],
                        'middle_name': _preinscriptionData!['middle_name'],
                        'date_of_birth': _preinscriptionData!['date_of_birth'],
                        'place_of_birth': _preinscriptionData!['place_of_birth'],
                        'gender': _preinscriptionData!['gender'],
                        'marital_status': _preinscriptionData!['marital_status'],
                        'phone_number': _preinscriptionData!['phone_number'],
                        'email': _preinscriptionData!['email'],
                        'first_language': _preinscriptionData!['first_language'],
                        'professional_situation': _preinscriptionData!['professional_situation'],
                        'residence_address': _preinscriptionData!['residence_address'],
                      }),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier les informations personnelles'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Informations académiques
                _buildSectionCard(
                  title: 'INFORMATIONS ACADÉMIQUES',
                  icon: Icons.school,
                  color: AppColors.secondary,
                  children: [
                    _buildInfoGrid([
                      {'label': 'Faculté', 'value': _preinscriptionData!['faculty']},
                      {'label': 'Dernier diplôme', 'value': _preinscriptionData!['previous_diploma']},
                      {'label': 'Établissement précédent', 'value': _preinscriptionData!['previous_institution']},
                      {'label': 'Année d\'obtention', 'value': _preinscriptionData!['graduation_year']?.toString()},
                      {'label': 'Mois d\'obtention', 'value': _preinscriptionData!['graduation_month']},
                      {'label': 'Programme désiré', 'value': _preinscriptionData!['desired_program']},
                      {'label': 'Niveau d\'étude', 'value': _preinscriptionData!['study_level']},
                      {'label': 'Spécialisation', 'value': _preinscriptionData!['specialization']},
                      if (_preinscriptionData!['gpa_score'] != null)
                        {'label': 'Score GPA', 'value': _preinscriptionData!['gpa_score'].toString()},
                      if (_preinscriptionData!['rank_in_class'] != null)
                        {'label': 'Rang dans la classe', 'value': _preinscriptionData!['rank_in_class'].toString()},
                    ]),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showEditDialog('académiques', {
                        'faculty': _preinscriptionData!['faculty'],
                        'previous_diploma': _preinscriptionData!['previous_diploma'],
                        'previous_institution': _preinscriptionData!['previous_institution'],
                        'graduation_year': _preinscriptionData!['graduation_year'],
                        'graduation_month': _preinscriptionData!['graduation_month'],
                        'desired_program': _preinscriptionData!['desired_program'],
                        'study_level': _preinscriptionData!['study_level'],
                        'specialization': _preinscriptionData!['specialization'],
                        'gpa_score': _preinscriptionData!['gpa_score'],
                        'rank_in_class': _preinscriptionData!['rank_in_class'],
                      }),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier les informations académiques'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Informations Baccalauréat
                if (_preinscriptionData!['series_bac'] != null) ...[
                  _buildSectionCard(
                    title: 'INFORMATIONS BACCALAURÉAT',
                    icon: Icons.menu_book,
                    color: Colors.green,
                    children: [
                      _buildInfoGrid([
                        {'label': 'Série BAC', 'value': _preinscriptionData!['series_bac']},
                        {'label': 'Année BAC', 'value': _preinscriptionData!['bac_year']?.toString()},
                        {'label': 'Centre BAC', 'value': _preinscriptionData!['bac_center']},
                        {'label': 'Mention BAC', 'value': _preinscriptionData!['bac_mention']},
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Informations parents
                _buildSectionCard(
                  title: 'INFORMATIONS PARENTS',
                  icon: Icons.family_restroom,
                  color: Colors.purple,
                  children: [
                    _buildInfoGrid([
                      {'label': 'Nom du parent', 'value': _preinscriptionData!['parent_name']},
                      {'label': 'Téléphone parent', 'value': _preinscriptionData!['parent_phone']},
                      {'label': 'Email parent', 'value': _preinscriptionData!['parent_email']},
                      {'label': 'Occupation parent', 'value': _preinscriptionData!['parent_occupation']},
                      {'label': 'Relation', 'value': _preinscriptionData!['parent_relationship']},
                      {'label': 'Niveau de revenu', 'value': _preinscriptionData!['parent_income_level']},
                    ]),
                    if (_preinscriptionData!['parent_address'] != null)
                      _buildFullWidthInfo('Adresse parent', _preinscriptionData!['parent_address']),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showEditDialog('parents', {
                        'parent_name': _preinscriptionData!['parent_name'],
                        'parent_phone': _preinscriptionData!['parent_phone'],
                        'parent_email': _preinscriptionData!['parent_email'],
                        'parent_occupation': _preinscriptionData!['parent_occupation'],
                        'parent_relationship': _preinscriptionData!['parent_relationship'],
                        'parent_income_level': _preinscriptionData!['parent_income_level'],
                        'parent_address': _preinscriptionData!['parent_address'],
                      }),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier les informations parents'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Informations paiement
                _buildSectionCard(
                  title: 'INFORMATIONS PAIEMENT',
                  icon: Icons.payment,
                  color: Colors.orange,
                  children: [
                    _buildInfoGrid([
                      {'label': 'Méthode de paiement', 'value': _preinscriptionData!['payment_method']},
                      if (_preinscriptionData!['payment_reference'] != null)
                        {'label': 'Référence paiement', 'value': _preinscriptionData!['payment_reference']},
                      if (_preinscriptionData!['payment_amount'] != null)
                        {'label': 'Montant', 'value': '${_preinscriptionData!['payment_amount']} XAF'},
                      {'label': 'Statut paiement', 'value': _preinscriptionData!['payment_status']},
                      {'label': 'Bourse demandée', 'value': _preinscriptionData!['scholarship_requested'] == 1 ? 'Oui' : 'Non'},
                      if (_preinscriptionData!['scholarship_type'] != null)
                        {'label': 'Type bourse', 'value': _preinscriptionData!['scholarship_type']},
                    ]),
                  ],
                ),

                const SizedBox(height: 20),

                // Documents
                _buildSectionCard(
                  title: 'DOCUMENTS',
                  icon: Icons.folder,
                  color: Colors.teal,
                  children: [
                    _buildDocumentsGrid([
                      {'label': 'Acte de naissance', 'path': _preinscriptionData!['birth_certificate_path']},
                      {'label': 'CNI', 'path': _preinscriptionData!['cni_path']},
                      {'label': 'Diplôme', 'path': _preinscriptionData!['diploma_path']},
                      {'label': 'Relevé de notes', 'path': _preinscriptionData!['transcript_path']},
                      {'label': 'Photo', 'path': _preinscriptionData!['photo_path']},
                      {'label': 'Lettre de recommandation', 'path': _preinscriptionData!['recommendation_letter_path']},
                      {'label': 'Lettre de motivation', 'path': _preinscriptionData!['motivation_letter_path']},
                      {'label': 'Certificat médical', 'path': _preinscriptionData!['medical_certificate_path']},
                    ]),
                  ],
                ),

                const SizedBox(height: 20),

                // Informations système
                _buildSectionCard(
                  title: 'INFORMATIONS SYSTÈME',
                  icon: Icons.info,
                  color: Colors.grey,
                  children: [
                    _buildInfoGrid([
                      {'label': 'Date de soumission', 'value': _formatDateTime(_preinscriptionData!['submission_date'])},
                      {'label': 'Dernière mise à jour', 'value': _formatDateTime(_preinscriptionData!['last_updated'])},
                      {'label': 'Adresse IP', 'value': _preinscriptionData!['ip_address']},
                    ]),
                    if (_preinscriptionData!['user_agent'] != null)
                      _buildFullWidthInfo('Navigateur', _preinscriptionData!['user_agent']),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<Map<String, String?>> data) {
    return Column(
      children: [
        for (int i = 0; i < data.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    data[i]['label']!,
                    data[i]['value'] ?? 'Non renseigné',
                  ),
                ),
                if (i + 1 < data.length) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      data[i + 1]['label']!,
                      data[i + 1]['value'] ?? 'Non renseigné',
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthInfo(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid(List<Map<String, String?>> documents) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final hasDocument = doc['path'] != null && doc['path']!.isNotEmpty;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasDocument ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasDocument ? Colors.green.shade200 : Colors.red.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasDocument ? Icons.check_circle : Icons.cancel,
                color: hasDocument ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: hasDocument ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LinearGradient _getStatusGradient(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        );
      case 'approved':
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        );
      case 'rejected':
        return LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        );
      case 'under_review':
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        );
      default:
        return LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade600],
        );
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Non renseigné';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatDateTime(String? date) {
    if (date == null || date.isEmpty) return 'Non renseigné';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Ma Fiche de Préinscription',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),
            _buildPreinscriptionCard(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
