/// Pure navigation geometry: no sensors, no state, all static. This is the most test-worthy code in any
/// sensor app, so it lives apart from anything that touches hardware or the main actor. It is
/// `nonisolated` so tests and the buffer can call it directly, without an await or a main-actor hop.
public nonisolated enum Bearing {
    /// Wrap any angle into the range [0, 360).
    public static func normalizedDegrees(_ degrees: Double) -> Double {
        let remainder = degrees.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    /// The signed shortest turn from one heading to another, in the range (-180, 180].
    /// Positive is clockwise. This is the value a turn cue or a steering controller actually wants.
    public static func shortestDelta(from: Double, to: Double) -> Double {
        let diff = normalizedDegrees(to - from)
        return diff > 180 ? diff - 360 : diff
    }
}
