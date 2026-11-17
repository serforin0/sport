import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
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

  Future<Result<List<Map<String, dynamic>>>> listSponsorships() async {
    try {
      final response = await apiClient.get('/sponsorships');
      final list = unwrapDataList(response.data);
      return Ok(
        list
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList(growable: false),
      );
    } catch (e) {
      return Err(ServerFailure('Error al cargar patrocinios: $e'));
    }
  }
}
