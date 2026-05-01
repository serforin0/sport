import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import '../providers/stories_providers.dart';
import '../../domain/entities/story.dart';
import '../pages/story_view_page.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';


/// Barra horizontal de stories desde `GET /stories`.
class StoriesBar extends ConsumerWidget {
  final String? currentUserPhotoUrl;

  const StoriesBar({super.key, this.currentUserPhotoUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(storiesProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 96,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stories) {
        if (stories.isEmpty) {
          return _EmptyStoriesSlot(
            currentUserPhotoUrl: currentUserPhotoUrl,
            onAdd: () => _showCreateStory(context, ref),
          );
        }
        return SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _AddStoryAvatar(
                    photoUrl: currentUserPhotoUrl,
                    onTap: () => _showCreateStory(context, ref),
                  ),
                );
              }
              final story = stories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryViewPage(
                          stories: stories,
                          initialIndex: index - 1,
                        ),
                      ),
                    );
                  },
                  child: _StoryRing(story: story, fallbackOwnPhoto: currentUserPhotoUrl),
                ),
              );
            },

          ),
        );
      },
    );
  }

  void _showCreateStory(BuildContext context, WidgetRef ref) {
    final token = ref.read(sharedPreferencesProvider).getString('auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para crear una historia')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CreateStorySheet(
        onSubmit: (mediaUrl, filePath, type) async {
          Navigator.pop(ctx);
          await ref.read(storiesNotifierProvider.notifier).createStory(
                mediaUrl: mediaUrl,
                filePath: filePath,
                type: type,
              );
          ref.invalidate(storiesProvider);
        },

      ),
    );
  }
}

class _CreateStorySheet extends StatefulWidget {
  final Future<void> Function(String? mediaUrl, String? filePath, String type) onSubmit;

  const _CreateStorySheet({required this.onSubmit});


  @override
  State<_CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<_CreateStorySheet> {
  final _picker = ImagePicker();
  XFile? _pickedFile;
  String _type = 'image';
  bool _sending = false;

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final file = _type == 'image'
          ? await _picker.pickImage(source: source)
          : await _picker.pickVideo(source: source);
      if (file != null) {
        setState(() => _pickedFile = file);
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nueva historia',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_pickedFile != null)
                TextButton(
                  onPressed: () => setState(() => _pickedFile = null),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_pickedFile == null) ...[
            const Text(
              'Selecciona el tipo y luego el archivo:',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Imagen'),
                  selected: _type == 'image',
                  onSelected: (_) => setState(() {
                    _type = 'image';
                    _pickedFile = null;
                  }),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Video'),
                  selected: _type == 'video',
                  onSelected: (_) => setState(() {
                    _type = 'video';
                    _pickedFile = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickMedia(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('GALERÍA'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickMedia(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('CÁMARA'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _type == 'image'
                    ? Image.file(File(_pickedFile!.path), fit: BoxFit.cover)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.video_file, color: Color(0xFF3B82F6), size: 40),
                            SizedBox(height: 8),
                            Text('Video seleccionado', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_sending || _pickedFile == null)
                ? null
                : () async {
                    setState(() => _sending = true);
                    await widget.onSubmit(null, _pickedFile!.path, _type);
                  },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _sending
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('PUBLICAR HISTORIA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


class _EmptyStoriesSlot extends StatelessWidget {
  final String? currentUserPhotoUrl;
  final VoidCallback onAdd;

  const _EmptyStoriesSlot({this.currentUserPhotoUrl, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        children: [
          _AddStoryAvatar(photoUrl: currentUserPhotoUrl, onTap: onAdd),
        ],
      ),
    );
  }
}

class _AddStoryAvatar extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback onTap;

  const _AddStoryAvatar({this.photoUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : null,
                backgroundColor: Colors.white12,
                child: (photoUrl == null || photoUrl!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white38, size: 26)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tu historia',
            style: TextStyle(color: Colors.white60, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  final Story story;
  final String? fallbackOwnPhoto;

  const _StoryRing({required this.story, this.fallbackOwnPhoto});

  @override
  Widget build(BuildContext context) {
    final photo = story.isOwn ? fallbackOwnPhoto : story.avatarUrl;

    return Column(
      children: [
        if (!story.isOwn)
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 26,
                backgroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
                backgroundColor: Colors.white12,
                child: (photo == null || photo.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white38, size: 22)
                    : null,
              ),
            ),
          )
        else
          CircleAvatar(
            radius: 30,
            backgroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
            backgroundColor: Colors.white12,
            child: (photo == null || photo.isEmpty)
                ? const Icon(Icons.person, color: Colors.white38, size: 26)
                : null,
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            story.displayName,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
