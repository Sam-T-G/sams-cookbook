# Part 7: Testing

Swift Testing as the default for every recipe, with golden-vector parameterized tests for pure logic and the
two XCTest-only escape hatches.

## Planned recipes

- **Swift Testing fundamentals**: `@Test` / `@Suite` / `#expect` / `#require`, `init` / `deinit` instead of
  `setUp` / `tearDown`, traits, and the two XCTest-only escape hatches (XCUI automation, performance).
- **Golden-vector tests for pure logic**: parameterized cases with `@Test(arguments: zip(...))`, when to add
  `.serialized`, testing a typed error with `#expect(throws:)`, exit tests and why not on an iOS device.
- **Snapshot and UI testing**: view snapshots with a recording trait and `perceptualPrecision`, pinning a
  simulator, the XCUI escape hatch, and preferring behavioral assertions for visual recipes.

The concurrency-posture recipe in Part 2 already demonstrates the golden-vector pattern end to end. Add a
recipe with `/new-recipe 07-testing <slug>`.
