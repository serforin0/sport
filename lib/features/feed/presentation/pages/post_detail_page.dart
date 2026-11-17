import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/core/widgets/skeleton_base.dart';
import 'dart:io';

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  final _commentFocusNode = FocusNode();
  bool _isLiked = false;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likes.contains('current_user'); // Simplified for now
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    setState(() => _isLiked = !_isLiked);
    await ref.read(feedProvider.notifier).likePost(widget.post.id);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);
    await ref.read(feedProvider.notifier).addComment(widget.post.id, text);

    if (mounted) {
      _commentController.clear();
      setState(() => _isSubmittingComment = false);
      // Optional: Scroll to bottom
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays} días';
  }

  String _authorDetailLine(Post post) {
    final author = post.author;
    final parts = [
      author.profileType,
      author.position,
      author.mainSport,
      author.country ?? post.location,
    ];
    final detail = parts.where((part) => part?.isNotEmpty == true).join(' · ');
    return detail.isEmpty ? 'Perfil deportivo' : detail;
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta opción estará disponible próximamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final post =
        feedAsync.valueOrNull?.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        ) ??
        widget.post;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leadingWidth: 72,
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white70),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Publicación',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white12,
                        backgroundImage: post.author.photoUrl != null
                            ? CachedNetworkImageProvider(post.author.photoUrl!)
                            : null,
                        child: post.author.photoUrl == null
                            ? const Icon(Icons.person, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author.name ?? 'Usuario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _authorDetailLine(post),
                              style: const TextStyle(
                                color: Color(0xFF23A6E8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Event badge (if any)
                  if (post.eventName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_outlined,
                              color: Color(0xFF60A5FA),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.eventName!,
                              style: const TextStyle(
                                color: Color(0xFF60A5FA),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Media Gallery
                  if (post.images.isNotEmpty) ...[
                    _buildMediaGallery(post.images),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  Text(
                    post.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Timestamp & Comments Count
                  Row(
                    children: [
                      Text(
                        _formatTime(post.createdAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${post.comments.length} Comentarios',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Like Status Text
                  if (post.likeCount > 0)
                    Text(
                      post.likeSummary,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),

                  const SizedBox(height: 16),
                  // Interaction Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: _isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        label: 'Me gusta',
                        isSelected: _isLiked,
                        onTap: _handleLike,
                      ),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Comentar',
                        onTap: () => _commentFocusNode.requestFocus(),
                      ),
                      _ActionButton(
                        icon: Icons.send_outlined,
                        label: 'Compartir',
                        onTap: _showComingSoon,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Comments Section
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (post.comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Aún no hay comentarios.',
                          style: TextStyle(color: Colors.white24),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        return _CommentItem(comment: comment);
                      },
                    ),
                ],
              ),
            ),
          ),

          // Sticky Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(color: Color(0xFF506B99)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, size: 18, color: Colors.white54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Deja tu comentario...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                TextButton(
                  onPressed: _isSubmittingComment ? null : _submitComment,
                  child: Text(
                    'Publicar',
                    style: TextStyle(
                      color: _isSubmittingComment
                          ? Colors.grey
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallery(List<String> images) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImage(images.first, double.infinity, 300),
      );
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: _buildImage(images[0], double.infinity, 200),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: _buildImage(images[1], double.infinity, 200),
            ),
          ),
        ],
      );
    }

    // Grid for 3+ images (matching screenshot layout)
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                ),
                child: _buildImage(images[0], double.infinity, 150),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                ),
                child: _buildImage(images[1], double.infinity, 150),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: _buildImage(
            images.length > 2 ? images[2] : images[0],
            double.infinity,
            180,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url, double width, double height) {
    return !url.startsWith('http')
        ? Image.file(
            File(url),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _errorPlaceholder(height),
          )
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => SkeletonBase(height: height),
            errorWidget: (context, url, error) => _errorPlaceholder(height),
          );
  }

  Widget _errorPlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.white12,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white24),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFFB547) : Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFB547) : Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    final detail = [
      comment.author.profileType,
      comment.author.position,
      comment.author.mainSport,
      comment.author.country,
    ].where((part) => part?.isNotEmpty == true).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white12,
            backgroundImage: comment.author.photoUrl != null
                ? CachedNetworkImageProvider(comment.author.photoUrl!)
                : null,
            child: comment.author.photoUrl == null
                ? const Icon(Icons.person, color: Colors.white54, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
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
                        fontSize: 15,
                      ),
                    ),
                    const Text(' · ', style: TextStyle(color: Colors.white38)),
                    Text(
                      '2 días', // Simplified
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xFF23A6E8),
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Las respuestas estarán disponibles próximamente',
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white54,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Responder',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
