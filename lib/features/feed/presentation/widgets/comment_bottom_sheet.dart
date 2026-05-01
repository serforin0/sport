import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final Post post;

  const CommentBottomSheet({super.key, required this.post});

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    await ref.read(feedProvider.notifier).addComment(widget.post.id, text);
    _commentController.clear();

    if (mounted) {
      setState(() => _isSubmitting = false);
      // Scroll to bottom after new comment
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    // Watch the feed to get live comment updates
    final feedAsync = ref.watch(feedProvider);
    final livePost = feedAsync.valueOrNull?.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    ) ?? widget.post;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Color(0xFF0F2A5B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Text(
                  'Comentarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${livePost.comments.length}',
                    style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Comments list
          Expanded(
            child: livePost.comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.white12, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Sé el primero en comentar.',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: livePost.comments.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemBuilder: (context, index) {
                      final comment = livePost.comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: comment.author.photoUrl != null
                                  ? NetworkImage(comment.author.photoUrl!)
                                  : null,
                              backgroundColor: Colors.white12,
                              child: comment.author.photoUrl == null
                                  ? const Icon(Icons.person, size: 16, color: Colors.white38)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF506B99),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.author.name ?? 'Usuario',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatTime(comment.createdAt),
                                          style: const TextStyle(color: Colors.white24, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              top: 12,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF506B99),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Añadir un comentario...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    ),
                    onSubmitted: (_) => _submitComment(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  child: IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF19B5FF),
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
