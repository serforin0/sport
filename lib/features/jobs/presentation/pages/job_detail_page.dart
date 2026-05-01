import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/job_offer.dart';
import '../providers/jobs_providers.dart';


class JobDetailPage extends ConsumerStatefulWidget {
  final JobOffer job;

  const JobDetailPage({super.key, required this.job});

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  bool _isSaved = false;
  bool _hasApplied = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.job.isSaved;
    _hasApplied = widget.job.hasApplied;
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leadingWidth: 70,
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles del empleo',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 118),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Logo, Company, Location)
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: job.companyLogoUrl != null
                            ? Hero(
                                tag: 'job_logo_${job.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: job.companyLogoUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const Icon(Icons.business, color: Color(0xFF001A43)),
                      ),

                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.company,
                            style: const TextStyle(
                              color: Color(0xFF19B5FF),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                job.location,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.work_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${job.modality} · ${job.experienceLevel}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_formatTime(job.createdAt), style: const TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFF1C4B8F)),
                const SizedBox(height: 14),
                Text(
                  widget.job.isOwner ? 'Empleo publicado por ti' : 'Acerca de la empresa',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.job.isOwner
                      ? 'Has recibido ${widget.job.applicationsCount} solicitud${widget.job.applicationsCount == 1 ? '' : 'es'} para esta oferta.'
                      : 'Revisa la información de la empresa antes de aplicar. Si tienes dudas, usa el método de aplicación indicado.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sitio web',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Color(0xFF19B5FF), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.applicationUrl?.isNotEmpty == true ? job.applicationUrl! : 'www.${job.company.replaceAll(' ', '')}.com',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Color(0xFF19B5FF), size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Acerca del empleo',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                const Text(
                  '• Maecenas vitae mattis tellus. Nullam quis imperdiet augue.\n'
                  '• Vestibulum auctor ornare leo, non suscipit magna interdum eu.\n'
                  '• Curabitur pellentesque nibh nibh, at maximus ante fermentum sit amet.\n'
                  '• Pellentesque commodo lacus at sodales sodales.',
                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.35, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Quisque sagittis orci ut diam condimentum, vel euismod erat placerat. In iaculis arcu eros, eget tempus orci facilisis id.\n\n'
                  'Quisque sagittis orci ut diam condimentum, vel euismod erat placerat. In iaculis arcu eros, eget tempus orci facilisis id.\n\n'
                  'Quisque sagittis orci ut diam condimentum, vel euismod erat placerat. In iaculis arcu eros, eget tempus orci facilisis id.',
                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                const Text('Fecha límite de aplicación', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  job.deadline == null ? 'No definida' : '${job.deadline!.day} ${_monthLabel(job.deadline!.month)} ${job.deadline!.year}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          
          // Bottom Actions
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF0F2A5B),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (!job.isOwner)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                        onPressed: _toggleSave,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(_isSaved ? 'Guardado' : 'Guardar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                     ),
                    if (!job.isOwner) const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _isApplying
                            ? null
                            : () {
                                if (job.isOwner) {
                                  Navigator.pop(context);
                                } else if (_hasApplied) {
                                  _cancelApplication();
                                } else {
                                  _showApplyDialog(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C8DFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(
                          job.isOwner ? 'Editar empleo' : (_hasApplied ? 'Cancelar aplicación' : 'Aplicar'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF00183F),
        title: const Text('Aplicar al empleo', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Escribe un mensaje breve...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isApplying = true);
              final repo = ref.read(jobsRepositoryProvider);
              final res = await repo.applyToJob(widget.job.id, controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {
                  _hasApplied = res.isSuccess;
                  _isApplying = false;
                });
                ref.invalidate(jobsListProvider);
                ref.invalidate(myJobApplicationsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res.isSuccess ? 'Aplicación enviada' : 'Error al aplicar')),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSave() async {
    final nextValue = !_isSaved;
    setState(() => _isSaved = nextValue);
    final repo = ref.read(jobsRepositoryProvider);
    final result = nextValue ? await repo.saveJob(widget.job.id) : await repo.unsaveJob(widget.job.id);

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isSaved = !nextValue);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ref.invalidate(jobsListProvider);
        ref.invalidate(savedJobsProvider);
      },
    );
  }

  Future<void> _cancelApplication() async {
    setState(() => _isApplying = true);
    final result = await ref.read(jobsRepositoryProvider).cancelApplication(widget.job.id);

    if (!mounted) return;
    setState(() => _isApplying = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        setState(() => _hasApplied = false);
        ref.invalidate(jobsListProvider);
        ref.invalidate(myJobApplicationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aplicación cancelada')));
      },
    );
  }

  String _monthLabel(int month) {
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return months[month - 1];
  }

}
