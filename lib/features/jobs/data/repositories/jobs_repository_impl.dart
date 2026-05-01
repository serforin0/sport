import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/jobs/data/models/job_applicant_model.dart';
import 'package:sport/features/jobs/data/models/job_offer_model.dart';
import 'package:sport/features/jobs/domain/entities/job_applicant.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  final ApiClient apiClient;

  JobsRepositoryImpl(this.apiClient);

  @override
  Future<Result<List<JobOffer>>> getJobs({int page = 1, int limit = 20}) async {
    try {
      final response = await apiClient.get('/jobs', queryParameters: {
        'page': page,
        'per_page': limit,
      });

      final list = unwrapDataList(response.data);
      final jobs = list
          .whereType<Map<String, dynamic>>()
          .map((e) => JobOfferModel.fromApi(e))
          .toList();

      return Ok(jobs);
    } catch (e) {
      return Err(ServerFailure('Error al cargar ofertas: ${e.toString()}'));
    }
  }

  @override
  Future<Result<JobOffer>> getJobById(String id) async {
    try {
      final response = await apiClient.get('/jobs/$id');
      final map = unwrapDataMap(response.data) ?? 
                  (response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null);
                  
      if (map == null) {
        return const Err(NotFoundFailure('Empleo no encontrado'));
      }
      return Ok(JobOfferModel.fromApi(map));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<JobOffer>> createJob(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/jobs', data: data);
      final map = unwrapDataMap(response.data);
      if (map == null) return const Err(ServerFailure('Respuesta inválida al publicar empleo'));
      return Ok(JobOfferModel.fromApi(map));
    } catch (e) {
      return Err(ServerFailure('Error al publicar empleo: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<JobOffer>>> getMyOffers() => _getJobList('/jobs/my-offers', 'Error al cargar empleos publicados');

  @override
  Future<Result<List<JobOffer>>> getMyApplications() => _getJobList('/jobs/my-applications', 'Error al cargar aplicaciones');

  @override
  Future<Result<List<JobOffer>>> getSavedJobs() => _getJobList('/jobs/my-saved', 'Error al cargar empleos guardados');

  Future<Result<List<JobOffer>>> _getJobList(String path, String errorMessage) async {
    try {
      final response = await apiClient.get(path);
      final jobs = unwrapDataList(response.data)
          .whereType<Map<String, dynamic>>()
          .map((e) => JobOfferModel.fromApi(e))
          .toList();

      return Ok(jobs);
    } catch (e) {
      return Err(ServerFailure('$errorMessage: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<JobApplicant>>> getApplicants(String jobId) async {
    try {
      final response = await apiClient.get('/jobs/$jobId/applicants');
      final applicants = unwrapDataList(response.data)
          .whereType<Map<String, dynamic>>()
          .map((e) => JobApplicantModel.fromApi(e))
          .toList();

      return Ok(applicants);
    } catch (e) {
      return Err(ServerFailure('Error al cargar candidatos: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> applyToJob(String jobId, String message) async {
    try {
      await apiClient.post('/jobs/$jobId/apply', data: {
        'message': message,
      });
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> cancelApplication(String jobId) async {
    try {
      await apiClient.delete('/jobs/$jobId/apply');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> saveJob(String jobId) async {
    try {
      await apiClient.post('/jobs/$jobId/save');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> unsaveJob(String jobId) async {
    try {
      await apiClient.delete('/jobs/$jobId/unsave');
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}
