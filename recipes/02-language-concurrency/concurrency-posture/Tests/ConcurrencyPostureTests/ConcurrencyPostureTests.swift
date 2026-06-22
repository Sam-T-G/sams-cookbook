import Testing

@testable import ConcurrencyPosture

@Suite struct BearingTests {
    @Test(arguments: [
        (370.0, 10.0),
        (-10.0, 350.0),
        (0.0, 0.0),
        (720.0, 0.0),
        (-360.0, 0.0),
    ])
    func normalizesIntoZeroTo360(_ input: Double, _ expected: Double) {
        #expect(Bearing.normalizedDegrees(input) == expected)
    }

    @Test func shortestDeltaTakesTheShortWayAround() {
        #expect(Bearing.shortestDelta(from: 350, to: 10) == 20)
        #expect(Bearing.shortestDelta(from: 10, to: 350) == -20)
        #expect(Bearing.shortestDelta(from: 0, to: 180) == 180)
        #expect(Bearing.shortestDelta(from: 90, to: 90) == 0)
    }
}

@Suite struct SampleBufferTests {
    @Test func averageOfKnownVectorsIsExact() async throws {
        let buffer = SampleBuffer(capacity: 4)
        for value in [2.0, 4.0, 6.0] {
            await buffer.append(Reading(value: value, timestamp: 0))
        }
        let average = try await buffer.average()
        #expect(average == 4.0)
    }

    @Test func evictsOldestBeyondCapacity() async {
        let buffer = SampleBuffer(capacity: 2)
        for value in [1.0, 2.0, 3.0] {
            await buffer.append(Reading(value: value, timestamp: 0))
        }
        let count = await buffer.count
        #expect(count == 2)
        #expect(await buffer.latest() == Reading(value: 3.0, timestamp: 0))
    }

    @Test func emptyBufferThrowsTypedError() async {
        let buffer = SampleBuffer()
        await #expect(throws: PostureError.emptyBuffer) {
            _ = try await buffer.average()
        }
    }
}

@Suite @MainActor struct CoordinatorTests {
    @Test func coordinatorBridgesToTheActor() async {
        let coordinator = PostureCoordinator(buffer: SampleBuffer(capacity: 4))
        await coordinator.record(10, at: 0)
        await coordinator.record(20, at: 1)
        #expect(await coordinator.smoothedAverage() == 15.0)
    }

    @Test func emptyWindowReadsAsNilNotAFailure() async {
        let coordinator = PostureCoordinator()
        #expect(await coordinator.smoothedAverage() == nil)
    }
}
