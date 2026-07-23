import 'dart:io';

class AudioCacheManager {
  AudioCacheManager({required this._cacheDirectory});

  final Directory _cacheDirectory;

  Future<String?> getCachedAudioPath(String cacheKey) async {
    final file = File(_buildPath(cacheKey));
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<String> cacheAudio({
    required String cacheKey,
    required List<int> bytes,
  }) async {
    if (!await _cacheDirectory.exists()) {
      await _cacheDirectory.create(recursive: true);
    }

    final file = File(_buildPath(cacheKey));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _buildPath(String cacheKey) {
    return '${_cacheDirectory.path}${Platform.pathSeparator}$cacheKey.mp3';
  }
}
