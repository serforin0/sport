import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/match_result.dart';

class MatchResultCard extends StatelessWidget {
  final MatchResult match;

  const MatchResultCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Liga + deporte
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.league,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (match.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '• LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Text(
                    _sportIcon(match.sport),
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Teams and score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: [
                      _TeamBadge(badgeUrl: match.homeTeamBadge, sport: match.sport),
                      const SizedBox(height: 6),
                      Text(
                        match.homeTeam,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Score
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: match.hasScore
                      ? Column(
                          children: [
                            Text(
                              '${match.homeScore} - ${match.awayScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              match.isLive ? (match.minute ?? '') : 'FIN',
                              style: TextStyle(
                                color: match.isLive ? Colors.red : Colors.white30,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'vs',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                // Away team
                Expanded(
                  child: Column(
                    children: [
                      _TeamBadge(badgeUrl: match.awayTeamBadge, sport: match.sport),
                      const SizedBox(height: 6),
                      Text(
                        match.awayTeam,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date
            Text(
              DateFormat('dd MMM • HH:mm').format(match.date),
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _sportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'basketball':
        return '🏀';
      case 'american football':
        return '🏈';
      case 'baseball':
        return '⚾';
      case 'tennis':
        return '🎾';
      default:
        return '⚽';
    }
  }
}

class _TeamBadge extends StatelessWidget {
  final String? badgeUrl;
  final String sport;

  const _TeamBadge({this.badgeUrl, required this.sport});

  @override
  Widget build(BuildContext context) {
    if (badgeUrl != null) {
      return SizedBox(
        width: 42,
        height: 42,
        child: Image.network(
          badgeUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          sport.toLowerCase() == 'basketball' ? '🏀' : '⚽',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
