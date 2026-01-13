import 'package:flutter/material.dart';
import 'package:mycampus/features/messaging/presentation/widgets/conversation_list_widget.dart';
import 'package:mycampus/features/messaging/presentation/widgets/search_user_widget.dart';
import 'package:mycampus/features/messaging/presentation/pages/conversation_page.dart';
import 'package:mycampus/features/messaging/domain/models/message_model.dart';
import 'package:mycampus/constants/app_colors.dart';

class MyCampusMessengerPage extends StatefulWidget {
  const MyCampusMessengerPage({super.key});

  @override
  State<MyCampusMessengerPage> createState() => _MyCampusMessengerPageState();
}

class _MyCampusMessengerPageState extends State<MyCampusMessengerPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _selectedUserId;
  String? _selectedUserName;
  String? _selectedUserAvatar;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectConversation(String userId, String userName, String? userAvatar) {
    setState(() {
      _selectedUserId = userId;
      _selectedUserName = userName;
      _selectedUserAvatar = userAvatar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Couleur de l'application
      body: Row(
        children: [
          // Left panel - Conversations list
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              border: Border(
                right: BorderSide(color: AppColors.primary, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    border: Border(
                      bottom: BorderSide(color: AppColors.primary, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'MyCampus',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white, size: 22),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Search bar (when searching)
                if (_isSearching)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      border: Border(
                        bottom: BorderSide(color: AppColors.primary, width: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Rechercher des contacts ou conversations...',
                        hintStyle: const TextStyle(color: Color(0xFF8F9492)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF8F9492)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                // Tabs
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    border: Border(
                      bottom: BorderSide(color: AppColors.primary, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.accent, width: 3),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'MESSAGES',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text(
                              'ACTIVITÉ',
                              style: TextStyle(
                                color: Color(0xFF8F9492),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text(
                              'CONTACTS',
                              style: TextStyle(
                                color: Color(0xFF8F9492),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Conversations list or search results
                Expanded(
                  child: _isSearching && _searchController.text.isNotEmpty
                      ? SearchUserWidget(
                          onUserSelected: (user) {
                            _selectConversation(user.id, user.name, user.avatar);
                          },
                        )
                      : ConversationListWidget(
                          onConversationSelected: (conversation) {
                            _selectConversation(
                              conversation.participantId,
                              conversation.participantName,
                              conversation.participantAvatar,
                            );
                          },
                          selectedConversationId: _selectedUserId,
                        ),
                ),
              ],
            ),
          ),

          // Right panel - Active conversation
          Expanded(
            child: _selectedUserId != null
                ? ConversationPage(
                    userId: _selectedUserId!,
                    userName: _selectedUserName ?? 'Utilisateur',
                    userAvatar: _selectedUserAvatar,
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // MyCampus light background
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[50]!,
                          Colors.grey[100]!,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Messagerie MyCampus',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choisissez une conversation pour commencer',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
