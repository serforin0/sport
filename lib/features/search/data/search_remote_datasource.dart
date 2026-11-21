import 'package:dio/dio.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/feed/data/models/post_model.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/events/data/models/sport_event_model.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/jobs/data/models/job_offer_model.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/people/domain/people_list_user.dart';

class SearchFilters {
  final String query;
  final String? profileType;
  final String? sportId;
  final String? countryId;
  final String? city;
  final String? sportLevel;
  final String? opportunityType;
  final bool talent;
  final bool verifiedOnly;

  const SearchFilters({
    this.query = '',
    this.profileType,
    this.sportId,
    this.countryId,
    this.city,
    this.sportLevel,
    this.opportunityType,
    this.talent = false,
    this.verifiedOnly = false,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (profileType?.isNotEmpty == true) 'profile_type': profileType,
      if (sportId?.isNotEmpty == true) 'sport_id': sportId,
      if (countryId?.isNotEmpty == true) 'country_id': countryId,
      if (city?.trim().isNotEmpty == true) 'city': city!.trim(),
      if (sportLevel?.isNotEmpty == true) 'sport_level': sportLevel,
      if (opportunityType?.isNotEmpty == true) 'opportunity_type': opportunityType,
      if (talent) 'talent': 1,
      if (verifiedOnly) 'verified_only': 1,
    };
  }

  SearchFilters copyWith({
    String? query,
    String? profileType,
    String? sportId,
    String? countryId,
    String? city,
    String? sportLevel,
    String? opportunityType,
    bool? talent,
    bool? verifiedOnly,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      profileType: profileType ?? this.profileType,
      sportId: sportId ?? this.sportId,
      countryId: countryId ?? this.countryId,
      city: city ?? this.city,
      sportLevel: sportLevel ?? this.sportLevel,
      opportunityType: opportunityType ?? this.opportunityType,
      talent: talent ?? this.talent,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          query == other.query &&
          profileType == other.profileType &&
          sportId == other.sportId &&
          countryId == other.countryId &&
          city == other.city &&
          sportLevel == other.sportLevel &&
          opportunityType == other.opportunityType &&
          talent == other.talent &&
          verifiedOnly == other.verifiedOnly;

  @override
  int get hashCode => Object.hash(
        query,
        profileType,
        sportId,
        countryId,
        city,
        sportLevel,
        opportunityType,
        talent,
        verifiedOnly,
      );
}

class SponsorshipResult {
  final String id;
  final String brandName;
  final String sponsorshipType;
  final String requirements;
  final String benefits;
  final String? contact;
  final String? sportName;

  const SponsorshipResult({
    required this.id,
    required this.brandName,
    required this.sponsorshipType,
    required this.requirements,
    required this.benefits,
    this.contact,
    this.sportName,
  });

  factory SponsorshipResult.fromApi(Map<String, dynamic> json) {
    final sport = json['sport'];
    return SponsorshipResult(
      id: json['id']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? 'Marca',
      sponsorshipType: json['sponsorship_type']?.toString() ?? 'Patrocinio',
      requirements: json['requirements']?.toString() ?? '',
      benefits: json['benefits']?.toString() ?? '',
      contact: json['contact']?.toString(),
      sportName: sport is Map ? sport['name']?.toString() : sport?.toString(),
    );
  }
}

class SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSource(this.apiClient);

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<Map<String, dynamic>> userMaps, List<Post> posts, List<JobOffer> opportunities, List<SportEvent> events, List<SponsorshipResult> sponsorships})> _searchRaw(
    String token,
    SearchFilters filters,
    String currentUserId,
  ) async {
    final qp = filters.toQueryParameters();
    final response = await apiClient.get(
      '/search',
      queryParameters: qp,
      options: _auth(token),
    );

    List<dynamic> userList = [];
    List<dynamic> postList = [];
    List<dynamic> opportunityList = [];
    List<dynamic> eventList = [];
    List<dynamic> sponsorshipList = [];

    void takeFromMap(Map<String, dynamic> m) {
      final u = m['users'] ?? m['user'];
      final p = m['posts'] ?? m['post'];
      final o = m['opportunities'] ?? m['jobs'] ?? m['job_offers'];
      final ev = m['events'];
      final sp = m['sponsorships'];
      if (u is List) userList = u;
      if (p is List) postList = p;
      if (o is List) opportunityList = o;
      if (ev is List) eventList = ev;
      if (sp is List) sponsorshipList = sp;
    }

    final root = response.data;
    if (root is Map) {
      final data = root['data'];
      if (data is Map) {
        takeFromMap(Map<String, dynamic>.from(data));
      } else {
        takeFromMap(Map<String, dynamic>.from(root));
      }
    }

    if (userList.isEmpty && postList.isEmpty) {
      final unwrapped = unwrapDataMap(root);
      if (unwrapped != null) {
        takeFromMap(unwrapped);
      }
    }

    final userMaps =
        userList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

    final posts = postList
        .whereType<Map>()
        .map((e) => PostModel.fromApi(Map<String, dynamic>.from(e), currentUserId: currentUserId))
        .toList();

    final opportunities = opportunityList
        .whereType<Map>()
        .map((e) => JobOfferModel.fromApi(Map<String, dynamic>.from(e)))
        .toList();

    final events = eventList
        .whereType<Map>()
        .map((e) => SportEventModel.fromApi(Map<String, dynamic>.from(e)))
        .toList();

    final sponsorships = sponsorshipList
        .whereType<Map>()
        .map((e) => SponsorshipResult.fromApi(Map<String, dynamic>.from(e)))
        .toList();

    return (
      userMaps: userMaps,
      posts: posts,
      opportunities: opportunities,
      events: events,
      sponsorships: sponsorships,
    );
  }

  Future<({List<UserModel> users, List<Post> posts, List<JobOffer> opportunities, List<SportEvent> events, List<SponsorshipResult> sponsorships})> search(
    String token,
    SearchFilters filters, {
    required String currentUserId,
  }) async {
    final raw = await _searchRaw(token, filters, currentUserId);
    final users = raw.userMaps.map(UserModel.fromMap).toList();
    return (
      users: users,
      posts: raw.posts,
      opportunities: raw.opportunities,
      events: raw.events,
      sponsorships: raw.sponsorships,
    );
  }

  /// Sugerencias: mismo endpoint sin `q` (si el backend lo permite).
  Future<List<PeopleListUser>> searchPeopleSuggestions(
    String token,
    String currentUserId,
  ) async {
    final raw = await _searchRaw(token, const SearchFilters(), currentUserId);
    return raw.userMaps.map(PeopleListUser.fromApiMap).toList();
  }
}
