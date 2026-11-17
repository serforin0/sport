import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userLocation;
  final String? photoUrl;
  final List<dynamic>? stats;

  const StatisticsPage({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userLocation,
    this.photoUrl,
    this.stats,
  });

  List<Map<String, String>> _rows() {
    return (stats ?? [])
        .whereType<Map>()
        .map(
          (item) => {
            'season': (item['season'] ?? item['year'] ?? item['label'] ?? '')
                .toString(),
            'rank': (item['rank'] ?? item['position'] ?? '').toString(),
            'points': (item['points'] ?? item['pts'] ?? item['value'] ?? '')
                .toString(),
            'matches': (item['matches'] ?? item['games'] ?? '').toString(),
            'wins': (item['wins'] ?? '').toString(),
            'podiums': (item['podiums'] ?? item['poles'] ?? '').toString(),
          },
        )
        .where((item) => item.values.any((value) => value.isNotEmpty))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Estadísticas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // User Mini Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, color: Colors.white54)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$userRole • $userLocation',
                        style: const TextStyle(
                          color: Color(0xFF2CB5FF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFF0F172A).withValues(alpha: 0.5),
            child: const Row(
              children: [
                Expanded(flex: 2, child: _TableHeaderText('Temporada')),
                Expanded(child: _TableHeaderText('Lugar')),
                Expanded(child: _TableHeaderText('Pts')),
                Expanded(child: _TableHeaderText('Partidas')),
                Expanded(child: _TableHeaderText('Victorias')),
                Expanded(child: _TableHeaderText('Podios')),
              ],
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aún no hay estadísticas registradas para este perfil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                : ListView(
                    children: rows
                        .map(
                          (row) => _StatRow(
                            season: row['season'] ?? '',
                            rank: row['rank'] ?? '',
                            points: row['points'] ?? '',
                            matches: row['matches'] ?? '',
                            wins: row['wins'] ?? '',
                            podiums: row['podiums'] ?? '',
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _StatRow extends StatelessWidget {
  final String season;
  final String rank;
  final String points;
  final String matches;
  final String wins;
  final String podiums;

  const _StatRow({
    required this.season,
    required this.rank,
    required this.points,
    required this.matches,
    required this.wins,
    required this.podiums,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _StatValueText(season, isBold: false)),
          Expanded(child: _StatValueText(rank)),
          Expanded(child: _StatValueText(points)),
          Expanded(child: _StatValueText(matches)),
          Expanded(child: _StatValueText(wins)),
          Expanded(child: _StatValueText(podiums)),
        ],
      ),
    );
  }
}

class _StatValueText extends StatelessWidget {
  final String text;
  final bool isBold;
  const _StatValueText(this.text, {this.isBold = true});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }
}
