---
description: Draft or revise recipe prose in the house voice (we-voice, no em dashes, no AI-tell vocabulary, sources cited).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Edit, Write
argument-hint: "<path to the README or doc to draft or revise>"
---

# /draft-recipe-prose

Write or revise recipe and doc prose so it matches the house voice. Read `context/voice-guide.md` first.

## The rules

- We-voice by default. "I" only for a personal judgment in a reflection.
- No em dashes. Restructure, use a comma or semicolon or parentheses, or split the sentence.
- No AI-tell vocabulary: delve, leverage, showcase, robust, seamless, tapestry, at its core, navigate the
  complexities, in essence, it is worth noting.
- Straight quotes, not curly.
- Captions are one to three sentences.
- A reflection carries a difficulty encountered plus a forward note.
- Every rule or claim cites a published source. Reference `versions.lock` for version facts, not raw build
  numbers in prose.
- Write like a sharp teammate, not a consultant. Plain headers beat clever ones.

## After drafting

Self-check the draft against the rules above. Grep your own output for em dashes and the banned words
before handing back.
