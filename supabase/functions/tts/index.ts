import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { createTtsHandler } from "./tts_handler.ts";

serve(createTtsHandler());

