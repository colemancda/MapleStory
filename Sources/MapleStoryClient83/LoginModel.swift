//
//  LoginModel.swift
//  MapleStoryClient83
//
//  Thread-safe state shared between the synchronous render loop (main thread) and
//  the asynchronous network session (background tasks).
//

import Foundation

final class LoginModel: @unchecked Sendable {

    enum Status: String, Sendable {
        case connecting = "Connecting..."
        case ready = "Enter your credentials"
        case loggingIn = "Logging in..."
        case loggedIn = "Logged in"
        case failed = "Connection failed"
    }

    /// Which screen the login flow is currently showing.
    enum Phase: Sendable {
        case login
        case worldSelect
        case characterSelect
        case enteringGame
        case inGame
    }

    struct Snapshot {
        var status: Status
        var phase: Phase
        var username: String
        var password: String
        var activeField: Int
        var message: String
        var worlds: [String]
        var selectedWorld: Int
        var characters: [String]
        var selectedCharacter: Int
        var avatarX: Float
        var avatarY: Float
    }

    private let lock = NSLock()
    private var status: Status = .connecting
    private var phase: Phase = .login
    private var username = ""
    private var password = ""
    private var activeField = 0   // 0 = username, 1 = password
    private var message = ""
    private var worlds: [String] = []
    private var selectedWorld = 0
    private var characters: [String] = []
    private var characterIDs: [UInt32] = []
    private var selectedCharacter = 0
    private var avatarX: Float = 0
    private var avatarY: Float = 0
    private var client: V83Client?

    func snapshot() -> Snapshot {
        lock.lock(); defer { lock.unlock() }
        return Snapshot(
            status: status,
            phase: phase,
            username: username,
            password: password,
            activeField: activeField,
            message: message,
            worlds: worlds,
            selectedWorld: selectedWorld,
            characters: characters,
            selectedCharacter: selectedCharacter,
            avatarX: avatarX,
            avatarY: avatarY
        )
    }

    func moveAvatar(dx: Float, dy: Float) {
        lock.lock(); defer { lock.unlock() }
        avatarX += dx
        avatarY += dy
    }

    func setStatus(_ newStatus: Status, message newMessage: String? = nil) {
        lock.lock(); defer { lock.unlock() }
        status = newStatus
        if let newMessage { message = newMessage }
    }

    func setPhase(_ newPhase: Phase) {
        lock.lock(); defer { lock.unlock() }
        phase = newPhase
    }

    func currentPhase() -> Phase {
        lock.lock(); defer { lock.unlock() }
        return phase
    }

    /// Move the world-select cursor, clamped to the available worlds.
    func moveWorldSelection(by delta: Int) {
        lock.lock(); defer { lock.unlock() }
        guard worlds.isEmpty == false else { return }
        selectedWorld = min(max(0, selectedWorld + delta), worlds.count - 1)
    }

    func selectedWorldIndex() -> Int {
        lock.lock(); defer { lock.unlock() }
        return selectedWorld
    }

    func setCharacters(_ list: [(id: UInt32, name: String)]) {
        lock.lock(); defer { lock.unlock() }
        characters = list.map(\.name)
        characterIDs = list.map(\.id)
        selectedCharacter = 0
    }

    func moveCharacterSelection(by delta: Int) {
        lock.lock(); defer { lock.unlock() }
        guard characters.isEmpty == false else { return }
        selectedCharacter = min(max(0, selectedCharacter + delta), characters.count - 1)
    }

    func selectedCharacterID() -> UInt32? {
        lock.lock(); defer { lock.unlock() }
        guard characterIDs.indices.contains(selectedCharacter) else { return nil }
        return characterIDs[selectedCharacter]
    }

    func setClient(_ newClient: V83Client) {
        lock.lock(); defer { lock.unlock() }
        client = newClient
    }

    func currentClient() -> V83Client? {
        lock.lock(); defer { lock.unlock() }
        return client
    }

    func append(_ character: Character) {
        lock.lock(); defer { lock.unlock() }
        if activeField == 0 { username.append(character) } else { password.append(character) }
    }

    func backspace() {
        lock.lock(); defer { lock.unlock() }
        if activeField == 0 {
            if username.isEmpty == false { username.removeLast() }
        } else {
            if password.isEmpty == false { password.removeLast() }
        }
    }

    func toggleField() {
        lock.lock(); defer { lock.unlock() }
        activeField = (activeField + 1) % 2
    }

    func credentials() -> (username: String, password: String) {
        lock.lock(); defer { lock.unlock() }
        return (username, password)
    }

    func setWorlds(_ newWorlds: [String]) {
        lock.lock(); defer { lock.unlock() }
        worlds = newWorlds
    }

    func clearWorlds() {
        lock.lock(); defer { lock.unlock() }
        worlds.removeAll(keepingCapacity: true)
    }

    func addWorld(_ name: String) {
        lock.lock(); defer { lock.unlock() }
        worlds.append(name)
    }
}
