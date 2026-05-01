import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/stories/domain/entities/story.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryViewPage extends ConsumerWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewPage({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        itemCount: stories.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          final story = stories[index];
          return Stack(
            children: [
              // Media Content
              Positioned.fill(
                child: story.type == 'video'
                    ? const Center(
                        child: Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
                      )
                    : CachedNetworkImage(
                        imageUrl: story.mediaUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error, color: Colors.white),
                        ),
                      ),
              ),

              // Overlay Gradient (Top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Header (User info)
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Usuario Hubsport',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Progress Bar Placeholder
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(
                    stories.length,
                    (idx) => Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: idx <= index ? Colors.white : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
