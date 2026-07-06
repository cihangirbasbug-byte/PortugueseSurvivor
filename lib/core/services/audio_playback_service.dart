abstract class AudioPlaybackService {
  Future<void> prepareForMission(String missionId);
  Future<void> playSceneCue(String cueId);
  Future<void> stop();
}

class NoopAudioPlaybackService implements AudioPlaybackService {
  @override
  Future<void> prepareForMission(String missionId) async {}

  @override
  Future<void> playSceneCue(String cueId) async {}

  @override
  Future<void> stop() async {}
}
