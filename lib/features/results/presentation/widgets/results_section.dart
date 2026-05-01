import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/match_result.dart';
import '../providers/results_providers.dart';
import 'match_result_card.dart';
import 'match_result_skeleton.dart';

// Sport filter options
const _sportFilters = ['Todos', 'Fútbol', 'Basketball'];

class ResultsSection extends ConsumerWidget {
  const ResultsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(recentResultsProvider);
    final selected = ref.watch(selectedSportProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resultados Recientes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sports_soccer, color: Color(0xFF3B82F6), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Sport filter pills ──
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _sportFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = _sportFilters[index];
              final isActive = selected == label;
              return GestureDetector(
                onTap: () => ref.read(selectedSportProvider.notifier).state = label,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF3B82F6)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ── Cards carousel ──
        SizedBox(
          height: 210,
          child: resultsAsync.when(
            data: (all) {
              final results = _filter(all, selected);
              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports, color: Colors.white12, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'No hay resultados de $selected',
                        style: const TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (context, index) =>
                    MatchResultCard(match: results[index]),
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => const MatchResultSkeleton(),
            ),
            error: (_, __) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_outlined, color: Colors.white12, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'No se pudieron cargar los resultados',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(recentResultsProvider),
                    child: const Text('Reintentar',
                        style: TextStyle(color: Color(0xFF3B82F6))),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<MatchResult> _filter(List<MatchResult> all, String selected) {
    if (selected == 'Todos') return all;
    
    final selLower = selected.toLowerCase();
    
    if (selLower == 'fútbol') {
      return all.where((m) {
        final s = m.sport.toLowerCase();
        return s == 'soccer' || s == 'fútbol' || s == 'futbol';
      }).toList();
    }
    
    if (selLower == 'basketball') {
      return all.where((m) {
        final s = m.sport.toLowerCase();
        return s == 'basketball' || s == 'baloncesto' || s == 'básquetbol' || s == 'basquetbol';
      }).toList();
    }
    
    return all;
  }
}
