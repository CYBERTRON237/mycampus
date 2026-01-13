import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EnhancedImportWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>> data, String format) onImport;

  const EnhancedImportWidget({
    super.key,
    required this.onImport,
  });

  @override
  State<EnhancedImportWidget> createState() => _EnhancedImportWidgetState();
}

class _EnhancedImportWidgetState extends State<EnhancedImportWidget> {
  String? _selectedFilePath;
  String? _selectedFileName;
  String _selectedFormat = 'csv';
  bool _hasHeaders = true;
  bool _validateData = true;
  bool _skipExisting = false;
  bool _updateExisting = false;
  int _previewRows = 5;
  List<Map<String, dynamic>> _previewData = [];
  List<String> _availableColumns = [];
  Map<String, String?> _columnMapping = {};
  bool _isLoading = false;
  bool _isPreviewing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.upload,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Importer des étudiants',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File selection
                    _buildSectionHeader('Sélection du fichier'),
                    _buildFileSelectionSection(),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Import options
                    _buildSectionHeader('Options d\'import'),
                    _buildImportOptionsSection(),
                    
                    if (_previewData.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      
                      // Column mapping
                      _buildSectionHeader('Mappage des colonnes'),
                      _buildColumnMappingSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Preview
                      _buildSectionHeader('Aperçu des données'),
                      _buildPreviewSection(),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Instructions
                    _buildSectionHeader('Instructions'),
                    _buildInstructionsSection(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_selectedFilePath == null || _isLoading) ? null : _handleImport,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_isLoading ? 'Importation...' : 'Importer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelectionSection() {
    return Column(
      children: [
        // File picker
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
              const SizedBox(height: 16),
              
              if (_selectedFileName != null) ...[
                Text(
                  _selectedFileName!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilePath!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Choisir un autre fichier'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isPreviewing ? null : _previewFile,
                        icon: const Icon(Icons.preview),
                        label: Text(_isPreviewing ? 'Analyse...' : 'Aperçu'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Sélectionnez un fichier à importer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Formats supportés: CSV, Excel (.xlsx, .xls)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choisir un fichier'),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Format selection
        DropdownButtonFormField<String>(
          value: _selectedFormat,
          decoration: const InputDecoration(
            labelText: 'Format du fichier',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'csv', child: Text('CSV')),
            DropdownMenuItem(value: 'excel', child: Text('Excel')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedFormat = value!;
              _previewData.clear();
              _availableColumns.clear();
              _columnMapping.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildImportOptionsSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Le fichier contient des en-têtes'),
          subtitle: const Text('La première ligne contient les noms des colonnes'),
          value: _hasHeaders,
          onChanged: (value) {
            setState(() {
              _hasHeaders = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Valider les données'),
          subtitle: const Text('Vérifier la validité des données avant import'),
          value: _validateData,
          onChanged: (value) {
            setState(() {
              _validateData = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Ignorer les étudiants existants'),
          subtitle: const Text('Ne pas importer si le matricule existe déjà'),
          value: _skipExisting,
          onChanged: (value) {
            setState(() {
              _skipExisting = value ?? false;
              if (value == true) _updateExisting = false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Mettre à jour les étudiants existants'),
          subtitle: const Text('Mettre à jour les données si le matricule existe'),
          value: _updateExisting,
          onChanged: (value) {
            setState(() {
              _updateExisting = value ?? false;
              if (value == true) _skipExisting = false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        const SizedBox(height: 16),
        
        // Preview rows
        Row(
          children: [
            Expanded(
              child: Text(
                'Nombre de lignes d\'aperçu: $_previewRows',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Slider(
              value: _previewRows.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _previewRows = value.round();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnMappingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mappez les colonnes du fichier aux champs de la base de données',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          ..._availableColumns.map((column) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DropdownButtonFormField<String>(
                value: _columnMapping[column],
                decoration: InputDecoration(
                  labelText: column,
                  border: const OutlineInputBorder(),
                  helperText: 'Colonne: "$column"',
                ),
                items: _getAvailableFields().map((field) {
                  return DropdownMenuItem<String>(
                    value: field,
                    child: Text(field),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _columnMapping[column] = value;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Aperçu des données (${_previewData.length} lignes)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_previewData.isNotEmpty)
                TextButton(
                  onPressed: _previewFile,
                  child: const Text('Rafraîchir'),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_previewData.isEmpty)
            Text(
              'Aucune donnée à afficher. Sélectionnez un fichier et cliquez sur "Aperçu".',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _availableColumns.map((column) {
                  return DataColumn(
                    label: Text(
                      column,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                rows: _previewData.take(_previewRows).map((row) {
                  return DataRow(
                    cells: _availableColumns.map((column) {
                      return DataCell(
                        Text(row[column]?.toString() ?? ''),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...[
            'Le fichier doit contenir les colonnes de base: matricule, nom, prénom, email',
            'Les colonnes optionnelles incluent: téléphone, date_de_naissance, niveau, statut',
            'Le matricule doit être unique pour chaque étudiant',
            'Les dates doivent être au format JJ/MM/AAAA ou AAAA-MM-JJ',
            'Les valeurs vides seront ignorées lors de l\'importation',
            'Vérifiez l\'aperçu avant de lancer l\'importation',
          ].map((instruction) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instruction,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _selectedFormat == 'csv' 
            ? ['csv'] 
            : ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          _previewData.clear();
          _availableColumns.clear();
          _columnMapping.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection du fichier: ${e.toString()}';
      });
    }
  }

  Future<void> _previewFile() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isPreviewing = true;
      _errorMessage = null;
    });

    try {
      // Simulate file reading and preview generation
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock preview data
      final mockData = [
        {'matricule': '2024001', 'nom': 'Dupont', 'prénom': 'Jean', 'email': 'jean.dupont@email.com'},
        {'matricule': '2024002', 'nom': 'Martin', 'prénom': 'Marie', 'email': 'marie.martin@email.com'},
        {'matricule': '2024003', 'nom': 'Bernard', 'prénom': 'Pierre', 'email': 'pierre.bernard@email.com'},
        {'matricule': '2024004', 'nom': 'Thomas', 'prénom': 'Sophie', 'email': 'sophie.thomas@email.com'},
        {'matricule': '2024005', 'nom': 'Robert', 'prénom': 'Luc', 'email': 'luc.robert@email.com'},
      ];

      final columns = mockData.first.keys.toList();

      setState(() {
        _previewData = mockData;
        _availableColumns = columns;
        _columnMapping = Map.fromEntries(
          columns.map((col) => MapEntry(col, _mapColumnToField(col))),
        );
        _isPreviewing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la lecture du fichier: ${e.toString()}';
        _isPreviewing = false;
      });
    }
  }

  String _mapColumnToField(String column) {
    final mapping = {
      'matricule': 'matricule',
      'nom': 'lastName',
      'prénom': 'firstName',
      'prenom': 'firstName',
      'email': 'email',
      'téléphone': 'phone',
      'telephone': 'phone',
      'date_de_naissance': 'dateOfBirth',
      'date de naissance': 'dateOfBirth',
      'niveau': 'currentLevel',
      'statut': 'status',
    };
    
    return mapping[column.toLowerCase()] ?? column;
  }

  List<String> _getAvailableFields() {
    return [
      'matricule',
      'lastName',
      'firstName',
      'middleName',
      'email',
      'phone',
      'alternativePhone',
      'dateOfBirth',
      'placeOfBirth',
      'gender',
      'nationality',
      'address',
      'city',
      'region',
      'country',
      'postalCode',
      'currentLevel',
      'status',
      'gpa',
      'totalCreditsEarned',
      'scholarshipStatus',
      'bloodGroup',
      'medicalConditions',
      'allergies',
      'languages',
      'hobbies',
      'skills',
      'bio',
    ];
  }

  void _handleImport() {
    if (_previewData.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez d\'abord prévisualiser les données';
      });
      return;
    }

    setState(() => _isLoading = true);

    // Apply column mapping and prepare data
    final processedData = _previewData.map((row) {
      final mappedRow = <String, dynamic>{};
      _columnMapping.forEach((sourceColumn, targetField) {
        if (targetField != null && row.containsKey(sourceColumn)) {
          mappedRow[targetField] = row[sourceColumn];
        }
      });
      return mappedRow;
    }).toList();

    widget.onImport(processedData, _selectedFormat);

    // Simulate import completion
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${processedData.length} étudiants importés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
