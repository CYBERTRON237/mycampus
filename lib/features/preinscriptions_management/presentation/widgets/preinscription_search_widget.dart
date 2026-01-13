import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PreinscriptionSearchWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;

  const PreinscriptionSearchWidget({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<PreinscriptionSearchWidget> createState() => _PreinscriptionSearchWidgetState();
}

class _PreinscriptionSearchWidgetState extends State<PreinscriptionSearchWidget> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    
    if (kDebugMode) {
      print('🔎 [WIDGET DEBUG] PreinscriptionSearchWidget initState avec query: "${widget.searchQuery}"');
    }
    
    _controller.addListener(() {
      if (kDebugMode) {
        print('🔎 [WIDGET DEBUG] Search changé: "${_controller.text}"');
      }
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PreinscriptionSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔎 [WIDGET DEBUG] PreinscriptionSearchWidget build avec query: "${widget.searchQuery}"');
    }
    
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Rechercher par nom, email, code...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
