import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../domain/models/contact_model.dart';
import '../../../auth/services/auth_service.dart';

class UserProfilePage extends StatefulWidget {
  final ContactModel contact;

  const UserProfilePage({
    super.key,
    required this.contact,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  ContactModel? _fullContact;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFullContactInfo();
  }

  Future<void> _loadFullContactInfo() async {
    // Si le contact vient d'une conversation (email vide), on charge les infos complètes
    if (widget.contact.email.isEmpty) {
      setState(() => _isLoading = true);
      
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser?.id == null) return;

        const url = 'http://127.0.0.1/mycampus/api/messaging/contacts/get_contact_info.php';
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-User-Id': currentUser!.id,
            'X-Contact-User-Id': widget.contact.contactUserId,
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['success'] == true) {
            final contactData = data['data'];
            setState(() {
              _fullContact = ContactModel.fromJson(contactData);
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        print('Error loading full contact info: $e');
      }
      
      setState(() => _isLoading = false);
    } else {
      // Si on a déjà les infos complètes (venant des contacts)
      setState(() => _fullContact = widget.contact);
    }
  }

  ContactModel get contact => _fullContact ?? widget.contact;

  @override
  Widget build(BuildContext context) {
    // Debug: afficher les informations du contact
    print('Contact: ${contact.firstName} ${contact.lastName}');
    print('Email: ${contact.email}');
    print('Phone: ${contact.phone}');
    print('Role: ${contact.role}');
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Profil',
          style: AppStyles.heading5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Menu options supplémentaires
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        : Column(
        children: [
          // Header avec photo et nom
          Container(
            color: AppColors.primary,
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: contact.avatar != null && contact.avatar!.isNotEmpty
                      ? NetworkImage(contact.avatar!)
                      : null,
                  child: contact.avatar == null || contact.avatar!.isEmpty
                      ? Text(
                          '${contact.firstName.isNotEmpty ? contact.firstName[0] : ''}${contact.lastName.isNotEmpty ? contact.lastName[0] : ''}'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  '${contact.firstName} ${contact.lastName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: contact.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contact.isOnline ? 'En ligne' : 'Hors ligne',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Actions rapides
          Container(
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    // Naviguer vers la conversation
                  },
                ),
                _buildActionButton(
                  icon: Icons.call,
                  label: 'Appel audio',
                  onTap: () {
                    _showComingSoon(context, 'Appel audio');
                  },
                ),
                _buildActionButton(
                  icon: Icons.videocam,
                  label: 'Appel vidéo',
                  onTap: () {
                    _showComingSoon(context, 'Appel vidéo');
                  },
                ),
                _buildActionButton(
                  icon: contact.isFavorite ? Icons.star : Icons.star_border,
                  label: contact.isFavorite ? 'Favori' : 'Ajouter',
                  onTap: () {
                    // Toggle favorite
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Informations détaillées
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  _buildInfoSection(
                    title: 'Informations de contact',
                    children: [
                      _buildInfoItem(
                        icon: Icons.phone,
                        label: 'Téléphone',
                        value: contact.phone ?? 'Non renseigné',
                        onTap: contact.phone != null && contact.phone!.isNotEmpty ? () {
                          // Appeler
                        } : null,
                      ),
                      _buildInfoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: contact.email.isNotEmpty ? contact.email : 'Non renseigné',
                        onTap: contact.email.isNotEmpty ? () {
                          // Envoyer email
                        } : null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildInfoSection(
                    title: 'Informations académiques',
                    children: [
                      _buildInfoItem(
                        icon: Icons.school,
                        label: 'Rôle',
                        value: _getRoleDisplayName(contact.role),
                      ),
                      _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Contact ajouté',
                        value: _formatDate(contact.createdAt),
                      ),
                      _buildInfoItem(
                        icon: Icons.info_outline,
                        label: 'ID Utilisateur',
                        value: contact.contactUserId,
                      ),
                      _buildInfoItem(
                        icon: Icons.circle,
                        label: 'Statut',
                        value: _getStatusDisplayName(contact.status),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Étudiant';
      case 'teacher':
        return 'Enseignant';
      case 'admin':
        return 'Administrateur';
      case 'staff':
        return 'Personnel';
      default:
        return role;
    }
  }

  String _getStatusDisplayName(ContactStatus status) {
    switch (status) {
      case ContactStatus.accepted:
        return 'Accepté';
      case ContactStatus.pending:
        return 'En attente';
      case ContactStatus.rejected:
        return 'Refusé';
      case ContactStatus.blocked:
        return 'Bloqué';
      case ContactStatus.cancelled:
        return 'Annulé';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              feature,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Cette fonctionnalité sera bientôt disponible.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
