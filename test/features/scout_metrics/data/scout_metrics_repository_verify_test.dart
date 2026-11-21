import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/scout_metrics/data/repositories/scout_metrics_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late ScoutMetricsRepository repo;

  setUp(() {
    api = MockApiClient();
    repo = ScoutMetricsRepository(api);
  });

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(<String, dynamic>{});
  });

  test('verifyMetric_envia_patch_status', () async {
    when(
      () => api.patch(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/verify'),
        data: {'success': true},
      ),
    );

    final result = await repo.verifyMetric(
      athleteUserId: 'athlete-1',
      metricValueId: 'metric-9',
      status: 'coach_verified',
    );

    expect(result.isSuccess, isTrue);
    final path = verify(
      () => api.patch(captureAny(), data: captureAny(named: 'data')),
    ).captured;
    expect(path[0], '/user/athlete-1/metrics/metric-9/verify');
    expect(path[1], {'verification_status': 'coach_verified'});
  });

  test('addVideo_y_deleteVideo_rutas_correctas', () async {
    when(() => api.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/videos'),
        data: {'success': true},
      ),
    );
    when(() => api.delete(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/videos/1'),
        data: {'success': true},
      ),
    );

    expect(
      (await repo.addVideo(title: 'T', videoUrl: 'https://x/v.mp4')).isSuccess,
      isTrue,
    );
    verify(
      () => api.post(
        '/user/me/videos',
        data: {
          'title': 'T',
          'video_url': 'https://x/v.mp4',
          'kind': 'game',
        },
      ),
    ).called(1);

    expect((await repo.deleteVideo('vid-1')).isSuccess, isTrue);
    verify(() => api.delete('/user/me/videos/vid-1')).called(1);
  });
}
