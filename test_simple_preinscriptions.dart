import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SimplePreinscriptionsApp());
}

class SimplePreinscriptionsApp extends StatelessWidget {
  const SimplePreinscriptionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Simple Préinscriptions',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const SimplePreinscriptionsPage(),
    );
  }
}

class SimplePreinscriptionsPage extends StatefulWidget {
  const SimplePreinscriptionsPage({super.key});

  @override
  State<SimplePreinscriptionsPage> createState() => _SimplePreinscriptionsPageState();
}

class _SimplePreinscriptionsPageState extends State<SimplePreinscriptionsPage> {
  List<dynamic> preinscriptions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPreinscriptions();
  }

  Future<void> _loadPreinscriptions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=1&limit=5'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': '1',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body.substring(0, 500)}...');

      if (response.statusCode == 200) {
        // Extraire la première réponse JSON valide
        String responseBody = response.body;
        
        // Trouver la fin de la première réponse JSON
        int jsonEnd = responseBody.indexOf('{"success":false', 1);
        if (jsonEnd > 0) {
          responseBody = responseBody.substring(0, jsonEnd);
        }
        
        final Map<String, dynamic> data = json.decode(responseBody);
        if (data['success'] == true) {
          setState(() {
            preinscriptions = data['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Erreur inconnue';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Erreur HTTP: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        error = 'Erreur de connexion: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Simple Préinscriptions'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPreinscriptions,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPreinscriptions,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Statistiques
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.purple.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistiques',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Total', preinscriptions.length.toString(), Colors.blue),
                              _buildStatItem('En attente', preinscriptions.where((p) => p['status'] == 'pending').length.toString(), Colors.orange),
                              _buildStatItem('Payées', preinscriptions.where((p) => p['payment_status'] == 'paid').length.toString(), Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Liste
                    Expanded(
                      child: preinscriptions.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Aucune préinscription trouvée', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: preinscriptions.length,
                              itemBuilder: (context, index) {
                                final preinscription = preinscriptions[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getStatusColor(preinscription['status']),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      '${preinscription['first_name'] ?? ''} ${preinscription['last_name'] ?? ''}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(preinscription['email'] ?? ''),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(preinscription['status']),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getStatusLabel(preinscription['status']),
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                preinscription['faculty'] ?? '',
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      preinscription['unique_code'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      _showDetails(preinscription);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'deferred':
        return Colors.amber;
      case 'waitlisted':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En cours de révision';
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Rejeté';
      case 'cancelled':
        return 'Annulé';
      case 'deferred':
        return 'Différé';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return status ?? 'Inconnu';
    }
  }

  void _showDetails(Map<String, dynamic> preinscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${preinscription['first_name']} ${preinscription['last_name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Code unique', preinscription['unique_code']),
              _buildDetailRow('Email', preinscription['email']),
              _buildDetailRow('Téléphone', preinscription['phone_number']),
              _buildDetailRow('Faculté', preinscription['faculty']),
              _buildDetailRow('Statut', _getStatusLabel(preinscription['status'])),
              _buildDetailRow('Statut paiement', _getPaymentStatusLabel(preinscription['payment_status'])),
              if (preinscription['desired_program'] != null)
                _buildDetailRow('Programme', preinscription['desired_program']),
              if (preinscription['study_level'] != null)
                _buildDetailRow('Niveau', preinscription['study_level']),
              _buildDetailRow('Date de soumission', preinscription['submission_date']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  String _getPaymentStatusLabel(String? paymentStatus) {
    switch (paymentStatus) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'refunded':
        return 'Remboursé';
      case 'partial':
        return 'Partiel';
      default:
        return paymentStatus ?? 'Inconnu';
    }
  }
}
