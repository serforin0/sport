import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  /// Avatar del otro usuario (solo mensajes entrantes).
  final String? peerAvatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    this.peerAvatarUrl,
  });

  static final _timeFmt = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    final isMine = message.isSentByMe;
    final timeStr = _timeFmt.format(message.timestamp).replaceFirst(' ', '');
    final maxW = MediaQuery.sizeOf(context).width * 0.72;

    final bubble = Container(
      margin: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMine ? 56 : 0,
        right: isMine ? 16 : 0,
      ),
      constraints: BoxConstraints(maxWidth: maxW),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMine ? 18 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: isMine ? Colors.white : const Color(0xFF0F172A),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: TextStyle(
              color: isMine ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF64748B),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    if (isMine) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    }

    final showPeerAvatar =
        peerAvatarUrl != null && peerAvatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showPeerAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 6),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFCBD5E1),
                backgroundImage: NetworkImage(peerAvatarUrl!),
              ),
            )
          else
            const SizedBox(width: 4),
          bubble,
        ],
      ),
    );
  }
}
