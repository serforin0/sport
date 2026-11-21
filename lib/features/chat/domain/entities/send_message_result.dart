import 'chat_message.dart';

class SendMessageResult {
  final ChatMessage message;
  final String? scamWarning;

  const SendMessageResult({
    required this.message,
    this.scamWarning,
  });
}
