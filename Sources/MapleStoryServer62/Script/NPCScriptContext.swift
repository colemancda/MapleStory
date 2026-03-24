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
/// the player's response, and to read/mutate character state.
public actor NPCScriptContext {

    // MARK: - Properties

    public let npcID: UInt32

    private let sendPacket: @Sendable (NPCTalkNotification) async throws -> Void
    private let readCharacter: @Sendable () async throws -> MapleStory.Character
    private let writeCharacter: @Sendable (MapleStory.Character) async throws -> Void
    private let warpPlayer: @Sendable (Map.ID, UInt8) async throws -> Void

    private var continuation: CheckedContinuation<NPCTalkMoreRequest, Error>?

    // MARK: - Initialization

    init(
        npcID: UInt32,
        send: @Sendable @escaping (NPCTalkNotification) async throws -> Void,
        readCharacter: @Sendable @escaping () async throws -> MapleStory.Character,
        writeCharacter: @Sendable @escaping (MapleStory.Character) async throws -> Void,
        warpPlayer: @Sendable @escaping (Map.ID, UInt8) async throws -> Void
    ) {
        self.npcID = npcID
        self.sendPacket = send
        self.readCharacter = readCharacter
        self.writeCharacter = writeCharacter
        self.warpPlayer = warpPlayer
    }

    // MARK: - Character Access

    /// Fetch the current character state.
    public func character() async throws -> MapleStory.Character {
        try await readCharacter()
    }

    public var level: UInt16 {
        get async throws { try await readCharacter().level }
    }

    public var job: Job {
        get async throws { try await readCharacter().job }
    }

    public var meso: UInt32 {
        get async throws { try await readCharacter().meso }
    }

    public var str: UInt16 {
        get async throws { try await readCharacter().str }
    }

    public var dex: UInt16 {
        get async throws { try await readCharacter().dex }
    }

    public var int: UInt16 {
        get async throws { try await readCharacter().int }
    }

    public var luk: UInt16 {
        get async throws { try await readCharacter().luk }
    }

    public var name: CharacterName {
        get async throws { try await readCharacter().name }
    }

    public var gender: Gender {
        get async throws { try await readCharacter().gender }
    }

    // MARK: - Character Mutation

    /// Add or subtract mesos. Pass a negative value to charge the player.
    public func gainMeso(_ amount: Int32) async throws {
        var character = try await readCharacter()
        let current = Int64(character.meso)
        character.meso = UInt32(max(0, current + Int64(amount)))
        try await writeCharacter(character)
    }

    /// Teleport the player to the given map and spawn point.
    public func warp(to map: Map.ID, spawn: UInt8 = 0) async throws {
        try await warpPlayer(map, spawn)
    }

    /// Change the player's job.
    public func changeJob(_ job: Job) async throws {
        var character = try await readCharacter()
        character.job = job
        try await writeCharacter(character)
    }

    /// Give or take items. Positive quantity = give, negative = take.
    /// Not yet fully implemented — logs the operation.
    public func gainItem(_ itemID: UInt32, _ quantity: Int32 = 1) async throws {
        // TODO: implement item inventory
        _ = itemID; _ = quantity
    }

    /// Returns true if the player has at least one of the given item.
    /// Not yet fully implemented — always returns false.
    public func hasItem(_ itemID: UInt32) async throws -> Bool {
        // TODO: implement item inventory
        return false
    }

    /// Returns the player's current buddy list capacity.
    /// Stub — returns 20 until buddy list is implemented.
    public var buddyCapacity: UInt8 {
        get async { 20 }
    }

    /// Sets the player's buddy list capacity. Stub.
    public func setBuddyCapacity(_ capacity: UInt8) async throws {
        // TODO: implement buddy list capacity
        _ = capacity
    }

    /// Opens the player's storage. Stub.
    public func sendStorage() async throws {
        // TODO: implement storage
        try await sendOk("Storage is not available yet.")
    }

    /// Returns true if the player has inventory space for the given item. Stub — always returns true.
    public func canHold(_ itemID: UInt32) async throws -> Bool {
        // TODO: implement inventory space check
        return true
    }

    /// Change the player's hair style. Stub.
    public func changeHair(_ hairID: UInt32) async throws {
        // TODO: implement appearance changes
        _ = hairID
    }

    /// Change the player's face. Stub.
    public func changeFace(_ faceID: UInt32) async throws {
        // TODO: implement appearance changes
        _ = faceID
    }

    /// Reset the player's AP stats. Stub.
    public func resetStats() async throws {
        // TODO: implement AP reset
    }

    /// Give the player experience points. Stub.
    public func gainExp(_ amount: UInt32) async throws {
        // TODO: implement EXP gain
        _ = amount
    }

    /// Teach the player a skill at the given level. Stub.
    public func teachSkill(_ skillID: UInt32, _ currentLevel: Int, _ maxLevel: Int) async throws {
        // TODO: implement skill teaching
        _ = skillID; _ = currentLevel; _ = maxLevel
    }

    // MARK: - Dialog API

    /// Show a dialog with an OK button. Waits for acknowledgement.
    public func sendOk(_ message: String) async throws {
        try await sendPacket(.dialog(npc: npcID, message: message, buttons: []))
        _ = try await waitForResponse()
    }

    /// Show a dialog with a Next button.
    public func sendNext(_ message: String) async throws {
        try await sendPacket(.dialog(npc: npcID, message: message, buttons: .next))
        _ = try await waitForResponse()
    }

    /// Show a dialog with Back and Next buttons.
    /// Returns `true` if Next was pressed, `false` if Back.
    @discardableResult
    public func sendNextPrev(_ message: String) async throws -> Bool {
        try await sendPacket(.dialog(npc: npcID, message: message, buttons: [.next, .previous]))
        let response = try await waitForResponse()
        return response.action == 1
    }

    /// Show a Yes / No confirmation. Returns `true` if Yes.
    public func sendYesNo(_ message: String) async throws -> Bool {
        try await sendPacket(.confirmation(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.action == 1
    }

    /// Show an Accept / Decline confirmation. Returns `true` if accepted.
    public func sendAcceptDecline(_ message: String) async throws -> Bool {
        try await sendPacket(.accept(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.action == 1
    }

    /// Show a simple menu. Returns the 0-based index the player selected.
    public func sendSimple(_ message: String) async throws -> Int32 {
        try await sendPacket(.simple(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.selection ?? 0
    }

    /// Show a free-text input prompt. Returns what the player typed.
    public func sendGetText(_ message: String) async throws -> String {
        try await sendPacket(.getText(npc: npcID, message: message))
        let response = try await waitForResponse()
        return response.returnText ?? ""
    }

    /// Show a number input prompt. Returns the number the player entered.
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

    private func waitForResponse() async throws -> NPCTalkMoreRequest {
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
        }
    }

    func resume(with response: NPCTalkMoreRequest) {
        continuation?.resume(returning: response)
        continuation = nil
    }

    func cancel() {
        continuation?.resume(throwing: CancellationError())
        continuation = nil
    }
}
