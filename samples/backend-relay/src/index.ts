// Backend relay for Claude API calls from an iOS app.
//
// Why this exists: an iOS app must never ship the Anthropic API key in its binary, because anyone can
// extract strings from a downloaded app. The app calls THIS relay; the relay holds the key server side,
// proves the caller is a genuine instance of the app (Apple App Attest), injects the key, forwards to
// Anthropic, and streams the Server-Sent-Events response straight back.
//
// Reference runtime: a Cloudflare Worker, chosen because it is the industry-standard, lowest-ops,
// best-scaling way to proxy an LLM key (global edge, scales to zero, native streaming). An all-Swift
// server (Hummingbird or Vapor) is an equivalent alternative.
//
// Status: the key injection and SSE passthrough below are real and work. App Attest verification is the
// one device-required spike (see README): the handshake needs a real device to test end to end.

export interface Env {
  ANTHROPIC_API_KEY: string;      // set with: wrangler secret put ANTHROPIC_API_KEY
  ANTHROPIC_VERSION: string;      // e.g. "2023-06-01", from the Anthropic API docs
  APP_ATTEST_TEAM_AND_BUNDLE: string; // "TEAMID.com.example.app", the expected app identity
}

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method !== "POST" || new URL(request.url).pathname !== "/v1/messages") {
      return json({ error: "not_found" }, 404);
    }

    // 1. Prove the caller is a genuine instance of our app before spending the key.
    const attested = await verifyAppAttest(request, env);
    if (!attested.ok) {
      return json({ error: "attestation_failed", detail: attested.reason }, 401);
    }

    // 2. Forward the body to Anthropic with the key injected server side. The app never sees the key.
    const upstream = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": env.ANTHROPIC_API_KEY,
        "anthropic-version": env.ANTHROPIC_VERSION,
      },
      body: request.body,
    });

    // 3. Stream the response straight through. For a streaming request this is the SSE token stream;
    //    the relay adds no buffering of its own.
    return new Response(upstream.body, {
      status: upstream.status,
      headers: {
        "content-type": upstream.headers.get("content-type") ?? "application/json",
        "cache-control": "no-store",
      },
    });
  },
};

// App Attest verification.
//
// Contract this MUST satisfy before shipping (the device-required spike):
//   - On first launch the app calls DCAppAttestService to generate a hardware-backed key and an
//     attestation; the relay verifies the attestation chain against Apple's App Attest root, checks the
//     app id hash matches APP_ATTEST_TEAM_AND_BUNDLE, and stores the public key keyed by the key id.
//   - On each request the app sends an assertion over a hash of the request body plus a server nonce; the
//     relay verifies the assertion signature against the stored public key and checks the counter
//     increases, to stop replay.
//   - Persist key id -> public key and the last counter in Workers KV or a Durable Object.
//
// Until that spike lands, this stub fails closed unless DEV_BYPASS is explicitly set, so the relay is never
// accidentally open.
async function verifyAppAttest(
  request: Request,
  env: Env,
): Promise<{ ok: true } | { ok: false; reason: string }> {
  const keyId = request.headers.get("x-app-attest-key-id");
  const assertion = request.headers.get("x-app-attest-assertion");
  if (!keyId || !assertion) {
    return { ok: false, reason: "missing App Attest headers" };
  }
  // TODO (device-required spike): verify the assertion against the stored public key and counter.
  // See the contract above and samples/backend-relay/README.md.
  return { ok: false, reason: "App Attest verification not implemented yet (device-required spike)" };
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
