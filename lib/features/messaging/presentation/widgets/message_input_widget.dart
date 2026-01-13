import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/sticker_model.dart';
import 'sticker_picker_widget.dart';
import '../../../../constants/app_colors.dart';

class MessageInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachmentTap;
  final Function(StickerModel)? onStickerSelected;
  final bool isDarkMode;
  final FocusNode? focusNode;

  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachmentTap,
    this.onStickerSelected,
    this.isDarkMode = false,
    this.focusNode,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool _isComposing = false;
  bool _showStickerPicker = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = widget.controller.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    if (_isComposing) {
      widget.onSend();
    }
  }

  void _onStickerSelected(StickerModel sticker) {
    if (widget.onStickerSelected != null) {
      widget.onStickerSelected!(sticker);
    }
  }

  void _toggleStickerPicker() {
    setState(() {
      _showStickerPicker = !_showStickerPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Sticker picker
            if (_showStickerPicker)
              StickerPickerWidget(
                onStickerSelected: _onStickerSelected,
                onClose: _toggleStickerPicker,
              ),
            
            // Input row
            Row(
              children: [
                IconButton(
                  onPressed: widget.onAttachmentTap,
                  icon: Icon(
                    Icons.attach_file,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: _toggleStickerPicker,
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: _showStickerPicker 
                        ? AppColors.primary 
                        : (widget.isDarkMode ? AppColors.textLight : Colors.grey[600]),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? AppColors.backgroundDark : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isComposing ? _handleSend : null,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isComposing 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: _isComposing ? Colors.white : Colors.grey[600],
                      size: 20,
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
}
