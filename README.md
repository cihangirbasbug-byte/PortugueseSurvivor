# PortugueseSurvivor

## Backend TTS Architecture

Portuguese Survivor uses a Supabase Edge Function (`tts`) as a secure server-side proxy for OpenAI Speech API.

- Flutter must call Supabase Edge Function only.
- OpenAI API key is stored only in Supabase secrets.
- The function returns MP3 audio bytes and retry-safe JSON errors.

See deployment and contract details in:

- [supabase/functions/tts/README.md](supabase/functions/tts/README.md)

Quick commands:

- Local serve: `supabase functions serve tts --env-file .env.local`
- Deploy: `supabase functions deploy tts`