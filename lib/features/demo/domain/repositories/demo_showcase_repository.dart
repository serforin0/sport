import 'package:sport/core/result/result.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';

abstract class DemoShowcaseRepository {
  Future<Result<DemoShowcase>> getShowcase();
  Future<Result<void>> joinGroup(String groupId);
  Future<Result<void>> leaveGroup(String groupId);
  Future<Result<void>> postInGroup(String groupId, String body);
  Future<Result<Map<String, dynamic>>> checkout({
    required String productId,
    required String variant,
    required String recipientName,
    required String city,
    required String address,
  });
  Future<Result<void>> applySponsorship(
    String sponsorshipId, {
    String? message,
  });
}
