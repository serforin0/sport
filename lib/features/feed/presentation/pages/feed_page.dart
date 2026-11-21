import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/feed_providers.dart';

import '../widgets/post_card.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sport/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:sport/features/news/presentation/widgets/news_section.dart';
import 'package:sport/features/results/presentation/widgets/results_section.dart';
import 'package:sport/features/search/presentation/pages/search_page.dart';
import 'package:sport/features/stories/presentation/providers/stories_providers.dart';
import 'package:sport/features/stories/presentation/widgets/stories_bar.dart';
import 'package:sport/features/profile/presentation/widgets/profile_drawer.dart';
import 'package:sport/features/people/presentation/pages/people_page.dart';
import 'package:sport/features/chat/presentation/pages/chat_list_page.dart';
import 'package:sport/core/widgets/hubsport_wordmark.dart';


class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final userId = user?.id ?? 'current_user';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      endDrawer: ProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _FeedHeader(user: user),
            const _FeedSportScopeBar(),
            Expanded(
              child: feedAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return _EmptyFeedState(
                      onExplore: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PeoplePage()),
                      ),
                    );
                  }

                  return RefreshIndicator(
                  color: const Color(0xFF3B82F6),
                  backgroundColor: const Color(0xFF1E293B),
                  onRefresh: () async {
                    ref.invalidate(storiesProvider);
                    await ref.read(feedProvider.notifier).refresh();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Stories bar
                      SliverToBoxAdapter(
                        child: StoriesBar(currentUserPhotoUrl: user?.photoUrl),
                      ),
                      // News Section
                      SliverToBoxAdapter(
                        child: NewsSection(),
                      ),
                      // Results Section
                      SliverToBoxAdapter(
                        child: ResultsSection(),
                      ),
                      // Posts list
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = posts[index];
                              return PostCard(
                                key: ValueKey(post.id),
                                post: post,
                                currentUserId: userId,
                              );
                            },
                            childCount: posts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) => PostCard.skeleton(),
                ),
                error: (err, _) => _OfflineState(
                  onRetry: () => ref.read(feedProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedSportScopeBar extends ConsumerWidget {
  const _FeedSportScopeBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(feedSportScopeProvider);
    final sportName = ref.watch(authControllerProvider).valueOrNull?.mainSport;

    Widget chip(String value, String label) {
      final selected = scope == value;
      return ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xFF3B82F6),
        backgroundColor: Colors.white.withOpacity(0.06),
        onSelected: (_) {
          ref.read(feedSportScopeProvider.notifier).state = value;
        },
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Wrap(
        spacing: 8,
        children: [
          chip(
            'my_sport',
            sportName == null || sportName.isEmpty
                ? 'Mi deporte'
                : 'Mi deporte · $sportName',
          ),
          chip('all', 'Todos los deportes'),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Header
// ────────────────────────────────────────────────────────────
class _FeedHeader extends ConsumerWidget {
  final dynamic user;
  const _FeedHeader({this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2A5B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1C4B8F), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: HubSportWordmark(
              fontSize: 24,
              textAlign: TextAlign.left,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 25),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
          IconButton(
            key: const Key('feed_chat_button'),
            tooltip: 'Chat',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListPage()),
            ),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 25),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: unreadCount > 9 ? 18 : 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6A1A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            key: const Key('e2e_feed_avatar'),
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white12,
              backgroundImage: user?.photoUrl != null
                  ? CachedNetworkImageProvider(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white54)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  final VoidCallback onExplore;

  const _EmptyFeedState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFDCEBFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore, color: Color(0xFF0F2A5B), size: 42),
            ),
            const SizedBox(height: 28),
            const Text(
              '¡Explora ahora y\nexpande tu círculo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w300,
                height: 1.25,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF20A8FF),
                decorationThickness: 2,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Conecta con nuevos compañeros de equipo, conoce a atletas apasionados y sumérgete en una experiencia deportiva completamente significativa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onExplore,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF168BFF),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Explorar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineState extends StatelessWidget {
  final VoidCallback onRetry;

  const _OfflineState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Color(0xFFCFE6FF), size: 92),
            const SizedBox(height: 28),
            const Text(
              'Sin conexión a\ninternet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w300, height: 1.25),
            ),
            const SizedBox(height: 24),
            const Text(
              'Parece que no hay conexión a internet en este momento. Por favor, verifica tu conexión.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.35),
            ),
            const SizedBox(height: 28),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar', style: TextStyle(color: Color(0xFF20A8FF))),
            ),
          ],
        ),
      ),
    );
  }
}

