import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/sticker_model.dart';
import '../../services/sticker_service.dart';

class StickerPickerWidget extends StatefulWidget {
  final Function(StickerModel) onStickerSelected;
  final Function() onClose;

  const StickerPickerWidget({
    super.key,
    required this.onStickerSelected,
    required this.onClose,
  });

  @override
  State<StickerPickerWidget> createState() => _StickerPickerWidgetState();
}

class _StickerPickerWidgetState extends State<StickerPickerWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<StickerModel> _searchResults = [];
  bool _isSearching = false;
  late StickerService _stickerService;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _stickerService = StickerService();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    await _stickerService.loadStickers();
    if (mounted) {
      setState(() {
        _tabController = TabController(length: _stickerService.categories.length, vsync: this);
        _controllerInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    if (_controllerInitialized) {
      _tabController.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = _stickerService.searchStickers(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attendre que le TabController soit initialisé
    if (!_stickerService.isLoaded || !_controllerInitialized) {
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec recherche et fermeture
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Barre de recherche
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un sticker...',
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bouton fermer
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Aucun sticker trouvé',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final sticker = _searchResults[index];
          return _buildStickerItem(sticker);
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        // Tabs
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 2,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            tabs: _stickerService.categories.map((category) {
              return Tab(
                text: category.icon,
                height: 30,
              );
            }).toList(),
          ),
        ),
        
        // Contenu des tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _stickerService.categories.map((category) {
              return _buildStickerGrid(category.stickers);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStickerGrid(List<StickerModel> stickers) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: stickers.length,
        itemBuilder: (context, index) {
          final sticker = stickers[index];
          return _buildStickerItem(sticker);
        },
      ),
    );
  }

  Widget _buildStickerItem(StickerModel sticker) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onStickerSelected(sticker);
        widget.onClose();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: sticker.url.startsWith('assets')
              ? Image.asset(
                  sticker.url,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Text(
                          sticker.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                )
              : Image.network(
                  sticker.url,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Text(
                          sticker.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
