import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mission_model.dart';

class MissionRepository {
  Future<MissionModel> loadMission(String id) async {
    final String data = await _loadMissionJson(id);
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    return MissionModel.fromJson(decoded);
  }

  Future<String> _loadMissionJson(String id) async {
    final paths = <String>[
      'missions/chapter_01/$id.json',
      'missions/$id.json',
      'assets/missions/chapter_01/$id.json',
      'assets/missions/$id.json',
    ];

    for (final path in paths) {
      try {
        return await rootBundle.loadString(path);
      } catch (_) {
        // Try the next known mission path.
      }
    }

    throw Exception('Mission asset not found: $id');
  }

  Future<Map<String, dynamic>> loadProgress(String missionId) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'completed': prefs.getBool('${missionId}_completed') ?? false,
      'xpEarned': prefs.getInt('${missionId}_xp') ?? 0,
      'courageEarned': prefs.getInt('${missionId}_courage') ?? 0,
    };
  }

  Future<void> saveProgress(
    String missionId, {
    required bool completed,
    required int xpEarned,
    required int courageEarned,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${missionId}_completed', completed);
    await prefs.setInt('${missionId}_xp', xpEarned);
    await prefs.setInt('${missionId}_courage', courageEarned);
  }
}
