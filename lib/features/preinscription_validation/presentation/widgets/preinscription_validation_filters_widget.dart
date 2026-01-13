import 'package:flutter/material.dart';

class PreinscriptionValidationFiltersWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final String selectedFaculty;
  final Function(String) onFacultyChanged;
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final String selectedPaymentStatus;
  final Function(String) onPaymentStatusChanged;
  final Function() onClearFilters;

  const PreinscriptionValidationFiltersWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedFaculty,
    required this.onFacultyChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedPaymentStatus,
    required this.onPaymentStatusChanged,
    required this.onClearFilters,
  });

  @override
  State<PreinscriptionValidationFiltersWidget> createState() => _PreinscriptionValidationFiltersWidgetState();
}

class _PreinscriptionValidationFiltersWidgetState extends State<PreinscriptionValidationFiltersWidget> {
  final List<String> faculties = ['Toutes', 'UY1', 'FALSH', 'FS', 'FSE', 'IUT', 'ENSPY'];
  final List<String> statuses = ['Toutes', 'pending', 'under_review', 'accepted', 'rejected'];
  final List<String> paymentStatuses = ['Toutes', 'pending', 'paid', 'confirmed', 'refunded', 'partial'];
  
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Barre de recherche et bouton d'expansion
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, email, code...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: widget.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => widget.onSearchChanged(''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  tooltip: 'Filtres avancés',
                ),
                if (_hasActiveFilters()) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(Icons.filter_alt_off),
                    tooltip: 'Effacer les filtres',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
          
          // Filtres avancés
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? 120 : 0,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Filtre par faculté
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: widget.selectedFaculty,
                                onChanged: (value) {
                                  if (value != null) widget.onFacultyChanged(value);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Faculté',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: faculties.map((faculty) {
                                  return DropdownMenuItem(
                                    value: faculty,
                                    child: Text(_getFacultyDisplayName(faculty)),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Filtre par statut
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: widget.selectedStatus,
                                onChanged: (value) {
                                  if (value != null) widget.onStatusChanged(value);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Statut',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: statuses.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(_getStatusDisplayName(status)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            // Filtre par statut de paiement
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: widget.selectedPaymentStatus,
                                onChanged: (value) {
                                  if (value != null) widget.onPaymentStatusChanged(value);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Paiement',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: paymentStatuses.map((paymentStatus) {
                                  return DropdownMenuItem(
                                    value: paymentStatus,
                                    child: Text(_getPaymentStatusDisplayName(paymentStatus)),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Indicateurs de filtres actifs
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${_getActiveFiltersCount()} filtre(s) actif(s)',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.selectedFaculty != 'Toutes' ||
           widget.selectedStatus != 'Toutes' ||
           widget.selectedPaymentStatus != 'Toutes';
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (widget.selectedFaculty != 'Toutes') count++;
    if (widget.selectedStatus != 'Toutes') count++;
    if (widget.selectedPaymentStatus != 'Toutes') count++;
    return count;
  }

  String _getFacultyDisplayName(String faculty) {
    switch (faculty) {
      case 'Toutes':
        return 'Toutes les facultés';
      case 'UY1':
        return 'Université de Yaoundé 1';
      case 'FALSH':
        return 'FALSH';
      case 'FS':
        return 'Faculté des Sciences';
      case 'FSE':
        return 'Faculté des Sciences de l\'Éducation';
      case 'IUT':
        return 'Institut Universitaire de Technologie';
      case 'ENSPY':
        return 'École Nationale Supérieure Polytechnique';
      default:
        return faculty;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'Toutes':
        return 'Tous les statuts';
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En cours de révision';
      case 'accepted':
        return 'Acceptées';
      case 'rejected':
        return 'Rejetées';
      default:
        return status;
    }
  }

  String _getPaymentStatusDisplayName(String paymentStatus) {
    switch (paymentStatus) {
      case 'Toutes':
        return 'Tous les paiements';
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payés';
      case 'confirmed':
        return 'Confirmés';
      case 'refunded':
        return 'Remboursés';
      case 'partial':
        return 'Partiels';
      default:
        return paymentStatus;
    }
  }
}
