//
//  UNPushProvisioningCallQueue.swift
//  UnitPushProvisioning
//

import Foundation

actor UNPushProvisioningCallQueue {
    private var lastCall: Task<Void, Never>?

    nonisolated func run<T>(_ call: () async throws -> T) async throws -> T {
        let finish = await waitForTurn()
        defer { finish() }
        try Task.checkCancellation()
        return try await call()
    }

    // The returned closure ends this call's turn.
    private func waitForTurn() async -> @Sendable () -> Void {
        let previousCall = lastCall
        let (turn, continuation) = AsyncStream<Void>.makeStream()
        lastCall = Task { for await _ in turn {} }
        await previousCall?.value
        return { continuation.finish() }
    }
}
