import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../models/enums.dart';
import '../models/player.dart';
import '../providers/player_repository_provider.dart';

class PlayerListScreen extends StatelessWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Pool'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final repoAsync = ref.watch(playerRepositoryProvider(Sport.basketball));
          return repoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading players')),
            data: (repo) {
              final players = List<Player>.from(repo.players)
                ..sort((a, b) => b.startYear.compareTo(a.startYear));
              return _PlayerList(players: players);
            },
          );
        },
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.players});
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    // Group by decade-ish ranges
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final ht = "${player.height ~/ 12}'${player.height % 12}\"";
        final years = "'${(player.startYear % 100).toString().padLeft(2, '0')}-'${(player.endYear % 100).toString().padLeft(2, '0')}";

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  player.fullName,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  player.position,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  ht,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 55,
                child: Text(
                  years,
                  style: const TextStyle(color: AppTheme.mizzouGold, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
