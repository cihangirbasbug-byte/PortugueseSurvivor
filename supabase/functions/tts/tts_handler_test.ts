import {
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import { createTtsHandler } from "./tts_handler.ts";

Deno.test("OPTIONS returns CORS preflight response", async () => {
  const handler = createTtsHandler();
  const request = new Request("https://example.com/functions/v1/tts", {
    method: "OPTIONS",
    headers: {
      Origin: "https://app.example.com",
    },
  });

  const response = await handler(request);

  assertEquals(response.status, 204);
  assertEquals(
    response.headers.get("access-control-allow-origin"),
    "https://app.example.com",
  );
  assertStringIncludes(
    response.headers.get("access-control-allow-methods") ?? "",
    "POST",
  );
});

Deno.test("returns 400 for missing required fields", async () => {
  const previous = Deno.env.get("OPENAI_API_KEY");
  Deno.env.set("OPENAI_API_KEY", "test-key");

  try {
    const handler = createTtsHandler();
    const request = new Request("https://example.com/functions/v1/tts", {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({
        text: "",
        voice: "alloy",
      }),
    });

    const response = await handler(request);
    const payload = await response.json();

    assertEquals(response.status, 400);
    assertEquals(payload.error.code, "invalid_request");
    assertEquals(payload.error.retryable, false);
  } finally {
    if (previous == null) {
      Deno.env.delete("OPENAI_API_KEY");
    } else {
      Deno.env.set("OPENAI_API_KEY", previous);
    }
  }
});

Deno.test("returns 400 when text exceeds max length", async () => {
  const previous = Deno.env.get("OPENAI_API_KEY");
  Deno.env.set("OPENAI_API_KEY", "test-key");

  try {
    const handler = createTtsHandler();
    const request = new Request("https://example.com/functions/v1/tts", {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({
        text: "a".repeat(4001),
        voice: "alloy",
        language: "pt-PT",
      }),
    });

    const response = await handler(request);
    const payload = await response.json();

    assertEquals(response.status, 400);
    assertEquals(payload.error.code, "invalid_request");
    assertStringIncludes(payload.error.message, "4000");
  } finally {
    if (previous == null) {
      Deno.env.delete("OPENAI_API_KEY");
    } else {
      Deno.env.set("OPENAI_API_KEY", previous);
    }
  }
});

Deno.test("returns audio/mpeg on successful synthesis", async () => {
  const previous = Deno.env.get("OPENAI_API_KEY");
  Deno.env.set("OPENAI_API_KEY", "test-key");

  try {
    const fetcher: typeof fetch = async () => {
      return new Response(Uint8Array.from([1, 2, 3]), {
        status: 200,
        headers: {
          "content-type": "audio/wav",
        },
      });
    };

    const handler = createTtsHandler(fetcher);
    const request = new Request("https://example.com/functions/v1/tts", {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({
        text: "Bom dia",
        voice: "alloy",
        language: "pt-PT",
      }),
    });

    const response = await handler(request);

    assertEquals(response.status, 200);
    assertEquals(response.headers.get("content-type"), "audio/mpeg");
    const bytes = new Uint8Array(await response.arrayBuffer());
    assertEquals(Array.from(bytes), [1, 2, 3]);
  } finally {
    if (previous == null) {
      Deno.env.delete("OPENAI_API_KEY");
    } else {
      Deno.env.set("OPENAI_API_KEY", previous);
    }
  }
});

Deno.test("returns 503 and retryable true on upstream network error", async () => {
  const previous = Deno.env.get("OPENAI_API_KEY");
  Deno.env.set("OPENAI_API_KEY", "test-key");

  try {
    const fetcher: typeof fetch = async () => {
      throw new TypeError("network down");
    };

    const handler = createTtsHandler(fetcher);
    const request = new Request("https://example.com/functions/v1/tts", {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({
        text: "Bom dia",
        voice: "alloy",
      }),
    });

    const response = await handler(request);
    const payload = await response.json();

    assertEquals(response.status, 503);
    assertEquals(payload.error.code, "network_error");
    assertEquals(payload.error.retryable, true);
    assertEquals(response.headers.get("retry-after"), "1");
  } finally {
    if (previous == null) {
      Deno.env.delete("OPENAI_API_KEY");
    } else {
      Deno.env.set("OPENAI_API_KEY", previous);
    }
  }
});
