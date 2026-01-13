import 'package:flutter/material.dart';

class TypingIndicatorWidget extends StatelessWidget {
  final bool isTyping;
  final String? userName;

  const TypingIndicatorWidget({
    super.key,
    required this.isTyping,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTyping) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey[600]!,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${userName ?? 'Quelqu\'un'} est en train d\'écrire...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
