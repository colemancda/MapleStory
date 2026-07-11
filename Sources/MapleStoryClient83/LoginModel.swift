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

    struct Snapshot {
        var status: Status
        var username: String
        var password: String
        var activeField: Int
        var message: String
        var worlds: [String]
    }

    private let lock = NSLock()
    private var status: Status = .connecting
    private var username = ""
    private var password = ""
    private var activeField = 0   // 0 = username, 1 = password
    private var message = ""
    private var worlds: [String] = []
    private var client: V83Client?

    func snapshot() -> Snapshot {
        lock.lock(); defer { lock.unlock() }
        return Snapshot(
            status: status,
            username: username,
            password: password,
            activeField: activeField,
            message: message,
            worlds: worlds
        )
    }

    func setStatus(_ newStatus: Status, message newMessage: String? = nil) {
        lock.lock(); defer { lock.unlock() }
        status = newStatus
        if let newMessage { message = newMessage }
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
}
