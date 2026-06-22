import Foundation

#if canImport(FoundationModels)
    import FoundationModels

    /// The on-device tier, backed by Apple's Foundation Models framework (the ~3B model behind Apple
    /// Intelligence). Device-required: it needs eligible hardware with Apple Intelligence enabled, so it is
    /// not exercised in CI. The routing and escalation logic that decides when to reach for it, and what to
    /// do when it fails, is tested headlessly with fakes. This type is the real glue, verified on a device.
    @available(iOS 26, macOS 26, *)
    public nonisolated struct OnDeviceBackend: LanguageBackend {
        public init() {}

        public func respond(to prompt: String) async throws(BackendError) -> String {
            switch SystemLanguageModel.default.availability {
            case .available:
                break
            case .unavailable:
                throw .unavailable
            @unknown default:
                throw .unavailable
            }

            let session = LanguageModelSession(model: SystemLanguageModel.default)
            do {
                let response = try await session.respond(to: prompt)
                return response.content
            } catch let error as LanguageModelSession.GenerationError {
                // Map the two recoverable cases so the assistant escalates to the cloud on them. Anything
                // else is a real generation failure that a different tier cannot fix.
                switch error {
                case .exceededContextWindowSize: throw .contextExceeded
                case .rateLimited: throw .rateLimited
                default: throw .transport(String(describing: error))
                }
            } catch {
                throw .transport(String(describing: error))
            }
        }
    }
#endif
