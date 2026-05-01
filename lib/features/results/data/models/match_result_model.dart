import '../../domain/entities/match_result.dart';

class MatchResultModel extends MatchResult {
  const MatchResultModel({
    required super.id,
    required super.homeTeam,
    required super.awayTeam,
    super.homeTeamBadge,
    super.awayTeamBadge,
    super.homeScore,
    super.awayScore,
    required super.league,
    required super.sport,
    required super.date,
    super.isLive,
    super.minute,
  });

  /// Parses an event from TheSportsDB API response
  factory MatchResultModel.fromTheSportsDB(Map<String, dynamic> json) {
    int? homeScore;
    int? awayScore;

    if (json['intHomeScore'] != null && json['intHomeScore'] != '') {
      homeScore = int.tryParse(json['intHomeScore'].toString());
    }
    if (json['intAwayScore'] != null && json['intAwayScore'] != '') {
      awayScore = int.tryParse(json['intAwayScore'].toString());
    }

    DateTime date;
    try {
      final dateStr = json['dateEvent'] ?? '';
      final timeStr = json['strTime'] ?? '00:00:00';
      date = DateTime.parse('${dateStr}T$timeStr');
    } catch (_) {
      date = DateTime.now();
    }

    return MatchResultModel(
      id: json['idEvent']?.toString() ?? '',
      homeTeam: (json['strHomeTeam'] ?? json['strHomeTeamName'] ?? json['strTeamHome'] ?? '').toString(),
      awayTeam: (json['strAwayTeam'] ?? json['strAwayTeamName'] ?? json['strTeamAway'] ?? '').toString(),
      homeTeamBadge: json['strHomeTeamBadge'] ?? json['strTeamBadge'] ?? json['strBadge'],
      awayTeamBadge: json['strAwayTeamBadge'] ?? json['strTeamBadge'] ?? json['strBadge'],
      homeScore: homeScore,
      awayScore: awayScore,
      league: json['strLeague'] ?? '',
      sport: json['strSport'] ?? 'Soccer',
      date: date,
      isLive: json['strStatus'] == 'Match Finished' ? false : (homeScore != null && json['strStatus'] != 'Match Finished'),
    );
  }

  /// Respuesta de `GET /sport/results` (estructura flexible).
  factory MatchResultModel.fromHubApi(Map<String, dynamic> json) {
    int? parseScore(dynamic v) {
      if (v == null) return null;
      return int.tryParse(v.toString());
    }

    DateTime date;
    final dateRaw = json['date'] ?? json['played_at'] ?? json['match_date'] ?? json['event_date'];
    try {
      date = dateRaw != null ? DateTime.parse(dateRaw.toString()) : DateTime.now();
    } catch (_) {
      date = DateTime.now();
    }

    final sportObj = json['sport'];
    String sportName = 'Deporte';
    if (sportObj is Map) {
      sportName = sportObj['name']?.toString() ?? 'Deporte';
    } else if (json['sport'] != null) {
      sportName = json['sport'].toString();
    }

    return MatchResultModel(
      id: json['id']?.toString() ?? '',
      homeTeam: (json['team_a'] ?? json['home_team'] ?? json['homeTeam'] ?? json['strHomeTeam'] ?? '').toString(),
      awayTeam: (json['team_b'] ?? json['away_team'] ?? json['awayTeam'] ?? json['strAwayTeam'] ?? '').toString(),
      homeTeamBadge: json['home_team_badge']?.toString() ?? json['homeTeamBadge']?.toString(),
      awayTeamBadge: json['away_team_badge']?.toString() ?? json['awayTeamBadge']?.toString(),
      homeScore: parseScore(json['score_a'] ?? json['home_score'] ?? json['homeScore'] ?? json['intHomeScore']),
      awayScore: parseScore(json['score_b'] ?? json['away_score'] ?? json['awayScore'] ?? json['intAwayScore']),
      league: (json['league'] ?? json['competition'] ?? json['strLeague'] ?? '').toString(),
      sport: sportName,
      date: date,
      isLive: json['is_live'] == true || json['live'] == true || json['status'] == 'live',
      minute: json['minute']?.toString(),
    );
  }
}
