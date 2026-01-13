import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/preinscription_model.dart';

class PreinscriptionFiltersWidget extends StatelessWidget {
  final String? selectedFaculty;
  final String? selectedStatus;
  final String? selectedPaymentStatus;
  final Function(String?) onFacultyChanged;
  final Function(String?) onStatusChanged;
  final Function(String?) onPaymentStatusChanged;
  final VoidCallback onClearFilters;

  const PreinscriptionFiltersWidget({
    Key? key,
    this.selectedFaculty,
    this.selectedStatus,
    this.selectedPaymentStatus,
    required this.onFacultyChanged,
    required this.onStatusChanged,
    required this.onPaymentStatusChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔍 [WIDGET DEBUG] PreinscriptionFiltersWidget build appelé - faculty: $selectedFaculty, status: $selectedStatus, payment: $selectedPaymentStatus');
    }
    
    final hasActiveFilters = selectedFaculty != null || 
                           selectedStatus != null || 
                           selectedPaymentStatus != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8.0),
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (hasActiveFilters)
                  TextButton(
                    onPressed: onClearFilters,
                    child: const Text('Effacer'),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            
            // Faculty filter
            _buildDropdownField(
              context: context,
              label: 'Faculté',
              value: selectedFaculty,
              items: const [
                'UY1',
                'FALSH',
                'FS',
                'FSE',
                'IUT',
                'ENSPY',
                'Faculté des Sciences',
                'Faculté des Lettres',
                'Faculté de Médecine',
              ],
              onChanged: onFacultyChanged,
            ),
            
            const SizedBox(height: 8.0),
            
            // Status filter
            _buildDropdownField(
              context: context,
              label: 'Statut',
              value: selectedStatus,
              items: PreinscriptionConstants.statuses,
              onChanged: onStatusChanged,
            ),
            
            const SizedBox(height: 8.0),
            
            // Payment status filter
            _buildDropdownField(
              context: context,
              label: 'Statut de paiement',
              value: selectedPaymentStatus,
              items: PreinscriptionConstants.paymentStatuses,
              onChanged: onPaymentStatusChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4.0),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Tous'),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(_formatDisplayValue(item)),
            )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _formatDisplayValue(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En révision';
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Rejeté';
      case 'cancelled':
        return 'Annulé';
      case 'deferred':
        return 'Reporté';
      case 'waitlisted':
        return 'Liste d\'attente';
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'refunded':
        return 'Remboursé';
      case 'partial':
        return 'Partiel';
      default:
        return value;
    }
  }
}
