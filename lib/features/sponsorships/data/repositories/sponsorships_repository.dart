import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';

class SponsorshipsRepository {
  final ApiClient apiClient;

  SponsorshipsRepository(this.apiClient);

  Future<Result<bool>> createSponsorship(Map<String, dynamic> data) async {
    try {
      await apiClient.post('/sponsorships', data: data);
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure('Error al publicar patrocinio: $e'));
    }
  }
}
