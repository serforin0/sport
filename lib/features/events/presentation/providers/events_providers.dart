import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/events/data/repositories/events_repository.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(ref.watch(apiClientProvider));
});

final eventsListProvider =
    AsyncNotifierProvider<EventsListNotifier, List<SportEvent>>(() {
  return EventsListNotifier();
});

final eventDetailProvider =
    FutureProvider.autoDispose.family<SportEvent, String>((ref, id) async {
  final result = await ref.watch(eventsRepositoryProvider).getEvent(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (event) => event,
  );
});

class EventsListNotifier extends AsyncNotifier<List<SportEvent>> {
  @override
  Future<List<SportEvent>> build() async {
    final result = await ref.watch(eventsRepositoryProvider).getEvents();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (events) => events,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(eventsRepositoryProvider).getEvents();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (events) => events,
      );
    });
  }

  Future<bool> participate(String eventId) async {
    final result = await ref.read(eventsRepositoryProvider).participate(eventId);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(eventDetailProvider(eventId));
        return true;
      },
    );
  }

  Future<bool> leave(String eventId) async {
    final result = await ref.read(eventsRepositoryProvider).leave(eventId);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(eventDetailProvider(eventId));
        return true;
      },
    );
  }

  Future<bool> linkActivity({
    required String eventId,
    required String activityUrl,
    String? note,
  }) async {
    final result = await ref.read(eventsRepositoryProvider).linkActivity(
          eventId: eventId,
          activityUrl: activityUrl,
          note: note,
        );
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidate(eventDetailProvider(eventId));
        return true;
      },
    );
  }

  Future<bool> save(String eventId) async {
    final result = await ref.read(eventsRepositoryProvider).save(eventId);
    return result.fold((_) => false, (_) => true);
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    final result = await ref.read(eventsRepositoryProvider).createEvent(data);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }
}
