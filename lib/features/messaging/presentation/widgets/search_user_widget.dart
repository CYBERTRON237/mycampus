import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../../domain/repositories/messaging_repository.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../constants/app_colors.dart';

class SearchUserWidget extends StatefulWidget {
  final Function(UserSearchResult) onUserSelected;

  const SearchUserWidget({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<SearchUserWidget> createState() => _SearchUserWidgetState();
}

class _SearchUserWidgetState extends State<SearchUserWidget> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<UserSearchResult> _users = [];
  String? _currentUserId;
  Timer? _searchTimer;
  String? _lastSearchQuery;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    final authUser = await _authService.getCurrentUser();
    _currentUserId = authUser?.id.toString();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _users = [];
        _lastSearchQuery = '';
      });
      return;
    }

    // Avoid redundant searches
    if (_lastSearchQuery == query && _users.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _lastSearchQuery = query;
    });

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) {
        throw Exception('User not authenticated');
      }

      // Utiliser une URL compatible avec le web
      const url = 'http://127.0.0.1/mycampus/api/messaging/users/search.php';
      
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {'q': query}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': currentUser!.id,
        },
      );

      print('Search users URL: $url?q=$query');
      print('Search users response status: ${response.statusCode}');
      print('Search users response body: ${response.body}');

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
      print('Error searching users: $e');
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
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Rechercher des utilisateurs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _users = [];
                          _lastSearchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              // Annuler le timer précédent
              _searchTimer?.cancel();
              
              // Démarrer un nouveau timer pour le debounce
              if (value.length >= 2 || value.isEmpty) {
                _searchTimer = Timer(const Duration(milliseconds: 500), () {
                  _searchUsers(value);
                });
              }
            },
            onSubmitted: _searchUsers,
          ),
        ),
        Flexible(
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
    final hasQuery = _searchController.text.trim().isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'Aucun utilisateur trouvé' : 'Rechercher des utilisateurs',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'Essayez avec d autres termes de recherche'
                : 'Tapez un nom pour trouver des utilisateurs à contacter',
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
    // Don't show current user in search results
    if (user.id == _currentUserId) {
      return const SizedBox.shrink();
    }

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
        return 'Enseignant';
      case 'student':
        return 'Étudiant';
      default:
        return role;
    }
  }
}
