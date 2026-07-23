import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:portuguese_survivor/core/audio/audio_cache_manager.dart';
import 'package:portuguese_survivor/core/audio/audio_failure.dart';
import 'package:portuguese_survivor/core/audio/openai_tts_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('openai_tts_provider_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('cache hit returns cached audio without network call', () async {
    var callCount = 0;

    final client = MockClient((_) async {
      callCount++;
      return http.Response.bytes(
        <int>[1, 2, 3],
        200,
        headers: <String, String>{'content-type': 'audio/mpeg'},
      );
    });
    final cache = AudioCacheManager(cacheDirectory: tempDir);
    await cache.cacheAudio(cacheKey: 'cached-key', bytes: <int>[9, 9, 9]);

    final provider = OpenAITtsProvider(
      endpoint: 'https://edge.example.dev/tts',
      cacheManager: cache,
      httpClient: client,
      cacheKeyBuilder: (text, voice, language) => 'cached-key',
    );

    final result = await provider.synthesize(text: 'Ola', voice: 'alloy');

    expect(result.isSuccess, isTrue);
    expect(callCount, 0);
  });

  test('cache miss downloads and stores MP3', () async {
    var callCount = 0;

    final client = MockClient((_) async {
      callCount++;
      return http.Response.bytes(
        <int>[11, 22, 33],
        200,
        headers: <String, String>{'content-type': 'audio/mpeg'},
      );
    });
    final cache = AudioCacheManager(cacheDirectory: tempDir);

    final provider = OpenAITtsProvider(
      endpoint: 'https://edge.example.dev/tts',
      cacheManager: cache,
      httpClient: client,
    );

    final result = await provider.synthesize(text: 'Bom dia', voice: 'alloy');

    expect(result.isSuccess, isTrue);
    expect(callCount, 1);
    expect(result.filePath, isNotNull);
    final file = File(result.filePath!);
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), <int>[11, 22, 33]);
  });

  test('retries failed requests up to success', () async {
    var callCount = 0;

    final client = MockClient((_) async {
      callCount++;
      if (callCount < 3) {
        return http.Response('temporary error', 500);
      }
      return http.Response.bytes(
        <int>[7, 8, 9],
        200,
        headers: <String, String>{'content-type': 'audio/mpeg'},
      );
    });
    final cache = AudioCacheManager(cacheDirectory: tempDir);

    final provider = OpenAITtsProvider(
      endpoint: 'https://edge.example.dev/tts',
      cacheManager: cache,
      httpClient: client,
    );

    final result = await provider.synthesize(text: 'Obrigada', voice: 'alloy');

    expect(result.isSuccess, isTrue);
    expect(callCount, 3);
  });

  test('timeout returns timeout failure after retries', () async {
    var callCount = 0;

    final client = MockClient((_) async {
      callCount++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return http.Response.bytes(
        <int>[1, 2],
        200,
        headers: <String, String>{'content-type': 'audio/mpeg'},
      );
    });
    final cache = AudioCacheManager(cacheDirectory: tempDir);

    final provider = OpenAITtsProvider(
      endpoint: 'https://edge.example.dev/tts',
      cacheManager: cache,
      httpClient: client,
      timeout: const Duration(milliseconds: 10),
    );

    final result = await provider.synthesize(text: 'Ate logo', voice: 'alloy');

    expect(result.isSuccess, isFalse);
    expect(result.failure?.type, AudioFailureType.timeout);
    expect(callCount, 3);
  });

  test('network failure returns meaningful error', () async {
    var callCount = 0;

    final client = MockClient((_) async {
      callCount++;
      throw const SocketException('No internet');
    });
    final cache = AudioCacheManager(cacheDirectory: tempDir);

    final provider = OpenAITtsProvider(
      endpoint: 'https://edge.example.dev/tts',
      cacheManager: cache,
      httpClient: client,
    );

    final result = await provider.synthesize(text: 'Boa tarde', voice: 'alloy');

    expect(result.isSuccess, isFalse);
    expect(result.failure?.type, AudioFailureType.network);
    expect(result.failure?.message, contains('Network error'));
    expect(callCount, 3);
  });

  test('supports JSON response with base64 audio payload', () async {
    final payload = base64Encode(<int>[4, 5, 6]);
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode(<String, dynamic>{'audioBase64': payload}),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });
    final cache = AudioCacheManager(cacheDirectory: tempDir);

    final provider = OpenAITtsProvider(
      endpoint: 'https://edge.example.dev/tts',
      cacheManager: cache,
      httpClient: client,
    );

    final result = await provider.synthesize(text: 'Obrigado', voice: 'alloy');

    expect(result.isSuccess, isTrue);
    expect(await File(result.filePath!).readAsBytes(), <int>[4, 5, 6]);
  });
}
