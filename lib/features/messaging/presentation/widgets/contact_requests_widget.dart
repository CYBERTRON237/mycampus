import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/contact_model.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../constants/app_colors.dart';

class ContactRequestsWidget extends StatefulWidget {
  final VoidCallback? onRequestProcessed;

  const ContactRequestsWidget({
    super.key,
    this.onRequestProcessed,
  });

  @override
  State<ContactRequestsWidget> createState() => _ContactRequestsWidgetState();
}

class _ContactRequestsWidgetState extends State<ContactRequestsWidget>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<ContactRequestModel> _requests = [];
  late AnimationController _slideAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRequests();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimationController.forward();
  }

  Future<void> _loadRequests() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) {
        throw Exception('User not authenticated');
      }

      const url = 'http://127.0.0.1/mycampus/api/messaging/contacts/get_requests.php';
      
      final response = await http.get(
        Uri.parse('$url?type=received'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
      );

      print('Get contact requests URL: $url?type=received');
      print('Get contact requests response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> requestsJson = data['data'];
          final requests = requestsJson.map((json) => _parseContactRequest(json)).toList();
          
          setState(() {
            _requests = requests;
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load requests');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error loading contact requests: $e');
      setState(() {
        _requests = [];
        _isLoading = false;
      });
    }
  }

  ContactRequestModel _parseContactRequest(Map<String, dynamic> json) {
    return ContactRequestModel(
      id: json['id']?.toString() ?? '',
      requesterId: json['contact_user_id']?.toString() ?? '',
      recipientId: AuthService().currentUser?.id ?? '',
      requesterFirstName: json['first_name']?.toString() ?? '',
      requesterLastName: json['last_name']?.toString() ?? '',
      requesterAvatar: json['profile_photo_url']?.toString() ?? json['profile_picture']?.toString(),
      message: json['message']?.toString(),
      status: ContactRequestStatus.pending,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Future<void> _respondToRequest(ContactRequestModel request, bool accept) async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) return;

      const url = 'http://127.0.0.1/mycampus/api/messaging/contacts/respond_request.php';
      
      final response = await http.post(
        Uri.parse('$url?id=${request.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
        body: json.encode({
          'action': accept ? 'accept' : 'reject',
        }),
      );

      print('Respond to request URL: $url?id=${request.id}');
      print('Respond to request action: ${accept ? 'accept' : 'reject'}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _requests.removeWhere((r) => r.id == request.id);
          });
          widget.onRequestProcessed?.call();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    accept ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      accept ? 'Demande acceptée' : 'Demande refusée',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: accept ? AppColors.primary : AppColors.error,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error responding to request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erreur lors du traitement de la demande',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des demandes...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOut,
      )),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestTile(request);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune demande de contact',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les nouvelles demandes apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(ContactRequestModel request) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: request.requesterAvatar != null ? NetworkImage(request.requesterAvatar!) : null,
                  child: request.requesterAvatar == null
                      ? Text(
                          _getInitials(request.requesterFullName),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterFullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'veut ajouter ce contact',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  request.message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respondToRequest(request, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Refuser',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToRequest(request, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Accepter',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
