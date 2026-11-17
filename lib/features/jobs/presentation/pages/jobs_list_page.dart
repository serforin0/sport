import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'job_detail_page.dart';
import '../widgets/job_card_widget.dart';
import '../providers/jobs_providers.dart';
import 'create_job_flow_page.dart';
import 'my_jobs_page.dart';
import 'saved_jobs_page.dart';

class JobsListPage extends ConsumerStatefulWidget {
  const JobsListPage({super.key});

  @override
  ConsumerState<JobsListPage> createState() => _JobsListPageState();
}

class _JobsListPageState extends ConsumerState<JobsListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showJobsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _JobsMenuItem(
                icon: Icons.add_box_outlined,
                label: 'Publicar empleo',
                onTap: () async {
                  Navigator.pop(context);
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateJobFlowPage(),
                    ),
                  );
                  if (created == true) {
                    ref.invalidate(jobsListProvider);
                  }
                },
              ),
              _JobsMenuItem(
                icon: Icons.work_outline,
                label: 'Mis empleos',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyJobsPage()),
                  );
                },
              ),
              _JobsMenuItem(
                icon: Icons.bookmark_border,
                label: 'Empleos guardados',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedJobsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterJobs(List<dynamic> jobs) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return jobs;
    return jobs.where((job) {
      return job.title.toLowerCase().contains(q) ||
          job.company.toLowerCase().contains(q) ||
          job.location.toLowerCase().contains(q) ||
          job.modality.toLowerCase().contains(q);
    }).toList();
  }

  void _showFiltersComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Los filtros avanzados estarán disponibles próximamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        title: const Text(
          'Empleos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
            onPressed: () => _showJobsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF1C4B8F)),
                bottom: BorderSide(color: Color(0xFF1C4B8F)),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar empleos por deporte, cargo o empresa',
                hintStyle: const TextStyle(
                  color: Color(0xFF9AB0CC),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 26,
                ),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(_searchCtrl.clear),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          Expanded(
            child: jobsAsync.when(
              data: (jobs) {
                final filtered = _filterJobs(jobs);
                if (filtered.isEmpty) {
                  return _JobsEmptyState(
                    showResultsHeader: _searchCtrl.text.trim().isNotEmpty,
                    onFilters: _showFiltersComingSoon,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(jobsListProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 88),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _searchCtrl.text.trim().isEmpty
                                    ? 'Principales recomendaciones para ti'
                                    : '${filtered.length} Resultados',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.tune,
                                color: Color(0xFFFF9441),
                              ),
                              onPressed: _showFiltersComingSoon,
                            ),
                          ],
                        ),
                      ),
                      for (final job in filtered)
                        JobCardWidget(
                          job: job,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailPage(job: job),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 6,
                itemBuilder: (context, index) => JobCardWidget.skeleton(),
              ),

              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Error al cargar empleos',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(jobsListProvider.notifier).refresh(),
                      child: const Text('Reintentar'),
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
}

class _JobsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _JobsMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF2D2D2D)),
      title: Text(
        label,
        style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 16),
      ),
    );
  }
}

class _JobsEmptyState extends StatelessWidget {
  final bool showResultsHeader;
  final VoidCallback onFilters;

  const _JobsEmptyState({
    required this.showResultsHeader,
    required this.onFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showResultsHeader)
          Positioned(
            top: 10,
            left: 18,
            right: 18,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '0 Resultados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFFFF9441)),
                  onPressed: onFilters,
                ),
              ],
            ),
          ),
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.manage_search, color: Color(0xFF9BB1CB), size: 138),
              SizedBox(height: 18),
              Text(
                'Sin resultados',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
