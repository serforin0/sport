import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/people/domain/people_list_user.dart';
import '../../data/search_remote_datasource.dart';

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSource(ref.watch(apiClientProvider));
});

final searchResultsProvider =
    FutureProvider.family<({List<UserModel> users, List<Post> posts, List<JobOffer> opportunities, List<SportEvent> events, List<SponsorshipResult> sponsorships}), SearchFilters>((ref, filters) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString('auth_token');
  if (token == null) {
    return (
      users: <UserModel>[],
      posts: <Post>[],
      opportunities: <JobOffer>[],
      events: <SportEvent>[],
      sponsorships: <SponsorshipResult>[],
    );
  }
  final myId = ref.watch(authControllerProvider).valueOrNull?.id ?? '';
  return ref.watch(searchRemoteDataSourceProvider).search(token, filters, currentUserId: myId);
});

/// Sugerencias en Personas (`GET /search` sin `q` si el backend lo admite).
final peopleSuggestionsProvider = FutureProvider<List<PeopleListUser>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString('auth_token');
  if (token == null) return [];
  final myId = ref.watch(authControllerProvider).valueOrNull?.id ?? '';
  return ref.watch(searchRemoteDataSourceProvider).searchPeopleSuggestions(token, myId);
});
