# Backend relay for Claude API calls

The production-correct way for an iOS app to call Claude without ever shipping the API key. The app talks to
this relay; the relay holds the key, verifies the caller is a genuine instance of the app (Apple App
Attest), injects the key, forwards to Anthropic, and streams the response back.

This is the artifact behind the hard rule in `SWIFT.md` and Part 9 (Security): no API key in the app binary.

## Why an edge function

A stateless edge function (here, a Cloudflare Worker) is the industry-standard, lowest-ops, best-scaling way
to proxy an LLM key. It scales horizontally with no servers to manage, keeps the key in a server-side
secret, and streams Server-Sent Events natively. An all-Swift server (Hummingbird or Vapor) is an equivalent
alternative if you prefer one language.

## What works today

`src/index.ts` already does the real parts: it accepts `POST /v1/messages`, injects the `x-api-key` and
`anthropic-version` headers server side, forwards to `https://api.anthropic.com/v1/messages`, and streams the
response through without buffering.

## The one device-required spike

App Attest verification is stubbed and fails closed. Completing it needs a real device, so it is the spike
called out in `SPEC.md` section 12. The contract it must satisfy:

1. On first launch the app uses `DCAppAttestService` to make a hardware-backed key and an attestation. The
   relay verifies the attestation chain against Apple's App Attest root, checks the app id hash matches
   `APP_ATTEST_TEAM_AND_BUNDLE`, and stores the public key by key id (Workers KV or a Durable Object).
2. On each request the app sends an assertion over a hash of the body plus a server nonce. The relay verifies
   the signature against the stored public key and checks the counter increases, to stop replay.

## Run it locally

```sh
npm install
echo 'ANTHROPIC_API_KEY = "sk-ant-..."' > .dev.vars   # gitignored
npm run dev
```

`.dev.vars` is gitignored, as is any `Secrets.xcconfig`. Never commit a key.

## Tier

device-required (the App Attest handshake cannot be exercised in CI). The forwarding path can be smoke-tested
locally with `DEV_BYPASS`, but the relay ships fail-closed.
