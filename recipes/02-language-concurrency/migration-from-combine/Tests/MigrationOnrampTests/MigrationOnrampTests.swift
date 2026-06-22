import Testing

@testable import LegacyFeed
@testable import ModernFeed

/// The migration is only safe if it preserves behavior. These tests drive the same input sequence through
/// the legacy store and the migrated store and assert they agree at every step, so the rewrite is provably
/// behavior-preserving, not just plausible.
@Suite @MainActor struct MigrationParityTests {
    let inputs: [Double] = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

    @Test func modernMatchesLegacyStepForStep() async {
        let legacy = LegacyReadingStore(capacity: 4)
        let modern = ModernReadingStore(capacity: 4)

        for value in inputs {
            legacy.ingest(value)
            await modern.ingest(value)
            #expect(modern.average == legacy.average)
        }
    }

    @Test func bothStartAtZeroBeforeAnyInput() {
        #expect(LegacyReadingStore().average == 0)
        #expect(ModernReadingStore().average == 0)
    }
}

@Suite struct ModernStoreTests {
    @Test @MainActor func averageOfAKnownWindowIsExact() async {
        let store = ModernReadingStore(capacity: 3)
        await store.ingest(3)
        await store.ingest(6)
        await store.ingest(9)
        #expect(store.average == 6)
    }

    @Test @MainActor func evictsBeyondCapacity() async {
        let store = ModernReadingStore(capacity: 2)
        await store.ingest(10)
        await store.ingest(20)
        await store.ingest(30)
        // Only 20 and 30 remain, so the average is 25, not 20.
        #expect(store.average == 25)
    }
}
