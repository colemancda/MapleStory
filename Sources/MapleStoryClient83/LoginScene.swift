//
//  LoginScene.swift
//  MapleStoryClient83
//
//  The v83 login screen: connects to the server, performs the handshake, accepts
//  credentials, and sends a login request. The client analogue of the reference
//  client's `UIStateLogin` / `Login` UI.
//

import Foundation
import MapleStory
import MapleStory83
import MapleStoryClient

final class LoginScene: Scene {

    let model = LoginModel()
    private let configuration: ClientConfiguration
    private let verbose: Bool

    init(configuration: ClientConfiguration, verbose: Bool) {
        self.configuration = configuration
        self.verbose = verbose
    }

    /// Kick off the connection + handshake on a background task.
    func start() {
        let model = self.model
        let configuration = self.configuration
        let verbose = self.verbose
        Task.detached {
            let log: (@Sendable (String) -> Void)?
            if verbose {
                log = { message in print("[net] \(message)") }
            } else {
                log = nil
            }
            do {
                let client = try await V83Client.connect(configuration: configuration, log: log)
                await client.register { (response: MapleStory83.LoginResponse) in
                    LoginScene.handle(response: response, model: model)
                }
                await client.register { (list: MapleStory83.ServerListResponse) in
                    LoginScene.handle(serverList: list, model: model)
                }
                model.setClient(client)
                model.setStatus(.ready, message: "Connected to \(configuration.destination.rawValue)")
            } catch {
                model.setStatus(.failed, message: "\(error)")
            }
        }
    }

    private static func handle(response: MapleStory83.LoginResponse, model: LoginModel) {
        switch response {
        case .success:
            model.clearWorlds()
            model.setStatus(.loggedIn, message: "Login successful - loading worlds...")
            // Request the world list.
            if let client = model.currentClient() {
                Task.detached { try? await client.send(MapleStory83.ServerListRequest()) }
            }
        case .failure(let error):
            model.setStatus(.ready, message: "Login failed: \(error)")
        case .permanentBan:
            model.setStatus(.ready, message: "Account permanently banned")
        case .temporaryBan(let error, _):
            model.setStatus(.ready, message: "Temporarily banned: \(error)")
        }
    }

    private static func handle(serverList: MapleStory83.ServerListResponse, model: LoginModel) {
        switch serverList {
        case let .world(_, world):
            model.addWorld(world.name)
        case .end:
            model.setStatus(.loggedIn, message: "Select a world")
        }
    }

    // MARK: - Scene

    func render(_ context: RenderContext) {
        let snapshot = model.snapshot()
        let renderer = context.renderer
        let text = context.text

        text.draw("MapleStory v83", x: 48, y: 48, scale: 1, color: .white, using: renderer)
        text.draw(snapshot.status.rawValue, x: 48, y: 104, scale: 0.6, color: .gray(0.85), using: renderer)

        drawField(label: "ID", value: snapshot.username, active: snapshot.activeField == 0, y: 176, context: context)
        drawField(label: "PW", value: String(repeating: "*", count: snapshot.password.count), active: snapshot.activeField == 1, y: 240, context: context)

        text.draw("[Tab] switch field   [Enter] log in", x: 48, y: 300, scale: 0.5, color: .gray(0.55), using: renderer)

        if snapshot.message.isEmpty == false {
            text.draw(snapshot.message, x: 48, y: 340, scale: 0.5, color: .gray(0.75), using: renderer)
        }

        var worldY: Float = 400
        for world in snapshot.worlds {
            text.draw("- " + world, x: 48, y: worldY, scale: 0.6, using: renderer)
            worldY += 32
        }
    }

    private func drawField(label: String, value: String, active: Bool, y: Float, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text
        text.draw(label, x: 48, y: y, scale: 0.6, color: .gray(0.7), using: renderer)
        let box = Rectangle(x: 120, y: y - 8, width: 340, height: 40)
        renderer.fill(box, color: active ? .gray(0.32) : .gray(0.18))
        text.draw(value, x: 132, y: y, scale: 0.6, color: .white, using: renderer)
    }

    func handle(_ event: InputEvent) {
        switch event {
        case let .character(character):
            model.append(character)
        case .control(.backspace):
            model.backspace()
        case .control(.tab):
            model.toggleField()
        case .control(.enter):
            submitLogin()
        case .control(.escape), .mouseDown, .resize, .quit:
            break
        }
    }

    private func submitLogin() {
        let model = self.model
        guard let client = model.currentClient() else { return }
        let (username, password) = model.credentials()
        guard username.isEmpty == false else { return }
        model.setStatus(.loggingIn, message: "Sending login for \(username)")
        Task.detached {
            do {
                try await client.send(MapleStory83.LoginRequest(username: username, password: password))
            } catch {
                model.setStatus(.failed, message: "Send failed: \(error)")
            }
        }
    }
}
