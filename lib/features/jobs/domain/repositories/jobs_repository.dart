import 'package:sport/core/result/result.dart';
import 'package:sport/features/jobs/domain/entities/job_applicant.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';

abstract class JobsRepository {
  Future<Result<List<JobOffer>>> getJobs({int page = 1, int limit = 20});
  Future<Result<JobOffer>> getJobById(String id);
  Future<Result<JobOffer>> createJob(Map<String, dynamic> data);
  Future<Result<List<JobOffer>>> getMyOffers();
  Future<Result<List<JobOffer>>> getMyApplications();
  Future<Result<List<JobOffer>>> getSavedJobs();
  Future<Result<List<JobApplicant>>> getApplicants(String jobId);
  Future<Result<bool>> applyToJob(String jobId, String message);
  Future<Result<bool>> cancelApplication(String jobId);
  Future<Result<bool>> saveJob(String jobId);
  Future<Result<bool>> unsaveJob(String jobId);
}
