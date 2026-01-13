import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(TestPreinscriptionsDisplayApp());
}

class TestPreinscriptionsDisplayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Préinscriptions Display',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TestPreinscriptionsPage(),
    );
  }
}

class TestPreinscriptionsPage extends StatefulWidget {
  @override
  _TestPreinscriptionsPageState createState() => _TestPreinscriptionsPageState();
}

class _TestPreinscriptionsPageState extends State<TestPreinscriptionsPage> {
  List<dynamic> preinscriptions = [];
  bool isLoading = false;
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
        Uri.parse('http://127.0.0.1/mycampus/api/preinscriptions/preinscriptions?page=1&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': '1',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Affichage Préinscriptions'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPreinscriptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPreinscriptions,
        child: Column(
          children: [
            // Statistiques
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.purple.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', preinscriptions.length.toString(), Colors.blue),
                  _buildStatItem('En attente', preinscriptions.where((p) => p['status'] == 'pending').length.toString(), Colors.orange),
                  _buildStatItem('Acceptées', preinscriptions.where((p) => p['status'] == 'accepted').length.toString(), Colors.green),
                  _buildStatItem('Payées', preinscriptions.where((p) => p['payment_status'] == 'paid').length.toString(), Colors.teal),
                ],
              ),
            ),
            
            // Liste des préinscriptions
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(error!, style: TextStyle(color: Colors.red, fontSize: 16)),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadPreinscriptions,
                                child: Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : preinscriptions.isEmpty
                          ? Center(
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
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  elevation: 4,
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getStatusColor(preinscription['status']),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      '${preinscription['first_name'] ?? ''} ${preinscription['last_name'] ?? ''}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(preinscription['email'] ?? ''),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(preinscription['status']),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getStatusLabel(preinscription['status']),
                                                style: TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                preinscription['faculty'] ?? '',
                                                style: TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildDetailRow('Code unique', preinscription['unique_code']),
                                            _buildDetailRow('Téléphone', preinscription['phone_number']),
                                            _buildDetailRow('Adresse', preinscription['residence_address']),
                                            _buildDetailRow('Date de naissance', preinscription['date_of_birth']),
                                            _buildDetailRow('Lieu de naissance', preinscription['place_of_birth']),
                                            _buildDetailRow('Statut paiement', _getPaymentStatusLabel(preinscription['payment_status'])),
                                            if (preinscription['payment_amount'] != null)
                                              _buildDetailRow('Montant paiement', '${preinscription['payment_amount']} XAF'),
                                            _buildDetailRow('Date de soumission', preinscription['submission_date']),
                                            if (preinscription['desired_program'] != null)
                                              _buildDetailRow('Programme souhaité', preinscription['desired_program']),
                                            if (preinscription['study_level'] != null)
                                              _buildDetailRow('Niveau d\'étude', preinscription['study_level']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
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
        SizedBox(height: 8),
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
