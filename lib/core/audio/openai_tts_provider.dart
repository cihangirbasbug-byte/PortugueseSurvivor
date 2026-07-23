import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'audio_cache_manager.dart';
import 'audio_failure.dart';
import 'audio_provider.dart';

class OpenAITtsProvider implements AudioProvider {
  OpenAITtsProvider({
    required String endpoint,
    required this._cacheManager,
    http.Client? httpClient,
    this._timeout = const Duration(seconds: 12),
    this._maxAttempts = 3,
    this._cacheKeyBuilder,
  }) : _endpoint = Uri.parse(endpoint),
       _httpClient = httpClient ?? http.Client();

  final Uri _endpoint;
  final AudioCacheManager _cacheManager;
  final http.Client _httpClient;
  final Duration _timeout;
  final int _maxAttempts;
  final String Function(String text, String voice, String language)?
  _cacheKeyBuilder;

  @override
  Future<AudioProviderResult> synthesize({
    required String text,
    required String voice,
    String language = 'pt-PT',
  }) async {
    final cacheKey =
      _cacheKeyBuilder?.call(text, voice, language) ??
      _buildCacheKey(text: text, voice: voice, language: language);

    try {
      final cachedPath = await _cacheManager.getCachedAudioPath(cacheKey);
      if (cachedPath != null) {
        return AudioProviderResult.success(cachedPath);
      }
    } on Object catch (error) {
      return AudioProviderResult.failure(
        AudioFailure(
          type: AudioFailureType.cache,
          message: 'Failed to read audio cache.',
          cause: error,
        ),
      );
    }

    AudioFailure? lastFailure;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final payload = <String, dynamic>{
          'text': text,
          'voice': voice,
          'language': language,
          'format': 'mp3',
          'provider': 'openai',
        };

        final response = await _httpClient
            .post(
              _endpoint,
              headers: const <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
            .timeout(_timeout);

        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastFailure = AudioFailure(
            type: AudioFailureType.server,
            message: 'TTS endpoint returned an error.',
            statusCode: response.statusCode,
          );
          continue;
        }

        final mp3Bytes = await _extractMp3Bytes(response);
        final savedPath = await _cacheManager.cacheAudio(
          cacheKey: cacheKey,
          bytes: mp3Bytes,
        );

        return AudioProviderResult.success(savedPath);
      } on TimeoutException catch (error) {
        lastFailure = AudioFailure(
          type: AudioFailureType.timeout,
          message: 'TTS request timed out.',
          cause: error,
        );
      } on SocketException catch (error) {
        lastFailure = AudioFailure(
          type: AudioFailureType.network,
          message: 'Network error while requesting TTS audio.',
          cause: error,
        );
      } on FormatException catch (error) {
        lastFailure = AudioFailure(
          type: AudioFailureType.invalidResponse,
          message: 'Invalid TTS response format.',
          cause: error,
        );
      } on HttpException catch (error) {
        lastFailure = AudioFailure(
          type: AudioFailureType.network,
          message: 'Failed to download generated MP3.',
          cause: error,
        );
      } on Object catch (error) {
        lastFailure = AudioFailure(
          type: AudioFailureType.unknown,
          message: 'Unexpected TTS provider error.',
          cause: error,
        );
      }
    }

    return AudioProviderResult.failure(
      lastFailure ??
          const AudioFailure(
            type: AudioFailureType.unknown,
            message: 'TTS failed for unknown reasons.',
          ),
    );
  }

  Future<List<int>> _extractMp3Bytes(http.Response response) async {
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.startsWith('audio/')) {
      return response.bodyBytes;
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Response JSON must be an object.');
    }

    final base64Audio = decoded['audioBase64'] ?? decoded['audio_base64'];
    if (base64Audio is String && base64Audio.isNotEmpty) {
      return base64Decode(base64Audio);
    }

    final audioUrl = decoded['audioUrl'] ?? decoded['audio_url'];
    if (audioUrl is! String || audioUrl.isEmpty) {
      throw const FormatException('Response must contain audioUrl or audioBase64.');
    }

    final downloadResponse = await _httpClient
        .get(Uri.parse(audioUrl))
        .timeout(_timeout);

    if (downloadResponse.statusCode < 200 || downloadResponse.statusCode >= 300) {
      throw HttpException('MP3 download failed with status ${downloadResponse.statusCode}.');
    }

    return downloadResponse.bodyBytes;
  }

  String _buildCacheKey({
    required String text,
    required String voice,
    required String language,
  }) {
    final source = '$language|$voice|$text';
    return sha1.convert(utf8.encode(source)).toString();
  }
}
