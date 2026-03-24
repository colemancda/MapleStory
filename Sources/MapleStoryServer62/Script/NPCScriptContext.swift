//
//  NPCScriptContext.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

/// Execution context passed to every NPC script.
///
/// Scripts call the async methods on this type to send dialogs and wait for
/// the player's response. Each `send*` call suspends until the player clicks
/// a button or types a value.
public actor NPCScriptContext {

    // MARK: - Properties

    /// The NPC template ID (used as the sprite shown in dialog boxes).
    public let npcID: UInt32

    private let sendPacket: @Sendable (NPCTalkNotification) async throws -> Void

    private var continuation: CheckedContinuation<NPCTalkMoreRequest, Error>?

    // MARK: - Initialization

    init(
        npcID: UInt32,
        send: @Sendable @escaping (NPCTalkNotification) async throws -> Void
    ) {
        self.npcID = npcID
        self.sendPacket = send
    }

    // MARK: - Script API

    /// Show a dialog with an OK button. Waits for acknowledgement.
    public func sendOk(_ message: String) async throws {
        try await sendPacket(.dialog(npc: npcID, message: message, buttons: []))
        _ = try await waitForResponse()
    }

    /// Show a dialog with a Next button. Waits for the player to advance.
    public func sendNext(_ message: String) async throws {
        try await sendPacket(.dialog(npc: npcID, message: message, buttons: .next))
        _ = try await waitForResponse()
    }

    /// Show a dialog with Back and Next buttons.
    /// Returns `true` if the player pressed Next, `false` if Back.
    @discardableResult
    public func sendNextPrev(_ message: String) async throws -> Bool {
        try await sendPacket(.dialog(npc: npcID, message: message, buttons: [.next, .previous]))
        let response = try await waitForResponse()
        return response.action == 1
    }

    /// Show a Yes / No dialog.
    /// Returns `true` if the player pressed Yes.
    public func sendYesNo(_ message: String) async throws -> Bool {
        try await sendPacket(.confirmation(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.action == 1
    }

    /// Show a simple menu. Returns the 0-based index of the selected option.
    public func sendSimple(_ message: String) async throws -> Int32 {
        try await sendPacket(.simple(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.selection ?? 0
    }

    /// Show a free-text input prompt. Returns the string the player typed.
    public func sendGetText(_ message: String) async throws -> String {
        try await sendPacket(.getText(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.returnText ?? ""
    }

    /// Show a numeric input prompt. Returns the number the player entered.
    public func sendGetNumber(
        _ message: String,
        default defaultValue: UInt32 = 0,
        min: UInt32 = 0,
        max: UInt32 = 1_000_000
    ) async throws -> Int32 {
        try await sendPacket(.number(npc: npcID, message: message, default: defaultValue, min: min, max: max))
        let response = try await waitForResponse()
        return response.selection ?? Int32(defaultValue)
    }

    // MARK: - Internal

    /// Suspends the script until `NPCTalkMoreHandler` delivers the player's next response.
    private func waitForResponse() async throws -> NPCTalkMoreRequest {
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
        }
    }

    /// Called by `NPCTalkMoreHandler` to deliver the player's response to the waiting script.
    func resume(with response: NPCTalkMoreRequest) {
        continuation?.resume(returning: response)
        continuation = nil
    }

    /// Called when the player closes the dialog or the connection drops.
    func cancel() {
        continuation?.resume(throwing: CancellationError())
        continuation = nil
    }
}
