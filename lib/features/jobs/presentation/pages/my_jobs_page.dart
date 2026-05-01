import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/job_card_widget.dart';
import '../../domain/entities/job_offer.dart';
import 'job_detail_page.dart';
import '../providers/jobs_providers.dart';


class MyJobsPage extends ConsumerStatefulWidget {
  const MyJobsPage({super.key});

  @override
  ConsumerState<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends ConsumerState<MyJobsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        title: const Text('Mis empleos', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFFF7A1A),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                tabs: const [
                  Tab(text: 'Publicados'),
                  Tab(text: 'Aplicaciones'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPublishedTab(),
                _buildApplicationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedTab() {
    final async = ref.watch(myJobOffersProvider);
    return async.when(
      data: (jobs) => _JobsListSection(
        title: 'Empleos publicados por ti',
        jobs: jobs,
        emptyText: 'Aún no has publicado empleos',
        onTap: (job) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PublishedJobApplicantsPage(job: job)),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, _) => _JobsErrorState(message: 'No se pudieron cargar tus empleos', onRetry: () => ref.invalidate(myJobOffersProvider)),
    );
  }

  Widget _buildApplicationsTab() {
    final async = ref.watch(myJobApplicationsProvider);
    return async.when(
      data: (jobs) => _JobsListSection(
        title: 'Empleos donde aplicaste',
        jobs: jobs,
        emptyText: 'Aún no has aplicado a empleos',
        onTap: (job) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailPage(job: job)),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, _) => _JobsErrorState(message: 'No se pudieron cargar tus aplicaciones', onRetry: () => ref.invalidate(myJobApplicationsProvider)),
    );
  }
}

class PublishedJobApplicantsPage extends ConsumerWidget {
  final JobOffer job;

  const PublishedJobApplicantsPage({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(jobApplicantsProvider(job.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        leading: const BackButton(color: Colors.white),
        title: const Text('Empleo publicado', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: const [Icon(Icons.edit, color: Colors.white), SizedBox(width: 18)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JobCardWidget(job: job),
          Container(
            height: 56,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1C4B8F)), bottom: BorderSide(color: Color(0xFF1C4B8F))),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar personas',
                hintStyle: TextStyle(color: Color(0xFF9AB0CC)),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: applicantsAsync.when(
              data: (applicants) => ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Text('Solicitudes recibidas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                  if (applicants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aún no hay solicitudes para este empleo', style: TextStyle(color: Colors.white70)),
                    ),
                  for (final applicant in applicants)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: applicant.user.photoUrl == null ? null : NetworkImage(applicant.user.photoUrl!),
                        child: applicant.user.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                      ),
                      title: Text(applicant.user.name ?? applicant.user.email, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      subtitle: Text(
                        [
                          if ((applicant.user.profileType ?? '').isNotEmpty) applicant.user.profileType!,
                          if ((applicant.user.mainSport ?? '').isNotEmpty) applicant.user.mainSport!,
                          if ((applicant.user.country ?? '').isNotEmpty) applicant.user.country!,
                        ].join(' · '),
                        style: const TextStyle(color: Color(0xFF19B5FF), fontSize: 12),
                      ),
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (_, _) => _JobsErrorState(message: 'No se pudieron cargar candidatos', onRetry: () => ref.invalidate(jobApplicantsProvider(job.id))),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobsListSection extends StatelessWidget {
  final String title;
  final List<JobOffer> jobs;
  final String emptyText;
  final ValueChanged<JobOffer> onTap;

  const _JobsListSection({required this.title, required this.jobs, required this.emptyText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: Colors.white70)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        for (final job in jobs) JobCardWidget(job: job, onTap: () => onTap(job)),
      ],
    );
  }
}

class _JobsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _JobsErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.white70)),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
