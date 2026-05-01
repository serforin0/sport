import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';


import '../../../../core/widgets/skeleton_base.dart';
import '../providers/notifications_provider.dart';
import '../../domain/entities/notification.dart';
import 'solicitudes_page.dart';
import '../../../feed/presentation/pages/post_detail_page.dart';
import '../../../feed/presentation/providers/feed_providers.dart';


class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {


  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final requestsCount = ref.watch(connectionRequestsCountProvider);

    return notificationsAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFF072353),
        appBar: AppBar(
          backgroundColor: const Color(0xFF072353),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notificaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) => const _NotificationSkeleton(),
        ),
      ),

      error: (_, __) => Scaffold(
        backgroundColor: const Color(0xFF072353),
        appBar: AppBar(
          backgroundColor: const Color(0xFF072353),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Notificaciones', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text('No se pudieron cargar las notificaciones', style: TextStyle(color: Colors.white54)),
        ),
      ),
      data: (notifications) => _buildBody(context, notifications, requestsCount),
    );
  }

  Widget _buildBody(BuildContext context, List<AppNotification> notifications, int requestsCount) {
    // Group notifications by today / yesterday / earlier
    final now = DateTime.now();
    final today = notifications.where((AppNotification n) {
      final diff = now.difference(n.createdAt);
      return diff.inHours < 24;
    }).toList();
    final yesterday = notifications.where((AppNotification n) {
      final diff = now.difference(n.createdAt);
      return diff.inHours >= 24 && diff.inHours < 48;
    }).toList();
    final earlier = notifications.where((AppNotification n) {
      final diff = now.difference(n.createdAt);
      return diff.inHours >= 48;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF072353),
      appBar: AppBar(
        backgroundColor: const Color(0xFF072353),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            child: const Text('Leer todo', style: TextStyle(color: Color(0xFF2CB5FF), fontSize: 13)),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF2CB5FF),
        backgroundColor: const Color(0xFF0F172A),
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
        },
        child: notifications.isEmpty
            ? _EmptyState()
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Solicitudes de conexión banner
                  if (requestsCount > 0)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SolicitudesPage()),
                      ),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: const BoxDecoration(color: Color(0xFF007BFF)),
                        child: Row(
                          children: [
                            const Icon(Icons.people_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Solicitudes de conexión ($requestsCount)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
  
                  // Today
                  if (today.isNotEmpty) ...[
                    _SectionHeader('Hoy'),
                    ...today.map((AppNotification n) => _NotificationTile(notification: n)),
                  ],
  
                  // Yesterday
                  if (yesterday.isNotEmpty) ...[
                    _SectionHeader('Ayer'),
                    ...yesterday.map((AppNotification n) => _NotificationTile(notification: n)),
                  ],
  
                  // Earlier
                  if (earlier.isNotEmpty) ...[
                    _SectionHeader('Antes'),
                    ...earlier.map((AppNotification n) => _NotificationTile(notification: n)),
                  ],
  
                  const SizedBox(height: 24),
                ],
              ),
      ),

    );
  }

}

// ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  String _formatTime(DateTime dt) {
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    final hour12 = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    return '${hour12.toString().padLeft(2, '0')}:$m$period';
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      case NotificationType.like:
        return Icons.favorite_outline;
      case NotificationType.eventInvite:
        return Icons.event_outlined;
      case NotificationType.groupPost:
        return Icons.group_outlined;
      case NotificationType.newPost:
        return Icons.article_outlined;
      case NotificationType.connectionRequest:
        return Icons.person_add_outlined;
    }
  }

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.like:
        return const Color(0xFFEF4444);
      case NotificationType.comment:
        return const Color(0xFF2CB5FF);
      case NotificationType.eventInvite:
        return const Color(0xFF8B5CF6);
      case NotificationType.groupPost:
        return const Color(0xFF10B981);
      case NotificationType.newPost:
        return const Color(0xFF2CB5FF);
      case NotificationType.connectionRequest:
        return const Color(0xFF007BFF);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        // Mark as read (Optimistic update)
        ref.read(notificationsProvider.notifier).markAsRead(notification.id);

        if (notification.type == NotificationType.connectionRequest) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SolicitudesPage()),
          );
          return;
        }

        final relatedId = notification.relatedId;
        if (relatedId == null || relatedId.isEmpty) return;

        if (notification.type == NotificationType.newPost || 
            notification.type == NotificationType.comment || 
            notification.type == NotificationType.like) {
          
          try {
            // If the post is already in feed, we might find it there, 
            // but fetching by ID is safer for deep links/notifications.
            final post = await ref.read(getPostByIdProvider(relatedId).future);
            
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo cargar la publicación'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : Colors.white.withOpacity(0.04),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with type icon overlay
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white12,
                  backgroundImage: notification.authorPhotoUrl != null
                      ? CachedNetworkImageProvider(notification.authorPhotoUrl!)
                      : null,
                  child: notification.authorPhotoUrl == null
                      ? const Icon(Icons.person, color: Colors.white38)
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _typeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF072353), width: 2),
                    ),
                    child: Icon(_typeIcon, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: notification.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: ' ${notification.message}',
                          style: const TextStyle(
                            color: Color(0xFFB0C4DE),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF2CB5FF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF2CB5FF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBase(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBase(width: 180, height: 14),
                SizedBox(height: 8),
                SkeletonBase(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_outlined, color: Colors.white24, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin notificaciones',
            style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí aparecerán tus likes,\ncomentarios y solicitudes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
