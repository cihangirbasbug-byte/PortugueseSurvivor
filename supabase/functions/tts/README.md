# Supabase Edge Function: tts

This function is the only component that talks to OpenAI Speech API.

Flutter must call this edge function endpoint, never OpenAI directly.

The endpoint is not public. Supabase JWT verification is enabled and callers must
send a valid Supabase access token.

## Endpoint

Deployed path:

`/functions/v1/tts`

Method:

`POST`

Preflight:

- `OPTIONS` is supported for CORS.

Content-Type:

`application/json`

Authorization:

`Authorization: Bearer <SUPABASE_ACCESS_TOKEN>`

## Request Contract

```json
{
  "text": "Bom dia, turma!",
  "voice": "alloy",
  "language": "pt-PT"
}
```

Fields:

- `text` (string, required): text to synthesize.
- `voice` (string, required): OpenAI voice id.
- `language` (string, optional): defaults to `pt-PT`.

Validation rules:

- `text` must be non-empty and at most 4000 characters.
- `voice` must be non-empty.
- `language`, if provided, must be non-empty.

## Success Response

Status:

- `200 OK`

Headers:

- `Content-Type: audio/mpeg`
- `X-Request-Id: <uuid>`
- `Cache-Control: no-store`

Body:

- raw MP3 bytes

Example headers:

```text
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Access-Control-Allow-Origin: *
X-Request-Id: <uuid>
```

## Error Response (Retry-Safe)

All errors return JSON body:

```json
{
  "error": {
    "code": "upstream_timeout",
    "message": "Speech provider request timed out.",
    "retryable": true,
    "request_id": "0f40f7f8-1c95-4b6b-b8f0-4a5eb05f5f8e"
  }
}
```

Headers include `X-Request-Id` for support tracing.

Retry-safe behavior:

- Retryable errors include `retryable: true` and usually `Retry-After` header.
- Non-retryable errors include `retryable: false`.
- Idempotent retry is safe because the same input only triggers speech generation and returns bytes.

## HTTP Status Mapping

- `400` invalid JSON or invalid request fields.
- `405` wrong HTTP method.
- `415` unsupported content type.
- `500` server misconfiguration (`OPENAI_API_KEY` missing).
- `429` upstream rate limit; retryable and forwards `Retry-After` when available.
- `502` upstream `401/403` sanitized to generic backend configuration error; other unexpected upstream non-retryable failures also map to `502`.
- `503` transient upstream/network/5xx failures.
- `504` upstream timeout.

## CORS

The function responds with:

- `Access-Control-Allow-Origin`
- `Access-Control-Allow-Methods: POST, OPTIONS`
- `Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type`

And returns `204 No Content` on preflight `OPTIONS` requests.

## Environment Variables

Required in Supabase:

- `OPENAI_API_KEY`

Optional:

- none currently

## Deployment

1. Install Supabase CLI.
2. Authenticate:
   - `supabase login`
3. Link your project:
   - `supabase link --project-ref <your-project-ref>`
4. Set secret:
   - `supabase secrets set OPENAI_API_KEY=<your-openai-key>`
5. Deploy function:
   - `supabase functions deploy tts`
6. Test invocation:
   - `supabase functions invoke tts --header "Authorization: Bearer <SUPABASE_ACCESS_TOKEN>" --body '{"text":"Bom dia","voice":"alloy","language":"pt-PT"}'`

## Example curl Request

```bash
curl -X POST "https://<project-ref>.supabase.co/functions/v1/tts" \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer <SUPABASE_ACCESS_TOKEN>" \
   -d '{"text":"Bom dia!","voice":"alloy","language":"pt-PT"}' \
   --output tts.mp3
```

## Expected Formats

Success format:

- HTTP `200`
- Binary MP3 body (`audio/mpeg`)

Error format:

```json
{
   "error": {
      "code": "invalid_request",
      "message": "Field 'text' must be a non-empty string.",
      "retryable": false,
      "request_id": "d227f4e9-7c51-4ca5-b511-a5f30e89c019"
   }
}
```

## Local Development

1. Start local edge runtime:
   - `supabase start`
2. Serve functions:
   - `supabase functions serve tts --env-file .env.local`
3. Set `OPENAI_API_KEY` in `.env.local`.
4. Call the local endpoint with a valid Supabase access token.
