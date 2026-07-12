import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mission_model.dart';
import 'mission_validation_helper.dart';

class MissionRepository {
  Map<String, dynamic>? _assetManifestCache;

  Future<MissionModel> loadMission(String id, {String? chapterId}) async {
    final String data = await _loadMissionJson(id, chapterId: chapterId);
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    final source = chapterId == null ? id : '$chapterId/$id';
    MissionValidationHelper.validateMissionJson(decoded, sourcePath: source);
    return MissionModel.fromJson(decoded);
  }

  Future<List<MissionModel>> loadChapterMissions(String chapterId) async {
    final manifest = await _loadAssetManifest();
    final chapterMissionIds = manifest.keys
        .cast<String>()
        .map((key) => key.replaceAll('\\', '/'))
        .map((key) {
          final marker = 'missions/$chapterId/';
          final markerIndex = key.indexOf(marker);
          if (markerIndex < 0 || !key.endsWith('.json')) {
            return null;
          }

          final fileName = key.substring(markerIndex + marker.length);
          final missionMatch = RegExp(r'^(mission_\d{3})\.json$').firstMatch(fileName);
          return missionMatch?.group(1);
        })
        .whereType<String>()
        .toSet()
        .toList()
      ..sort((a, b) => _missionSortKey(a).compareTo(_missionSortKey(b)));

    if (chapterMissionIds.isNotEmpty) {
      final missions = <MissionModel>[];
      for (final missionId in chapterMissionIds) {
        try {
          missions.add(await loadMission(missionId, chapterId: chapterId));
        } catch (error) {
          if (error is FormatException) {
            rethrow;
          }
          if (chapterId == 'chapter_01') {
            missions.add(await loadMission(missionId));
          }
        }
      }
      return missions;
    }

    final missions = <MissionModel>[];
    var useLegacyPaths = false;
    var misses = 0;

    final maxFallbackMission = chapterId == 'chapter_01' ? 10 : 999;
    for (var i = 1; i <= maxFallbackMission; i++) {
      final missionId = 'mission_${i.toString().padLeft(3, '0')}';
      if (useLegacyPaths) {
        try {
          final mission = await loadMission(missionId);
          missions.add(mission);
          misses = 0;
          continue;
        } catch (_) {
          break;
        }
      }

      try {
        final mission = await loadMission(missionId, chapterId: chapterId);
        missions.add(mission);
        misses = 0;
      } catch (error) {
        if (error is FormatException) {
          rethrow;
        }
        if (chapterId == 'chapter_01') {
          try {
            final legacyMission = await loadMission(missionId);
            missions.add(legacyMission);
            useLegacyPaths = true;
            misses = 0;
            continue;
          } catch (legacyError) {
            if (legacyError is FormatException) {
              rethrow;
            }
            // Continue to standard miss handling.
          }
        }

        misses += 1;
        if (misses >= 1) {
          break;
        }
      }
    }

    missions.sort((a, b) => _missionSortKey(a.id).compareTo(_missionSortKey(b.id)));
    return missions;
  }

  Future<String?> findMissionChapter(String missionId) async {
    final manifest = await _loadAssetManifest();
    final keys = manifest.keys.cast<String>();
    final regex = RegExp(r'missions\/(chapter_\d{2})\/' + missionId + r'\.json$');

    for (final key in keys) {
      final normalized = key.replaceAll('\\', '/');
      final match = regex.firstMatch(normalized);
      if (match != null) {
        return match.group(1);
      }
    }

    for (var i = 1; i <= 99; i++) {
      final chapterId = 'chapter_${i.toString().padLeft(2, '0')}';
      try {
        await loadMission(missionId, chapterId: chapterId);
        return chapterId;
      } catch (error) {
        if (error is FormatException) {
          rethrow;
        }
        // Continue probing chapters.
      }
    }

    return null;
  }

  Future<List<String>> loadAvailableChapters() async {
    final manifest = await _loadAssetManifest();
    final chapterSet = <String>{};

    final keys = manifest.keys.cast<String>();
    for (final key in keys) {
      final normalized = key.replaceAll('\\', '/');
      final match = RegExp(r'missions\/(chapter_\d{2})\/mission_\d{3}\.json$').firstMatch(normalized);
      if (match != null) {
        chapterSet.add(match.group(1)!);
      }
    }

    if (chapterSet.isEmpty) {
      for (var i = 1; i <= 99; i++) {
        final chapterId = 'chapter_${i.toString().padLeft(2, '0')}';
        try {
          await loadMission('mission_001', chapterId: chapterId);
          chapterSet.add(chapterId);
        } catch (error) {
          if (error is FormatException) {
            rethrow;
          }
          // Ignore non-existing chapters.
        }
      }
    }

    if (chapterSet.isEmpty) {
      try {
        await loadMission('mission_001');
        chapterSet.add('chapter_01');
      } catch (_) {
        // Ignore when even legacy chapter_01 fallback is unavailable.
      }

      for (var i = 1; i <= 99; i++) {
        final chapterId = 'chapter_${i.toString().padLeft(2, '0')}';
        final candidatePaths = <String>[
          'assets/missions/$chapterId/mission_001.json',
          'missions/$chapterId/mission_001.json',
        ];
        final exists = await _pathExists(candidatePaths);
        if (exists) {
          chapterSet.add(chapterId);
        }
      }
    }

    final chapters = chapterSet.toList()..sort();
    return chapters;
  }

  Future<String> _loadMissionJson(String id, {String? chapterId}) async {
    final paths = await _pathCandidatesForId(id, chapterId: chapterId);

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
  }

  Future<void> setMissionUnlocked(String missionId, bool unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${missionId}_unlocked', unlocked);
  }

  Future<Map<String, dynamic>> _loadAssetManifest() async {
    if (_assetManifestCache != null) {
      return _assetManifestCache!;
    }

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      _assetManifestCache = {for (final key in assets) key: const <String>[]};
    } catch (_) {
      _assetManifestCache = <String, dynamic>{};
    }
    return _assetManifestCache!;
  }

  Future<List<String>> _pathCandidatesForId(String id, {String? chapterId}) async {
    final directPaths = <String>[];
    if (chapterId != null && chapterId.isNotEmpty) {
      directPaths.addAll([
        'missions/$chapterId/$id.json',
      ]);
    } else {
      directPaths.addAll([
        'missions/chapter_01/$id.json',
        'missions/$id.json',
      ]);
    }

    final manifest = await _loadAssetManifest();
    final discovered = manifest.keys
        .cast<String>()
        .where((key) {
          final normalized = key.replaceAll('\\', '/');
          if (chapterId != null && chapterId.isNotEmpty) {
            return normalized.endsWith('/$chapterId/$id.json');
          }
          return normalized.endsWith('/$id.json');
        })
        .toList()
      ..sort();

    return [...directPaths, ...discovered];
  }

  int _missionSortKey(String value) {
    final match = RegExp(r'mission_(\d{3})').firstMatch(value);
    return int.tryParse(match?.group(1) ?? '') ?? 999999;
  }

  Future<bool> _pathExists(List<String> candidates) async {
    for (final path in candidates) {
      try {
        await rootBundle.loadString(path);
        return true;
      } catch (_) {
        // Try next path candidate.
      }
    }
    return false;
  }
}
