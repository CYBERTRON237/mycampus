import 'package:flutter/material.dart';

class ValidationActionsWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onValidateAll;
  final VoidCallback onRejectAll;
  final VoidCallback onScheduleInterview;
  final VoidCallback onExport;

  const ValidationActionsWidget({
    Key? key,
    required this.selectedCount,
    required this.onValidateAll,
    required this.onRejectAll,
    required this.onScheduleInterview,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions pour $selectedCount préinscription(s)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Validate all
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Valider tout'),
            subtitle: const Text('Accepter toutes les préinscriptions sélectionnées'),
            onTap: onValidateAll,
          ),
          
          const Divider(),
          
          // Reject all
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Rejeter tout'),
            subtitle: const Text('Rejeter toutes les préinscriptions sélectionnées'),
            onTap: onRejectAll,
          ),
          
          const Divider(),
          
          // Schedule interviews
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: const Text('Planifier des entretiens'),
            subtitle: const Text('Organiser des entretiens pour les candidats'),
            onTap: onScheduleInterview,
          ),
          
          const Divider(),
          
          // Export
          ListTile(
            leading: const Icon(Icons.download, color: Colors.orange),
            title: const Text('Exporter'),
            subtitle: const Text('Exporter les données au format CSV/Excel'),
            onTap: onExport,
          ),
          
          const SizedBox(height: 16),
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }
}
