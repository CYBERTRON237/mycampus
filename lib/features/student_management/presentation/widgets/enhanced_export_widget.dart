import 'package:flutter/material.dart';

class EnhancedExportWidget extends StatefulWidget {
  final bool selectedOnly;
  final Function(String format, Map<String, dynamic> filters) onExport;

  const EnhancedExportWidget({
    super.key,
    this.selectedOnly = false,
    required this.onExport,
  });

  @override
  State<EnhancedExportWidget> createState() => _EnhancedExportWidgetState();
}

class _EnhancedExportWidgetState extends State<EnhancedExportWidget> {
  String _selectedFormat = 'csv';
  bool _includeHeaders = true;
  bool _includePhotos = false;
  bool _includeMedicalInfo = false;
  bool _includeFinancialInfo = false;
  bool _includeAcademicRecords = false;
  String _dateRange = 'all';
  String _statusFilter = 'all';
  String _levelFilter = 'all';
  bool _isExporting = false;

  final List<String> _formats = [
    'csv',
    'excel',
    'pdf',
    'json',
  ];

  final List<String> _dateRanges = [
    'all',
    'today',
    'week',
    'month',
    'quarter',
    'year',
    'custom',
  ];

  final List<String> _statusFilters = [
    'all',
    'active',
    'inactive',
    'graduated',
    'suspended',
    'enrolled',
  ];

  final List<String> _levelFilters = [
    'all',
    'licence',
    'master',
    'doctorat',
    'bts',
    'ingenieur',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
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
                  Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Exporter les étudiants${widget.selectedOnly ? ' sélectionnés' : ''}',
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
                    // Format selection
                    _buildSectionHeader('Format d\'export'),
                    _buildFormatSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Data options
                    _buildSectionHeader('Options de données'),
                    _buildDataOptionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Filters
                    _buildSectionHeader('Filtres d\'export'),
                    _buildFiltersSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Preview
                    _buildSectionHeader('Aperçu'),
                    _buildPreviewSection(),
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
                    onPressed: _isExporting ? null : _handleExport,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isExporting ? 'Exportation...' : 'Exporter'),
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

  Widget _buildFormatSection() {
    return Column(
      children: [
        // Format selection
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFormat,
                decoration: const InputDecoration(
                  labelText: 'Format',
                  border: OutlineInputBorder(),
                ),
                items: _formats.map((format) {
                  return DropdownMenuItem<String>(
                    value: format,
                    child: Row(
                      children: [
                        Icon(_getFormatIcon(format)),
                        const SizedBox(width: 8),
                        Text(_getFormatLabel(format)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFormatDescription(_selectedFormat),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Format-specific options
        if (_selectedFormat == 'csv' || _selectedFormat == 'excel')
          CheckboxListTile(
            title: const Text('Inclure les en-têtes de colonnes'),
            subtitle: const Text('Ajouter une ligne d\'en-têtes au début du fichier'),
            value: _includeHeaders,
            onChanged: (value) {
              setState(() {
                _includeHeaders = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        
        if (_selectedFormat == 'pdf')
          CheckboxListTile(
            title: const Text('Inclure les photos des étudiants'),
            subtitle: const Text('Ajouter les photos de profil dans le PDF'),
            value: _includePhotos,
            onChanged: (value) {
              setState(() {
                _includePhotos = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildDataOptionsSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Informations de base'),
          subtitle: const Text('Nom, prénom, matricule, email, téléphone'),
          value: true, // Always included
          onChanged: null, // Cannot be unchecked
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Informations académiques'),
          subtitle: const Text('Niveau, GPA, crédits, inscription'),
          value: _includeAcademicRecords,
          onChanged: (value) {
            setState(() {
              _includeAcademicRecords = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Informations médicales'),
          subtitle: const Text('Groupe sanguin, allergies, conditions médicales'),
          value: _includeMedicalInfo,
          onChanged: (value) {
            setState(() {
              _includeMedicalInfo = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        
        CheckboxListTile(
          title: const Text('Informations financières'),
          subtitle: const Text('Bourses, frais de scolarité, statut de paiement'),
          value: _includeFinancialInfo,
          onChanged: (value) {
            setState(() {
              _includeFinancialInfo = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _dateRange,
                decoration: const InputDecoration(
                  labelText: 'Période',
                  border: OutlineInputBorder(),
                ),
                items: _dateRanges.map((range) {
                  return DropdownMenuItem<String>(
                    value: range,
                    child: Text(_getDateRangeLabel(range)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _dateRange = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _statusFilter,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: _statusFilters.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(_getStatusFilterLabel(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value!;
                  });
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _levelFilter,
          decoration: const InputDecoration(
            labelText: 'Niveau académique',
            border: OutlineInputBorder(),
          ),
          items: _levelFilters.map((level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text(_getLevelFilterLabel(level)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _levelFilter = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Résumé de l\'export',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildPreviewItem('Format', _getFormatLabel(_selectedFormat)),
          _buildPreviewItem('Période', _getDateRangeLabel(_dateRange)),
          _buildPreviewItem('Statut', _getStatusFilterLabel(_statusFilter)),
          _buildPreviewItem('Niveau', _getLevelFilterLabel(_levelFilter)),
          _buildPreviewItem('En-têtes', _includeHeaders ? 'Oui' : 'Non'),
          _buildPreviewItem('Photos', _includePhotos ? 'Oui' : 'Non'),
          _buildPreviewItem('Info médicales', _includeMedicalInfo ? 'Oui' : 'Non'),
          _buildPreviewItem('Info financières', _includeFinancialInfo ? 'Oui' : 'Non'),
          _buildPreviewItem('Info académiques', _includeAcademicRecords ? 'Oui' : 'Non'),
          
          if (widget.selectedOnly)
            _buildPreviewItem('Type', 'Sélection uniquement'),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _handleExport() {
    setState(() => _isExporting = true);

    final filters = {
      'format': _selectedFormat,
      'includeHeaders': _includeHeaders,
      'includePhotos': _includePhotos,
      'includeMedicalInfo': _includeMedicalInfo,
      'includeFinancialInfo': _includeFinancialInfo,
      'includeAcademicRecords': _includeAcademicRecords,
      'dateRange': _dateRange,
      'statusFilter': _statusFilter,
      'levelFilter': _levelFilter,
      'selectedOnly': widget.selectedOnly,
    };

    widget.onExport(_selectedFormat, filters);

    // Simulate export completion
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportation réussie'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'csv':
        return Icons.table_chart;
      case 'excel':
        return Icons.grid_on;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'json':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFormatLabel(String format) {
    switch (format) {
      case 'csv':
        return 'CSV';
      case 'excel':
        return 'Excel';
      case 'pdf':
        return 'PDF';
      case 'json':
        return 'JSON';
      default:
        return format.toUpperCase();
    }
  }

  String _getFormatDescription(String format) {
    switch (format) {
      case 'csv':
        return 'Format de valeurs séparées par des virgules, compatible avec Excel';
      case 'excel':
        return 'Format Excel natif avec mise en forme et formules';
      case 'pdf':
        return 'Format de document portable avec mise en page professionnelle';
      case 'json':
        return 'Format de données structuré pour les développeurs';
      default:
        return '';
    }
  }

  String _getDateRangeLabel(String range) {
    switch (range) {
      case 'all':
        return 'Toutes les dates';
      case 'today':
        return "Aujourd'hui";
      case 'week':
        return 'Cette semaine';
      case 'month':
        return 'Ce mois';
      case 'quarter':
        return 'Ce trimestre';
      case 'year':
        return 'Cette année';
      case 'custom':
        return 'Personnalisé';
      default:
        return range;
    }
  }

  String _getStatusFilterLabel(String status) {
    switch (status) {
      case 'all':
        return 'Tous les statuts';
      case 'active':
        return 'Actifs';
      case 'inactive':
        return 'Inactifs';
      case 'graduated':
        return 'Diplômés';
      case 'suspended':
        return 'Suspendus';
      case 'enrolled':
        return 'Inscrits';
      default:
        return status;
    }
  }

  String _getLevelFilterLabel(String level) {
    switch (level) {
      case 'all':
        return 'Tous les niveaux';
      case 'licence':
        return 'Licence';
      case 'master':
        return 'Master';
      case 'doctorat':
        return 'Doctorat';
      case 'bts':
        return 'BTS';
      case 'ingenieur':
        return 'Ingénieur';
      default:
        return level;
    }
  }
}
