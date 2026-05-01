import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:sport/features/jobs/domain/entities/job_applicant.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/jobs/domain/repositories/jobs_repository.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JobsRepositoryImpl(apiClient);
});

final jobsListProvider = AsyncNotifierProvider<JobsListNotifier, List<JobOffer>>(() {
  return JobsListNotifier();
});

final myJobOffersProvider = FutureProvider.autoDispose<List<JobOffer>>((ref) async {
  final result = await ref.watch(jobsRepositoryProvider).getMyOffers();
  return result.fold((failure) => throw Exception(failure.message), (jobs) => jobs);
});

final myJobApplicationsProvider = FutureProvider.autoDispose<List<JobOffer>>((ref) async {
  final result = await ref.watch(jobsRepositoryProvider).getMyApplications();
  return result.fold((failure) => throw Exception(failure.message), (jobs) => jobs);
});

final savedJobsProvider = FutureProvider.autoDispose<List<JobOffer>>((ref) async {
  final result = await ref.watch(jobsRepositoryProvider).getSavedJobs();
  return result.fold((failure) => throw Exception(failure.message), (jobs) => jobs);
});

final jobApplicantsProvider = FutureProvider.autoDispose.family<List<JobApplicant>, String>((ref, jobId) async {
  final result = await ref.watch(jobsRepositoryProvider).getApplicants(jobId);
  return result.fold((failure) => throw Exception(failure.message), (applicants) => applicants);
});

class JobsListNotifier extends AsyncNotifier<List<JobOffer>> {
  @override
  Future<List<JobOffer>> build() async {
    final repo = ref.watch(jobsRepositoryProvider);
    final result = await repo.getJobs();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (jobs) => jobs,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(jobsRepositoryProvider);
      final result = await repo.getJobs();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (jobs) => jobs,
      );
    });
  }
}
