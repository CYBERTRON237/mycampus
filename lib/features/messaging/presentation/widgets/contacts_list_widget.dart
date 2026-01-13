import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/contact_model.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../constants/app_colors.dart';

class ContactsListWidget extends StatefulWidget {
  final Function(ContactModel) onContactTap;
  final Function(ContactModel)? onContactLongPress;
  final bool showFavorites;
  final String? searchQuery;

  const ContactsListWidget({
    super.key,
    required this.onContactTap,
    this.onContactLongPress,
    this.showFavorites = true,
    this.searchQuery,
  });

  @override
  State<ContactsListWidget> createState() => _ContactsListWidgetState();
}

class _ContactsListWidgetState extends State<ContactsListWidget>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<ContactModel> _contacts = [];
  List<ContactModel> _filteredContacts = [];
  late AnimationController _fadeAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadContacts();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController.forward();
  }

  Future<void> _loadContacts() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) {
        throw Exception('User not authenticated');
      }

      const url = 'http://127.0.0.1/mycampus/api/messaging/contacts/get_contacts.php';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
      );

      print('Get contacts URL: $url');
      print('Get contacts response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> contactsJson = data['data'];
          final contacts = contactsJson.map((json) => ContactModel.fromJson(json)).toList();
          
          setState(() {
            _contacts = contacts;
            _filteredContacts = contacts;
            _isLoading = false;
          });
          _applyFilter();
        } else {
          throw Exception(data['message'] ?? 'Failed to load contacts');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() {
        _contacts = [];
        _filteredContacts = [];
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement des contacts: $e');
    }
  }

  void _applyFilter() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      _filteredContacts = widget.showFavorites 
          ? _contacts.where((c) => c.isFavorite).toList()
          : _contacts;
    } else {
      final query = widget.searchQuery!.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        return contact.fullName.toLowerCase().contains(query) ||
            (contact.phone?.contains(query) ?? false);
      }).toList();
      
      if (widget.showFavorites) {
        _filteredContacts = _filteredContacts.where((c) => c.isFavorite).toList();
      }
    }
  }

  Future<void> _toggleFavorite(ContactModel contact) async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) return;

      const url = 'http://127.0.0.1/mycampus/api/messaging/contacts/toggle_favorite.php';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
        body: json.encode({
          'contact_id': contact.contactUserId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            final index = _contacts.indexWhere((c) => c.contactUserId == contact.contactUserId);
            if (index != -1) {
              _contacts[index] = contact.copyWith(isFavorite: data['is_favorite']);
            }
          });
          _applyFilter();
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _deleteContact(ContactModel contact) async {
    final confirmed = await _showDeleteConfirmation(contact);
    if (!confirmed) return;

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) return;

      const url = 'http://127.0.0.1/mycampus/api/messaging/contacts/delete_contact.php';
      
      final response = await http.delete(
        Uri.parse('$url?contact_id=${contact.contactUserId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _contacts.removeWhere((c) => c.contactUserId == contact.contactUserId);
          });
          _applyFilter();
          _showSuccessSnackBar('Contact supprimé avec succès');
        }
      }
    } catch (e) {
      print('Error deleting contact: $e');
      _showErrorSnackBar('Erreur lors de la suppression: $e');
    }
  }

  Future<bool> _showDeleteConfirmation(ContactModel contact) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 12),
            Text('Supprimer le contact'),
          ],
        ),
        content: Text('Voulez-vous vraiment supprimer ${contact.fullName} de vos contacts ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(ContactsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery || 
        oldWidget.showFavorites != widget.showFavorites) {
      _applyFilter();
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des contacts...',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimationController,
      child: ListView.separated(
        itemCount: _filteredContacts.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
          indent: 80,
        ),
        itemBuilder: (context, index) {
          final contact = _filteredContacts[index];
          return _buildContactTile(contact);
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
            widget.showFavorites ? Icons.star_border : Icons.contacts_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.showFavorites ? 'Aucun contact favori' : 'Aucun contact',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.showFavorites 
                ? 'Ajoutez des contacts en favoris pour les voir ici'
                : 'Ajoutez des contacts pour commencer à discuter',
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

  Widget _buildContactTile(ContactModel contact) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onContactTap(contact),
        onLongPress: () => widget.onContactLongPress?.call(contact),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
                    child: contact.avatar == null
                        ? Text(
                            contact.initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  if (contact.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.isFavorite)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.role == 'student' ? 'Étudiant' : 
                      contact.role == 'teacher' ? 'Enseignant' : 
                      contact.role == 'admin' ? 'Administrateur' : contact.role,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  switch (value) {
                    case 'favorite':
                      _toggleFavorite(contact);
                      break;
                    case 'delete':
                      _deleteContact(contact);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'favorite',
                    child: Row(
                      children: [
                        Icon(
                          contact.isFavorite ? Icons.star_border : Icons.star,
                          color: contact.isFavorite ? Colors.grey : Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        Text(contact.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('Supprimer le contact'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
