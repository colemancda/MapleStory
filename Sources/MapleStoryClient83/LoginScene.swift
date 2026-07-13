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

    /// Called (from a network task) when the channel server warps the client
    /// into a map — the hand-off point to the real map renderer.
    var onEnterField: (@Sendable (_ mapID: Int, _ spawnPoint: Int) -> Void)?

    init(configuration: ClientConfiguration, verbose: Bool) {
        self.configuration = configuration
        self.verbose = verbose
    }

    /// Kick off the connection + handshake on a background task.
    func start() {
        let model = self.model
        let configuration = self.configuration
        let verbose = self.verbose
        let onEnterField = self.onEnterField
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
                await client.register { (characters: MapleStory83.CharacterListResponse) in
                    LoginScene.handle(characterList: characters, model: model)
                }
                await client.register { (serverIP: MapleStory83.ServerIPResponse) in
                    LoginScene.handle(serverIP: serverIP, model: model, verbose: verbose,
                                      onEnterField: onEnterField)
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
            model.setStatus(.loggedIn, message: "Select a world  [Up/Down] move  [Enter] choose")
            model.setPhase(.worldSelect)
        }
    }

    private static func handle(characterList: MapleStory83.CharacterListResponse, model: LoginModel) {
        let list = characterList.characters.map { (id: $0.stats.id, name: "\($0.stats.name)") }
        model.setCharacters(list)
        model.setStatus(.loggedIn, message: list.isEmpty ? "No characters on this world" : "Select a character")
        model.setPhase(.characterSelect)
    }

    /// The login server hands off to a channel server: connect there and enter the game.
    private static func handle(
        serverIP: MapleStory83.ServerIPResponse,
        model: LoginModel,
        verbose: Bool,
        onEnterField: (@Sendable (Int, Int) -> Void)?
    ) {
        let address = serverIP.address
        let character = serverIP.character
        model.setPhase(.enteringGame)
        model.setStatus(.loggedIn, message: "Connecting to channel \(address.rawValue)...")
        Task.detached {
            let log: (@Sendable (String) -> Void)?
            if verbose {
                log = { message in print("[net] \(message)") }
            } else {
                log = nil
            }
            do {
                if let previous = model.currentClient() {
                    await previous.close()
                }
                let configuration = ClientConfiguration(destination: address)
                let client = try await V83Client.connect(configuration: configuration, log: log)
                await client.register { (field: MapleStory83.SetFieldNotification) in
                    LoginScene.handle(setField: field, model: model, onEnterField: onEnterField)
                }
                model.setClient(client)
                try await client.send(MapleStory83.PlayerLoginRequest(character: character))
                model.setStatus(.loggedIn, message: "In game as character \(character)")
                model.setPhase(.inGame)
            } catch {
                model.setStatus(.failed, message: "Channel connect failed: \(error)")
            }
        }
    }

    /// The channel server warped us into a map: hand off to the map renderer.
    static func handle(
        setField: MapleStory83.SetFieldNotification,
        model: LoginModel,
        onEnterField: (@Sendable (Int, Int) -> Void)?
    ) {
        model.setPhase(.inGame)
        model.setStatus(.loggedIn, message: "Entered map \(setField.mapID)")
        onEnterField?(Int(setField.mapID), Int(setField.spawnPoint))
    }

    // MARK: - Scene

    func render(_ context: RenderContext) {
        let snapshot = model.snapshot()
        let renderer = context.renderer
        let text = context.text

        text.draw("MapleStory v83", x: 48, y: 48, scale: 1, color: .white, using: renderer)
        text.draw(snapshot.status.rawValue, x: 48, y: 104, scale: 0.6, color: .gray(0.85), using: renderer)

        switch snapshot.phase {
        case .login:
            renderLogin(snapshot, context: context)
        case .worldSelect:
            renderList(title: "Worlds", items: snapshot.worlds, selected: snapshot.selectedWorld, context: context)
        case .characterSelect:
            renderList(title: "Characters", items: snapshot.characters, selected: snapshot.selectedCharacter, context: context)
        case .enteringGame:
            text.draw("Entering game...", x: 48, y: 176, scale: 0.8, color: .white, using: renderer)
        case .inGame:
            renderGame(snapshot, context: context)
        }

        if snapshot.message.isEmpty == false {
            text.draw(snapshot.message, x: 48, y: Float(context.height) - 60, scale: 0.5, color: .gray(0.75), using: renderer)
        }
    }

    private func renderLogin(_ snapshot: LoginModel.Snapshot, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text
        drawField(label: "ID", value: snapshot.username, active: snapshot.activeField == 0, y: 176, context: context)
        drawField(label: "PW", value: String(repeating: "*", count: snapshot.password.count), active: snapshot.activeField == 1, y: 240, context: context)
        text.draw("[Tab] switch field   [Enter] log in", x: 48, y: 300, scale: 0.5, color: .gray(0.55), using: renderer)
    }

    /// Placeholder scrolling game view: a ground grid drawn through a camera that
    /// follows the avatar, plus the avatar itself. Real WZ map/sprite rendering
    /// will replace the placeholder art once a WZ canvas->texture path exists.
    private func renderGame(_ snapshot: LoginModel.Snapshot, context: RenderContext) {
        let renderer = context.renderer
        let width = Float(context.width)
        let height = Float(context.height)
        let camera = Camera(x: snapshot.avatarX, y: snapshot.avatarY, viewportWidth: width, viewportHeight: height)

        // Ground grid: draw vertical/horizontal lines every 64 world units.
        let spacing: Float = 64
        let lineColor = RGBAColor.gray(0.16)
        let originX = snapshot.avatarX.truncatingRemainder(dividingBy: spacing)
        let originY = snapshot.avatarY.truncatingRemainder(dividingBy: spacing)
        var gx = -originX
        while gx <= width {
            renderer.fill(Rectangle(x: gx, y: 0, width: 1, height: height), color: lineColor)
            gx += spacing
        }
        var gy = -originY
        while gy <= height {
            renderer.fill(Rectangle(x: 0, y: gy, width: width, height: 1), color: lineColor)
            gy += spacing
        }

        // Avatar: a quad centered on the camera.
        let avatar = camera.screenRect(worldX: snapshot.avatarX - 16, worldY: snapshot.avatarY - 24, width: 32, height: 48)
        renderer.fill(avatar, color: RGBAColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1))

        context.text.draw("[Arrows] move", x: 48, y: height - 88, scale: 0.5, color: .gray(0.6), using: renderer)
    }

    private func renderList(title: String, items: [String], selected: Int, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text
        text.draw(title, x: 48, y: 168, scale: 0.7, color: .gray(0.7), using: renderer)
        var y: Float = 216
        for (index, item) in items.enumerated() {
            if index == selected {
                renderer.fill(Rectangle(x: 40, y: y - 6, width: 420, height: 34), color: .gray(0.32))
            }
            text.draw(item, x: 56, y: y, scale: 0.6, color: .white, using: renderer)
            y += 36
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
        switch model.currentPhase() {
        case .login:
            handleLogin(event)
        case .worldSelect:
            handleWorldSelect(event)
        case .characterSelect:
            handleCharacterSelect(event)
        case .enteringGame:
            break
        case .inGame:
            handleInGame(event)
        }
    }

    private func handleInGame(_ event: InputEvent) {
        let step: Float = 16
        switch event {
        case .control(.left):
            model.moveAvatar(dx: -step, dy: 0)
        case .control(.right):
            model.moveAvatar(dx: step, dy: 0)
        case .control(.up):
            model.moveAvatar(dx: 0, dy: -step)
        case .control(.down):
            model.moveAvatar(dx: 0, dy: step)
        default:
            break
        }
    }

    private func handleCharacterSelect(_ event: InputEvent) {
        switch event {
        case .control(.up):
            model.moveCharacterSelection(by: -1)
        case .control(.down):
            model.moveCharacterSelection(by: 1)
        case .control(.enter):
            selectCharacter()
        default:
            break
        }
    }

    private func selectCharacter() {
        let model = self.model
        guard let client = model.currentClient(), let id = model.selectedCharacterID() else { return }
        model.setStatus(.loggedIn, message: "Selecting character \(id)...")
        Task.detached {
            do {
                try await client.send(MapleStory83.CharacterSelectRequest(character: id))
            } catch {
                model.setStatus(.failed, message: "Character select failed: \(error)")
            }
        }
    }

    private func handleLogin(_ event: InputEvent) {
        switch event {
        case let .character(character):
            model.append(character)
        case .control(.backspace):
            model.backspace()
        case .control(.tab):
            model.toggleField()
        case .control(.enter):
            submitLogin()
        default:
            break
        }
    }

    private func handleWorldSelect(_ event: InputEvent) {
        switch event {
        case .control(.up):
            model.moveWorldSelection(by: -1)
        case .control(.down):
            model.moveWorldSelection(by: 1)
        case .control(.enter):
            requestCharacters()
        default:
            break
        }
    }

    private func requestCharacters() {
        let model = self.model
        guard let client = model.currentClient() else { return }
        let world = UInt8(min(max(0, model.selectedWorldIndex()), 255))
        model.setStatus(.loggedIn, message: "Loading characters for world \(world)...")
        Task.detached {
            do {
                try await client.send(MapleStory83.CharacterListRequest(world: world, channel: 0))
            } catch {
                model.setStatus(.failed, message: "Character list request failed: \(error)")
            }
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
