import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'job_detail_page.dart';
import '../widgets/job_card_widget.dart';
import '../providers/jobs_providers.dart';


class SavedJobsPage extends ConsumerWidget {
  const SavedJobsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2A5B),
      appBar: AppBar(
        toolbarHeight: 86,
        backgroundColor: const Color(0xFF0F2A5B),
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        title: const Text('Empleos guardados', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: async.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('Aún no tienes empleos guardados', style: TextStyle(color: Colors.white70)));
          }

          return ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            children: [
              for (final job in jobs)
                JobCardWidget(
                  job: job,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailPage(job: job))),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudieron cargar empleos guardados', style: TextStyle(color: Colors.white70)),
              TextButton(onPressed: () => ref.invalidate(savedJobsProvider), child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
