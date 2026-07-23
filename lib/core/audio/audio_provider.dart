import 'audio_failure.dart';

class AudioProviderResult {
  const AudioProviderResult.success(this.filePath) : failure = null;

  const AudioProviderResult.failure(this.failure) : filePath = null;

  final String? filePath;
  final AudioFailure? failure;

  bool get isSuccess => filePath != null;
}

abstract class AudioProvider {
  Future<AudioProviderResult> synthesize({
    required String text,
    required String voice,
    String language,
  });
}
