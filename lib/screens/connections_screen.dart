import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/connections_puzzle.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  ConnectionsPuzzle? _puzzle;
  List<String> _remainingItems = [];
  Set<String> _selected = {};
  List<ConnectionsGroup> _solvedGroups = [];
  int _lives = 4;
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final puzzles = await ConnectionsPuzzle.loadAll();
    if (puzzles.isEmpty) return;
    final puzzle = puzzles[Random().nextInt(puzzles.length)];
    final items = puzzle.allItems..shuffle();
    setState(() {
      _puzzle = puzzle;
      _remainingItems = items;
      _loading = false;
    });
  }

  void _toggleItem(String item) {
    setState(() {
      _message = null;
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else if (_selected.length < 4) {
        _selected.add(item);
      }
    });
  }

  void _submitGuess() {
    if (_selected.length != 4 || _puzzle == null) return;

    final group = _puzzle!.checkGuess(_selected.toList());
    if (group != null) {
      // Correct!
      setState(() {
        _solvedGroups.add(group);
        _remainingItems.removeWhere((item) => group.items.contains(item));
        _selected.clear();
        _message = null;
      });
    } else {
      // Wrong
      setState(() {
        _lives--;
        _message = 'Not quite...';
        _selected.clear();
      });
    }
  }

  Color _colorForGroup(String color) {
    switch (color) {
      case 'yellow':
        return const Color(0xFFF9DF6D);
      case 'green':
        return const Color(0xFFA0C35A);
      case 'blue':
        return const Color(0xFFB0C4EF);
      case 'purple':
        return const Color(0xFFBA81C5);
      default:
        return AppTheme.missGray;
    }
  }

  bool get _won => _solvedGroups.length == 4;
  bool get _lost => _lives <= 0;
  bool get _gameOver => _won || _lost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Connections'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Lives
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: i < _lives ? AppTheme.mizzouGold : Colors.white24,
                        ),
                      )),
                    ),
                    const SizedBox(height: 16),

                    // Solved groups
                    ..._solvedGroups.map((group) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _colorForGroup(group.color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              group.category,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              group.items.join(', '),
                              style: const TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )),

                    // Grid of remaining items
                    if (!_gameOver)
                      Expanded(
                        child: _buildGrid(),
                      ),

                    // Game over state
                    if (_gameOver) ...[
                      const Spacer(),
                      Text(
                        _won ? 'Nice!' : 'Better luck next time',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _won ? AppTheme.mizzouGold : Colors.redAccent,
                        ),
                      ),
                      if (_lost) ...[
                        const SizedBox(height: 12),
                        // Reveal unsolved groups
                        ...(_puzzle!.groups.where((g) => !_solvedGroups.contains(g))).map((group) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _colorForGroup(group.color).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(group.category, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(group.items.join(', '), style: const TextStyle(color: Colors.black87, fontSize: 12), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _solvedGroups.clear();
                            _selected.clear();
                            _lives = 4;
                            _message = null;
                            _loading = true;
                          });
                          _loadPuzzle();
                        },
                        child: const Text('Play Again'),
                      ),
                      const Spacer(),
                    ],

                    // Message
                    if (_message != null && !_gameOver)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_message!, style: const TextStyle(color: Colors.redAccent)),
                      ),

                    // Submit button
                    if (!_gameOver)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton(
                          onPressed: _selected.length == 4 ? _submitGuess : null,
                          child: const Text('Submit'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: _remainingItems.length,
      itemBuilder: (context, index) {
        final item = _remainingItems[index];
        final isSelected = _selected.contains(item);
        return GestureDetector(
          onTap: () => _toggleItem(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.mizzouGold : AppTheme.missGray,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppTheme.mizzouGold, width: 2)
                  : null,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Colors.black : AppTheme.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
