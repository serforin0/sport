class MatchResult {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamBadge;
  final String? awayTeamBadge;
  final int? homeScore;
  final int? awayScore;
  final String league;
  final String sport;
  final DateTime date;
  final bool isLive;
  final String? minute; // Minute of the match if live

  const MatchResult({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamBadge,
    this.awayTeamBadge,
    this.homeScore,
    this.awayScore,
    required this.league,
    required this.sport,
    required this.date,
    this.isLive = false,
    this.minute,
  });

  bool get hasScore => homeScore != null && awayScore != null;
}
