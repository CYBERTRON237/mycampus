import 'lib/features/messaging/domain/models/message_model.dart';

void main() {
  final message = MessageModel(
    id: 'test',
    senderId: '1',
    receiverId: '2',
    content: 'test',
    createdAt: DateTime.now(),
  );
  print('Import works: ${message.content}');
}
