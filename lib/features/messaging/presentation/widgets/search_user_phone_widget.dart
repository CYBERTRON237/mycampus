import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/repositories/messaging_repository.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../constants/app_colors.dart';

class SearchUserPhoneWidget extends StatefulWidget {
  final Function(UserSearchResult) onUserSelected;

  const SearchUserPhoneWidget({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<SearchUserPhoneWidget> createState() => _SearchUserPhoneWidgetState();
}

class _SearchUserPhoneWidgetState extends State<SearchUserPhoneWidget> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  List<UserSearchResult> _users = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchUsersByPhone(String phone) async {
    if (phone.trim().isEmpty) {
      setState(() {
        _users = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) {
        throw Exception('User not authenticated');
      }

      // Utiliser une URL compatible avec le web
      const url = 'http://127.0.0.1/mycampus/api/messaging/users/search/phone.php';
      
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {'phone': phone}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
      );

      print('Search users by phone URL: $url?phone=$phone');
      print('Search users by phone response status: ${response.statusCode}');
      print('Search users by phone response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> usersJson = data['data'];
          final users = usersJson.map((json) => UserSearchResult.fromJson(json)).toList();
          
          setState(() {
            _users = users;
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Search failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error searching users by phone: $e');
      setState(() {
        _users = [];
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de la recherche: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Numéro de téléphone...',
              prefixIcon: const Icon(Icons.phone),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _phoneController.clear();
                        setState(() {
                          _users = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              if (value.length >= 3 || value.isEmpty) {
                _searchUsersByPhone(value);
              }
            },
            onSubmitted: _searchUsersByPhone,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _users.isEmpty
                  ? _buildEmptyState()
                  : _buildUsersList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasQuery = _phoneController.text.trim().isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.phone_disabled : Icons.phone_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'Aucun utilisateur trouvé' : 'Rechercher par téléphone',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'Essayez avec un autre numéro de téléphone'
                : 'Entrez un numéro pour trouver des utilisateurs',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserItem(user);
      },
    );
  }

  Widget _buildUserItem(UserSearchResult user) {
    return ListTile(
      onTap: () {
        widget.onUserSelected(user);
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
        backgroundColor: _getRoleColor(user.role),
        child: user.avatar == null
            ? Text(
                user.name.isNotEmpty
                    ? user.name.split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.phone != null)
            Text(
              user.phone!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          Text(
            _getRoleDisplayName(user.role),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (user.institution != null)
            Text(
              user.institution!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
        ],
      ),
      trailing: Icon(
        Icons.message,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'teacher':
        return AppColors.primary;
      case 'student':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'teacher':
        return 'Professeur';
      case 'student':
        return 'Étudiant';
      default:
        return 'Utilisateur';
    }
  }
}
