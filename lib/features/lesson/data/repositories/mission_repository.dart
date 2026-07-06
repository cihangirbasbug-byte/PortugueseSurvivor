import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mission_model.dart';

class MissionRepository {
  static const int chapter01MissionCount = 10;

  Future<MissionModel> loadMission(String id) async {
    final String data = await _loadMissionJson(id);
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    return MissionModel.fromJson(decoded);
  }

  Future<List<MissionModel>> loadChapter01Missions() async {
    final futures = List<Future<MissionModel>>.generate(
      chapter01MissionCount,
      (index) => loadMission(_missionIdFromNumber(index + 1)),
    );
    return Future.wait(futures);
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
      'unlocked': prefs.getBool('${missionId}_unlocked') ?? missionId == 'mission_001',
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

    if (completed) {
      await prefs.setBool('${missionId}_unlocked', true);
      final nextMissionId = _nextMissionId(missionId);
      if (nextMissionId != null) {
        await prefs.setBool('${nextMissionId}_unlocked', true);
      }
    }
  }

  String _missionIdFromNumber(int missionNumber) {
    final number = missionNumber.toString().padLeft(3, '0');
    return 'mission_$number';
  }

  String? _nextMissionId(String missionId) {
    final match = RegExp(r'^mission_(\d{3})$').firstMatch(missionId);
    if (match == null) return null;

    final current = int.tryParse(match.group(1)!);
    if (current == null) return null;
    if (current >= chapter01MissionCount) return null;

    return _missionIdFromNumber(current + 1);
  }
}
