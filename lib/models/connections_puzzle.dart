import 'dart:convert';
import 'package:flutter/services.dart';

class ConnectionsGroup {
  final String category;
  final String color;
  final List<String> items;

  const ConnectionsGroup({
    required this.category,
    required this.color,
    required this.items,
  });

  factory ConnectionsGroup.fromJson(Map<String, dynamic> json) {
    return ConnectionsGroup(
      category: json['category'] as String,
      color: json['color'] as String,
      items: (json['items'] as List).cast<String>(),
    );
  }
}

class ConnectionsPuzzle {
  final int id;
  final List<ConnectionsGroup> groups;

  const ConnectionsPuzzle({required this.id, required this.groups});

  factory ConnectionsPuzzle.fromJson(Map<String, dynamic> json) {
    return ConnectionsPuzzle(
      id: json['id'] as int,
      groups: (json['groups'] as List)
          .map((g) => ConnectionsGroup.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }

  /// All 16 items across all groups.
  List<String> get allItems => groups.expand((g) => g.items).toList();

  /// Find which group an item belongs to.
  ConnectionsGroup? groupForItem(String item) {
    for (final group in groups) {
      if (group.items.contains(item)) return group;
    }
    return null;
  }

  /// Check if 4 selected items all belong to the same group.
  ConnectionsGroup? checkGuess(List<String> selected) {
    if (selected.length != 4) return null;
    final group = groupForItem(selected.first);
    if (group == null) return null;
    if (selected.every((item) => group.items.contains(item))) {
      return group;
    }
    return null;
  }

  static Future<List<ConnectionsPuzzle>> loadAll() async {
    final raw = await rootBundle.loadString('assets/data/connections_puzzles.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['puzzles'] as List)
        .map((p) => ConnectionsPuzzle.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
