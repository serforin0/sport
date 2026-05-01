import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userLocation;
  final String? photoUrl;

  const StatisticsPage({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userLocation,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
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
                    : const NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop'),
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
            color: const Color(0xFF0F172A).withOpacity(0.5),
            child: const Row(
              children: [
                Expanded(flex: 2, child: _TableHeaderText('Temporada')),
                Expanded(child: _TableHeaderText('Lugar')),
                Expanded(child: _TableHeaderText('Pts')),
                Expanded(child: _TableHeaderText('Partidas')),
                Expanded(child: _TableHeaderText('Victorias')),
                Expanded(child: _TableHeaderText('Poles')),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: ListView(
              children: const [
                _StatRow(year: '2024', rank: '18', pts: '6', matches: '6', wins: '1', poles: '1'),
                _StatRow(year: '2023', rank: '18', pts: '6', matches: '6', wins: '0', poles: '0'),
                _StatRow(year: '2022', rank: '50', pts: '0', matches: '3', wins: '0', poles: '0'),
              ],
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
  final String year;
  final String rank;
  final String pts;
  final String matches;
  final String wins;
  final String poles;

  const _StatRow({
    required this.year,
    required this.rank,
    required this.pts,
    required this.matches,
    required this.wins,
    required this.poles,
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
          Expanded(flex: 2, child: _StatValueText(year, isBold: false)),
          Expanded(child: _StatValueText(rank)),
          Expanded(child: _StatValueText(pts)),
          Expanded(child: _StatValueText(matches)),
          Expanded(child: _StatValueText(wins)),
          Expanded(child: _StatValueText(poles)),
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
