import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _media = [];
  _PostAudience _audience = _PostAudience.public;
  _PostGroup? _selectedGroup;
  bool _isPosting = false;

  static const _groups = [
    _PostGroup(name: 'Atletismo Dominicano', imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=1200&auto=format&fit=crop'),
    _PostGroup(name: 'Atletismo USA'),
    _PostGroup(name: 'UTS Reclutamiento', imageUrl: 'https://images.unsplash.com/photo-1526676037777-05a232554f77?q=80&w=1200&auto=format&fit=crop'),
  ];

  bool get _canPost => !_isPosting && (_textController.text.trim().isNotEmpty || _media.isNotEmpty);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      final images = await _picker.pickMultiImage(imageQuality: 82);
      if (images.isEmpty) return;
      setState(() {
        _media.addAll(images);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la galería: $e')),
      );
    }
  }

  Future<void> _openCamera() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 82);
      if (image == null) return;
      setState(() => _media.add(image));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la cámara: $e')),
      );
    }
  }

  Future<void> _handlePost() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null || !_canPost) return;

    setState(() => _isPosting = true);
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: user,
      description: _textController.text.trim(),
      images: _media.map((file) => file.path).toList(),
      createdAt: DateTime.now(),
      likes: const [],
      comments: const [],
      location: _selectedGroup?.name,
      eventName: _audience == _PostAudience.group ? _selectedGroup?.name : null,
    );

    await ref.read(feedProvider.notifier).createPost(newPost);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _showAudienceSheet() async {
    final selected = await showModalBottomSheet<_PostAudience>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 22),
              _AudienceOption(
                icon: Icons.public,
                title: 'Cualquiera',
                subtitle: 'Cualquier persona puede ver tus publicaciones',
                onTap: () => Navigator.pop(context, _PostAudience.public),
              ),
              const Divider(),
              _AudienceOption(
                icon: Icons.person_outline,
                title: 'Solo tus contactos',
                onTap: () => Navigator.pop(context, _PostAudience.contacts),
              ),
              const Divider(),
              _AudienceOption(
                icon: Icons.groups_outlined,
                title: 'Grupo',
                trailing: Icons.chevron_right,
                onTap: () => Navigator.pop(context, _PostAudience.group),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected == null) return;
    if (selected == _PostAudience.group) {
      if (!mounted) return;
      final group = await Navigator.push<_PostGroup>(
        context,
        MaterialPageRoute(builder: (_) => const _GroupPickerPage(groups: _groups)),
      );
      if (group == null) return;
      setState(() {
        _audience = selected;
        _selectedGroup = group;
      });
      return;
    }
    setState(() {
      _audience = selected;
      _selectedGroup = null;
    });
  }

  void _removeMedia(int index) {
    setState(() => _media.removeAt(index));
  }

  String get _audienceLabel {
    return switch (_audience) {
      _PostAudience.public => 'Cualquiera puede ver esta publicación',
      _PostAudience.contacts => 'Solo contactos',
      _PostAudience.group => _selectedGroup?.name ?? 'Grupo',
    };
  }

  IconData get _audienceIcon {
    return switch (_audience) {
      _PostAudience.public => Icons.public,
      _PostAudience.contacts => Icons.person_outline,
      _PostAudience.group => Icons.groups_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 84,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leadingWidth: 72,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva publicación',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ListenableBuilder(
              listenable: _textController,
              builder: (context, _) => _PublishButton(
                enabled: _canPost,
                isPosting: _isPosting,
                onTap: _canPost ? _handlePost : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: const Color(0xFF168BFF),
            child: InkWell(
              onTap: _showAudienceSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    Icon(_audienceIcon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _audienceLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text('Cambiar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textController,
                    autofocus: true,
                    maxLines: null,
                    minLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: '¡Comparte tus ideas con la comunidad...',
                      hintStyle: TextStyle(color: Color(0xFF7F9BC0), fontSize: 16, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_media.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 98,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _media.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => _MediaThumb(
                          file: _media[index],
                          onRemove: () => _removeMedia(index),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _pickMedia,
                      icon: const Icon(Icons.image_outlined, color: Color(0xFF19B5FF), size: 30),
                      label: const Text(
                        'Agregar\nmultimedia',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.05),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _openCamera,
                      icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFF19B5FF)),
                      label: const Text('Abrir cámara', style: TextStyle(color: Color(0xFF19B5FF))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  final bool enabled;
  final bool isPosting;
  final VoidCallback? onTap;

  const _PublishButton({required this.enabled, required this.isPosting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: enabled
            ? const LinearGradient(colors: [Color(0xFF64A6FF), Color(0xFF214D92)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            : LinearGradient(colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0.20)]),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const StadiumBorder(),
        ),
        child: isPosting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _MediaThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(File(file.path), width: 122, height: 92, fit: BoxFit.cover),
        ),
        Positioned(
          right: -6,
          top: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(color: Color(0xFF19B5FF), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _AudienceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData? trailing;
  final VoidCallback onTap;

  const _AudienceOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 34,
      leading: Icon(icon, color: const Color(0xFF2D2D2D), size: 30),
      title: Text(title, style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 20, fontWeight: FontWeight.w900)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 18)),
      trailing: trailing == null ? null : Icon(trailing, color: const Color(0xFF2D2D2D), size: 30),
      onTap: onTap,
    );
  }
}

class _GroupPickerPage extends StatefulWidget {
  final List<_PostGroup> groups;

  const _GroupPickerPage({required this.groups});

  @override
  State<_GroupPickerPage> createState() => _GroupPickerPageState();
}

class _GroupPickerPageState extends State<_GroupPickerPage> {
  _PostGroup? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 92,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leadingWidth: 72,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Grupos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Text(
              'A continuación, selecciona un grupo en el que desees publicar tu contenido',
              style: TextStyle(color: Colors.white, fontSize: 17, height: 1.35),
            ),
          ),
          for (final group in widget.groups)
            _GroupTile(
              group: group,
              selected: _selected == group,
              onTap: () => setState(() => _selected = group),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 34),
            child: _ReadyButton(
              enabled: _selected != null,
              onTap: _selected == null ? null : () => Navigator.pop(context, _selected),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final _PostGroup group;
  final bool selected;
  final VoidCallback onTap;

  const _GroupTile({required this.group, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1C4B8F)))),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: group.imageUrl == null
                  ? Container(
                      width: 58,
                      height: 44,
                      color: Colors.white.withValues(alpha: 0.10),
                      child: const Icon(Icons.groups, color: Colors.white70, size: 30),
                    )
                  : Image.network(group.imageUrl!, width: 58, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(group.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? const Color(0xFF19B5FF) : Colors.white38, width: 2),
              ),
              child: selected ? const Center(child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF19B5FF))) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _ReadyButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: enabled
            ? const LinearGradient(colors: [Color(0xFF4FA3FF), Color(0xFF214D92)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            : LinearGradient(colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0.20)]),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 58),
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
        ),
        child: const Text('Listo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 6,
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

enum _PostAudience { public, contacts, group }

class _PostGroup {
  final String name;
  final String? imageUrl;

  const _PostGroup({required this.name, this.imageUrl});
}
