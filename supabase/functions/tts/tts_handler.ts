type TtsRequest = {
  text: string;
  voice: string;
  language?: string;
};

type ErrorBody = {
  error: {
    code: string;
    message: string;
    retryable: boolean;
    request_id: string;
  };
};

const OPENAI_SPEECH_URL = "https://api.openai.com/v1/audio/speech";
const DEFAULT_LANGUAGE = "pt-PT";
const MODEL = "gpt-4o-mini-tts";
const MAX_ATTEMPTS = 3;
const REQUEST_TIMEOUT_MS = 15_000;
const MAX_TEXT_LENGTH = 4_000;

export function createTtsHandler(fetcher: typeof fetch = fetch) {
  return async (request: Request): Promise<Response> => {
    const requestId = crypto.randomUUID();

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(request.headers.get("origin")),
      });
    }

    if (request.method !== "POST") {
      return jsonError({
        origin: request.headers.get("origin"),
        requestId,
        status: 405,
        code: "method_not_allowed",
        message: "Only POST is supported.",
        retryable: false,
      });
    }

    const contentType = request.headers.get("content-type") ?? "";
    if (!contentType.toLowerCase().includes("application/json")) {
      return jsonError({
        origin: request.headers.get("origin"),
        requestId,
        status: 415,
        code: "unsupported_media_type",
        message: "Content-Type must be application/json.",
        retryable: false,
      });
    }

    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return jsonError({
        origin: request.headers.get("origin"),
        requestId,
        status: 400,
        code: "invalid_json",
        message: "Malformed JSON request body.",
        retryable: false,
      });
    }

    const validation = validateRequest(body);
    if (!validation.ok) {
      return jsonError({
        origin: request.headers.get("origin"),
        requestId,
        status: 400,
        code: "invalid_request",
        message: validation.message,
        retryable: false,
      });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return jsonError({
        origin: request.headers.get("origin"),
        requestId,
        status: 500,
        code: "server_misconfigured",
        message: "OPENAI_API_KEY is not configured.",
        retryable: false,
      });
    }

    const { text, voice, language } = validation.data;
    const input = buildTtsInput(text, language ?? DEFAULT_LANGUAGE);

    const upstream = await callOpenAiWithRetry({
      apiKey,
      voice,
      input,
      requestId,
      fetcher,
    });

    if (!upstream.ok) {
      return jsonError({
        origin: request.headers.get("origin"),
        requestId,
        status: upstream.status,
        code: upstream.code,
        message: upstream.message,
        retryable: upstream.retryable,
        retryAfterSeconds: upstream.retryAfterSeconds,
      });
    }

    const headers = corsHeaders(request.headers.get("origin"));
    headers.set("Content-Type", "audio/mpeg");
    headers.set("Content-Length", String(upstream.audioBytes.byteLength));
    headers.set("Cache-Control", "no-store");
    headers.set("X-Request-Id", requestId);

    return new Response(upstream.audioBytes, {
      status: 200,
      headers,
    });
  };
}

function validateRequest(body: unknown):
  | { ok: true; data: TtsRequest }
  | { ok: false; message: string } {
  if (!body || typeof body !== "object") {
    return { ok: false, message: "Body must be a JSON object." };
  }

  const map = body as Record<string, unknown>;
  const text = map.text;
  const voice = map.voice;
  const language = map.language;

  if (typeof text !== "string" || text.trim().length === 0) {
    return { ok: false, message: "Field 'text' must be a non-empty string." };
  }

  if (typeof voice !== "string" || voice.trim().length === 0) {
    return { ok: false, message: "Field 'voice' must be a non-empty string." };
  }

  if (
    language != null &&
    (typeof language !== "string" || language.trim().length === 0)
  ) {
    return {
      ok: false,
      message: "Field 'language' must be a non-empty string when provided.",
    };
  }

  if (text.length > MAX_TEXT_LENGTH) {
    return {
      ok: false,
      message: `Field 'text' exceeds maximum length of ${MAX_TEXT_LENGTH} characters.`,
    };
  }

  return {
    ok: true,
    data: {
      text: text.trim(),
      voice: voice.trim(),
      language: typeof language === "string" ? language.trim() : DEFAULT_LANGUAGE,
    },
  };
}

function buildTtsInput(text: string, language: string): string {
  // Language guidance is inlined because OpenAI Speech API does not expose a dedicated language field.
  return `[Language: ${language}] ${text}`;
}

async function callOpenAiWithRetry(params: {
  apiKey: string;
  voice: string;
  input: string;
  requestId: string;
  fetcher: typeof fetch;
}): Promise<
  | {
      ok: true;
      audioBytes: Uint8Array;
    }
  | {
      ok: false;
      status: number;
      code: string;
      message: string;
      retryable: boolean;
      retryAfterSeconds?: number;
    }
> {
  let lastFailure:
    | {
        status: number;
        code: string;
        message: string;
        retryable: boolean;
        retryAfterSeconds?: number;
      }
    | undefined;

  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

    try {
      const response = await params.fetcher(OPENAI_SPEECH_URL, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${params.apiKey}`,
          "Content-Type": "application/json",
          "OpenAI-Request-ID": params.requestId,
        },
        body: JSON.stringify({
          model: MODEL,
          voice: params.voice,
          input: params.input,
          format: "mp3",
        }),
        signal: controller.signal,
      });

      if (response.ok) {
        const arrayBuffer = await response.arrayBuffer();
        return {
          ok: true,
          audioBytes: new Uint8Array(arrayBuffer),
        };
      }

      const mapped = await mapUpstreamError(response);
      lastFailure = mapped;

      if (!mapped.retryable || attempt === MAX_ATTEMPTS) {
        return { ok: false, ...mapped };
      }

      await delay(backoffMs(attempt));
    } catch (error) {
      const mapped = mapFetchException(error);
      lastFailure = mapped;

      if (!mapped.retryable || attempt === MAX_ATTEMPTS) {
        return { ok: false, ...mapped };
      }

      await delay(backoffMs(attempt));
    } finally {
      clearTimeout(timeoutId);
    }
  }

  return {
    ok: false,
    ...(lastFailure ?? {
      status: 503,
      code: "upstream_unavailable",
      message: "Speech provider is temporarily unavailable.",
      retryable: true,
      retryAfterSeconds: 1,
    }),
  };
}

async function mapUpstreamError(response: Response): Promise<{
  status: number;
  code: string;
  message: string;
  retryable: boolean;
  retryAfterSeconds?: number;
}> {
  const status = response.status;
  const rawText = await response.text();
  const upstreamMessage = extractUpstreamMessage(rawText);
  const retryAfterSeconds = parseRetryAfter(response.headers.get("retry-after"));

  if (status === 400 || status === 422) {
    return {
      status: 400,
      code: "upstream_validation_error",
      message: upstreamMessage ?? "Invalid text, voice, or speech request parameters.",
      retryable: false,
    };
  }

  if (status === 401 || status === 403) {
    return {
      status: 502,
      code: "backend_configuration_error",
      message: "Speech backend configuration error.",
      retryable: false,
    };
  }

  if (status === 429) {
    return {
      status: 429,
      code: "upstream_rate_limited",
      message: "Speech provider is rate-limiting requests.",
      retryable: true,
      retryAfterSeconds: retryAfterSeconds ?? 2,
    };
  }

  if (status >= 500) {
    return {
      status: 503,
      code: "upstream_service_error",
      message: upstreamMessage ?? "Speech provider is temporarily unavailable.",
      retryable: true,
      retryAfterSeconds: retryAfterSeconds ?? 2,
    };
  }

  return {
    status: 502,
    code: "upstream_unexpected_error",
    message: upstreamMessage ?? "Unexpected speech provider response.",
    retryable: false,
  };
}

function mapFetchException(error: unknown): {
  status: number;
  code: string;
  message: string;
  retryable: boolean;
  retryAfterSeconds?: number;
} {
  if (error instanceof DOMException && error.name === "AbortError") {
    return {
      status: 504,
      code: "upstream_timeout",
      message: "Speech provider request timed out.",
      retryable: true,
      retryAfterSeconds: 1,
    };
  }

  return {
    status: 503,
    code: "network_error",
    message: "Network error while contacting speech provider.",
    retryable: true,
    retryAfterSeconds: 1,
  };
}

function extractUpstreamMessage(raw: string): string | undefined {
  if (!raw) return undefined;

  try {
    const parsed = JSON.parse(raw) as {
      error?: { message?: string };
      message?: string;
    };
    return parsed.error?.message ?? parsed.message;
  } catch {
    return raw.slice(0, 200);
  }
}

function parseRetryAfter(value: string | null): number | undefined {
  if (value == null) return undefined;

  const parsed = Number.parseInt(value, 10);
  if (Number.isFinite(parsed) && parsed >= 0) {
    return parsed;
  }

  const retryAt = Date.parse(value);
  if (Number.isNaN(retryAt)) {
    return undefined;
  }

  const deltaMs = retryAt - Date.now();
  if (deltaMs <= 0) {
    return 0;
  }

  return Math.ceil(deltaMs / 1000);
}

function backoffMs(attempt: number): number {
  return 200 * Math.pow(2, attempt - 1);
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function corsHeaders(origin: string | null): Headers {
  const headers = new Headers();
  headers.set("Access-Control-Allow-Origin", origin ?? "*");
  headers.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  headers.set(
    "Access-Control-Allow-Headers",
    "authorization, x-client-info, apikey, content-type",
  );
  headers.set("Vary", "Origin");
  return headers;
}

function jsonError(params: {
  origin: string | null;
  requestId: string;
  status: number;
  code: string;
  message: string;
  retryable: boolean;
  retryAfterSeconds?: number;
}): Response {
  const body: ErrorBody = {
    error: {
      code: params.code,
      message: params.message,
      retryable: params.retryable,
      request_id: params.requestId,
    },
  };

  const headers = corsHeaders(params.origin);
  headers.set("Content-Type", "application/json");
  headers.set("Cache-Control", "no-store");
  headers.set("X-Request-Id", params.requestId);

  if (params.retryable && params.retryAfterSeconds != null) {
    headers.set("Retry-After", String(params.retryAfterSeconds));
  }

  return new Response(JSON.stringify(body), {
    status: params.status,
    headers,
  });
}
