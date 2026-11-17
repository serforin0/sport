import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';

class GroupDetailPage extends ConsumerStatefulWidget {
  final DemoGroup group;

  const GroupDetailPage({super.key, required this.group});

  @override
  ConsumerState<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage> {
  final _postCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<dynamic> Function() action, String success) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(demoShowcaseProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success)));
      },
    );
  }

  DemoGroup _resolveGroup(DemoShowcase? showcase) {
    if (showcase == null) return widget.group;
    for (final item in showcase.groups) {
      if (item.id == widget.group.id) return item;
    }
    return widget.group;
  }

  @override
  Widget build(BuildContext context) {
    final group = _resolveGroup(ref.watch(demoShowcaseProvider).valueOrNull);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(group.name),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: group.imageUrl == null
                ? const ColoredBox(
                    color: Color(0xFF1E293B),
                    child: Icon(Icons.groups, color: Colors.white24, size: 64),
                  )
                : Semantics(
                    image: true,
                    label: 'Imagen del grupo ${group.name}',
                    child: ExcludeSemantics(
                      child: CachedNetworkImage(
                        imageUrl: group.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.description ?? '',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${group.membersCount} miembros',
                  style: const TextStyle(color: Color(0xFF5EEAD4)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy
                        ? null
                        : () => group.joined
                              ? _run(
                                  () => ref
                                      .read(demoShowcaseRepositoryProvider)
                                      .leaveGroup(group.id),
                                  'Saliste del grupo',
                                )
                              : _run(
                                  () => ref
                                      .read(demoShowcaseRepositoryProvider)
                                      .joinGroup(group.id),
                                  'Te uniste al grupo',
                                ),
                    child: Text(group.joined ? 'Salir del grupo' : 'Unirme'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Publicaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                if (group.joined) ...[
                  TextField(
                    controller: _postCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Publicación',
                      hintText: 'Escribe una publicación para el grupo',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              final body = _postCtrl.text.trim();
                              if (body.length < 3) return;
                              _run(
                                () => ref
                                    .read(demoShowcaseRepositoryProvider)
                                    .postInGroup(group.id, body),
                                'Publicación enviada',
                              ).then((_) => _postCtrl.clear());
                            },
                      child: const Text('Publicar'),
                    ),
                  ),
                ],
                ...group.posts.map(
                  (post) => Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        post.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        post.body,
                        style: const TextStyle(color: Colors.white70),
                      ),
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
}
