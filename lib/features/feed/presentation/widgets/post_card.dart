import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/post.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/features/feed/presentation/widgets/comment_bottom_sheet.dart';
import '../../../../core/widgets/video_background.dart';
import '../../../../core/widgets/skeleton_base.dart';
import '../pages/post_detail_page.dart';


class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final String currentUserId;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId = 'current_user',
  });

  static Widget skeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBase(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBase(width: 120, height: 14),
                  const SizedBox(height: 6),
                  const SkeletonBase(width: 80, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBase(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          const SkeletonBase(width: 200, height: 12),
          const SizedBox(height: 16),
          const SkeletonBase(width: double.infinity, height: 200, borderRadius: 12),
        ],
      ),
    );
  }



  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likes.contains(widget.currentUserId);
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    setState(() => _isLiked = !_isLiked);
    _heartController.forward().then((_) => _heartController.reverse());
    await ref.read(feedProvider.notifier).likePost(widget.post.id);
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _authorDetailLine(Post post) {
    final author = post.author;
    final parts = [
      author.profileType,
      author.position,
      author.mainSport,
      author.country ?? post.location,
    ];
    return parts.where((part) => part?.isNotEmpty == true).join(' · ');
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(post: widget.post),
    );
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(post: widget.post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A5B),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
              children: [
                Hero(
                  tag: 'avatar_${post.id}_${post.author.id}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white12,
                    backgroundImage: post.author.photoUrl != null
                        ? CachedNetworkImageProvider(post.author.photoUrl!)
                        : null,
                    child: post.author.photoUrl == null
                        ? const Icon(Icons.person, color: Colors.white54)
                        : null,
                  ),
                ),


                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.name ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _authorDetailLine(post),
                        style: const TextStyle(color: Color(0xFF23A6E8), fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.close, color: Colors.white54),
              ],
          ),
          const SizedBox(height: 12),

          // Event badge
          if (post.eventName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_outlined, color: Color(0xFF60A5FA), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      post.eventName!,
                      style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // Description
          GestureDetector(
            onTap: _navigateToDetail,
            child: Padding(
              padding: EdgeInsets.zero,
              child: Text(
                post.description,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Media
          if (post.images.isNotEmpty)
            GestureDetector(
              onTap: _navigateToDetail,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Hero(tag: 'post_media_${post.id}', child: _PostMediaGrid(images: post.images)),
              ),
            )

          else if (post.videoUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: VideoBackground(assetPath: post.videoUrl!),
                ),
              ),
            ),

          // Interaction Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatTime(post.createdAt),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${post.comments.length} Comentarios',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                if (post.likeCount > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Le ha gustado a ${post.likes.first} y otros ${post.likeCount - 1} usuarios',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _handleLike,
                      child: AnimatedBuilder(
                        animation: _heartAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _heartAnimation.value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                color: _isLiked ? const Color(0xFFFFB547) : Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Me gusta',
                                style: TextStyle(
                                  color: _isLiked ? const Color(0xFFFFB547) : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: _openComments,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 16),
                          SizedBox(width: 6),
                          Text('Comentar', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, color: Colors.white70, size: 16),
                          SizedBox(width: 6),
                          Text('Compartir', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _PostMediaGrid extends StatelessWidget {
  final List<String> images;

  const _PostMediaGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return _PostImage(path: images.first, height: 360);
    }
    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: _PostImage(path: images[0], height: 250)),
          const SizedBox(width: 4),
          Expanded(child: _PostImage(path: images[1], height: 250)),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PostImage(path: images[0], height: 150)),
            const SizedBox(width: 4),
            Expanded(child: _PostImage(path: images[1], height: 150)),
          ],
        ),
        const SizedBox(height: 4),
        _PostImage(path: images[2], height: 210),
      ],
    );
  }
}

class _PostImage extends StatelessWidget {
  final String path;
  final double height;

  const _PostImage({required this.path, required this.height});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(3);
    if (!path.startsWith('http')) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(path),
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _PostImageError(),
        ),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: path,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => SkeletonBase(height: height, borderRadius: 3),
        errorWidget: (context, url, error) => const _PostImageError(),
      ),
    );
  }
}

class _PostImageError extends StatelessWidget {
  const _PostImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Colors.white10,
      child: const Center(child: Icon(Icons.image_outlined, color: Colors.white24)),
    );
  }
}


