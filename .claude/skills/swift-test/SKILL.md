---
description: Run the Swift Testing suite for the current recipe or the whole workspace and report what passed and failed.
user-invocable: true
allowed-tools: Bash(swift test:*)
argument-hint: "[--filter <suite-or-test>]"
---

# /swift-test

Run `swift test` from the current directory. This is the golden-vector half of the verify loop; it must be
green before work is considered done (the Stop hook enforces this).

Live output:

!`swift test 2>&1 | tail -50`

A failing `#expect` prints the evaluated values, so read them before changing the test. Fix the code, not
the assertion, unless the assertion itself is wrong. Capture the final passing output into the recipe's
`verify-output/` as evidence.
