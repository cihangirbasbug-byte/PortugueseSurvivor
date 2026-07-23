enum AudioFailureType {
  timeout,
  network,
  server,
  invalidResponse,
  cache,
  unknown,
}

class AudioFailure {
  const AudioFailure({
    required this.type,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final AudioFailureType type;
  final String message;
  final int? statusCode;
  final Object? cause;
}
