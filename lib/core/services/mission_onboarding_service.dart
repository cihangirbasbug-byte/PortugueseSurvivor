import 'package:shared_preferences/shared_preferences.dart';

class MissionOnboardingService {
  static const String _mission001DoneKey = 'onboarding_mission_001_done';

  Future<bool> shouldShow(String missionId) async {
    if (missionId != 'mission_001') {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_mission001DoneKey) ?? false);
  }

  Future<void> markCompleted(String missionId) async {
    if (missionId != 'mission_001') {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mission001DoneKey, true);
  }
}
