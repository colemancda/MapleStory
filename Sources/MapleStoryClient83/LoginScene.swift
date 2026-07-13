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
import MapleStoryFile

/// Real login-screen art decoded from UI.wz (+ its Map.wz-backed backdrop).
struct LoginAssets {
    /// The animated login backdrop: UI.wz/MapLogin.img rendered as a map.
    var background: MapScene?
    /// Login.img/Common/frame - the 800x600 window chrome, origin at its center.
    var frame: WzSpriteFrame?
    /// Login.img/Title/MSTitle - the MapleStory logo.
    var logo: WzSpriteFrame?
    /// Login.img/Title/BtLogin button states.
    var buttonNormal: WzSpriteFrame?
    var buttonPressed: WzSpriteFrame?

    // World select: the unrolled paper scroll, per-world tower buttons,
    // world logos, the channel board, and the "go world" button.
    var worldScroll: WzSpriteFrame?
    var worldButtonNormal: [WzSpriteFrame] = []
    var worldButtonPressed: [WzSpriteFrame] = []
    var worldLogos: [WzSpriteFrame] = []
    var channelBoard: WzSpriteFrame?
    var channelButtons: [WzSpriteFrame] = []
    var goWorldButton: WzSpriteFrame?

    // Character select: the stat card and action buttons.
    var charInfoCard: WzSpriteFrame?
    var selectButton: WzSpriteFrame?
    var newCharButton: WzSpriteFrame?
    var deleteCharButton: WzSpriteFrame?
    /// Loads character-select avatars from Character.wz.
    var characterLoader: WzCharacterLoader?
}

final class LoginScene: Scene {

    let model = LoginModel()
    private let configuration: ClientConfiguration
    private let verbose: Bool

    /// When set, the scene renders the original WZ login screen instead of the
    /// text placeholder.
    var assets: LoginAssets?

    // GL textures for the WZ chrome, created on first render (main thread).
    private var uiBuilt = false
    private var frameTexture: Texture?
    private var logoTexture: Texture?
    private var buttonNormalTexture: Texture?
    private var buttonPressedTexture: Texture?
    private var worldScrollTexture: Texture?
    private var worldButtonNormalTextures: [Texture?] = []
    private var worldButtonPressedTextures: [Texture?] = []
    private var worldLogoTextures: [Texture?] = []
    private var channelBoardTexture: Texture?
    private var channelButtonTextures: [Texture?] = []
    private var goWorldTexture: Texture?
    private var charInfoTexture: Texture?
    private var selectButtonTexture: Texture?
    private var newCharButtonTexture: Texture?
    private var deleteCharButtonTexture: Texture?

    /// Stand-pose avatars for character select, keyed by list index; nil marks
    /// a look that failed to load (so it isn't retried every frame).
    private var avatars: [Int: CharacterSpriteView?] = [:]
    private var avatarLooks: [LoginModel.CharacterLook?] = []
    /// Login button screen rectangle (for click hit-testing), updated per frame.
    private var loginButtonRect: Rectangle?
    private var loginButtonPressedUntil: Double = 0
    private var time: Double = 0

    // The backdrop is a tall scene: the login art occupies world y -600...0
    // and the world-select art y 0...600. The camera scrolls between the two
    // bands like the original client. `scroll` is the current band offset
    // (+300 = login, -300 = world select).
    private var scroll: Float = 300
    private var scrollTarget: Float {
        switch model.currentPhase() {
        case .login: return 300
        case .worldSelect, .characterSelect, .enteringGame, .inGame: return -60
        }
    }
    /// True while the camera is still travelling between bands.
    private var isScrolling: Bool { abs(scroll - scrollTarget) > 1 }

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
        let looks = characterList.characters.map { entry -> LoginModel.CharacterLook? in
            let appearance = entry.appearance
            return LoginModel.CharacterLook(
                skin: Int(appearance.skinColor.rawValue),
                face: Int(appearance.face),
                hair: Int(appearance.hair.rawValue),
                equipment: appearance.equipment.items.values.map(Int.init)
            )
        }
        model.setCharacters(list, looks: looks)
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

    func update(deltaTime: Double) {
        time += deltaTime
        assets?.background?.update(deltaTime: deltaTime)
        // Ease the backdrop toward the current phase's band.
        let step = Float(deltaTime) * 900
        if scroll < scrollTarget {
            scroll = min(scroll + step, scrollTarget)
        } else if scroll > scrollTarget {
            scroll = max(scroll - step, scrollTarget)
        }
    }

    func render(_ context: RenderContext) {
        let snapshot = model.snapshot()
        let renderer = context.renderer
        let text = context.text

        if let assets, snapshot.phase != .inGame {
            renderWZ(assets, snapshot: snapshot, context: context)
            return
        }

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

    // MARK: - WZ login screen

    private func buildUITextures(_ assets: LoginAssets) {
        func texture(_ frame: WzSpriteFrame?) -> Texture? {
            guard let frame, frame.width > 0 else { return nil }
            return try? Texture(width: frame.width, height: frame.height, rgba: frame.rgba)
        }
        frameTexture = texture(assets.frame)
        logoTexture = texture(assets.logo)
        buttonNormalTexture = texture(assets.buttonNormal)
        buttonPressedTexture = texture(assets.buttonPressed)
        worldScrollTexture = texture(assets.worldScroll)
        worldButtonNormalTextures = assets.worldButtonNormal.map(texture)
        worldButtonPressedTextures = assets.worldButtonPressed.map(texture)
        worldLogoTextures = assets.worldLogos.map(texture)
        channelBoardTexture = texture(assets.channelBoard)
        channelButtonTextures = assets.channelButtons.map(texture)
        goWorldTexture = texture(assets.goWorldButton)
        charInfoTexture = texture(assets.charInfoCard)
        selectButtonTexture = texture(assets.selectButton)
        newCharButtonTexture = texture(assets.newCharButton)
        deleteCharButtonTexture = texture(assets.deleteCharButton)
        uiBuilt = true
    }

    /// The original v62 login screen: the MapLogin backdrop, window frame,
    /// logo, sign-in fields, and the real login button.
    private func renderWZ(_ assets: LoginAssets, snapshot: LoginModel.Snapshot, context: RenderContext) {
        if uiBuilt == false { buildUITextures(assets) }
        // The backdrop layers are screen-anchored (rx/ry -100), so the camera
        // value directly offsets the art: center the current band.
        assets.background?.setCamera(x: Float(context.width) / 2,
                                     y: Float(context.height) / 2 + scroll)
        assets.background?.render(context)

        // Positions are in the original 800x600 design space, centered on screen.
        let centerX = Float(context.width) / 2
        let centerY = Float(context.height) / 2
        switch snapshot.phase {
        case .login:
            if let logo = assets.logo, let logoTexture {
                let rect = Rectangle(x: centerX - Float(logo.width) / 2, y: centerY - 270,
                                     width: Float(logo.width), height: Float(logo.height))
                context.renderer.draw(logoTexture, in: rect)
            }
            drawLoginForm(assets, snapshot: snapshot, centerX: centerX, centerY: centerY, context: context)
        case .worldSelect where isScrolling == false:
            drawWorldSelect(assets, snapshot: snapshot, centerX: centerX, centerY: centerY, context: context)
        case .characterSelect where isScrolling == false:
            drawCharacterSelect(assets, snapshot: snapshot, centerX: centerX, centerY: centerY, context: context)
        case .worldSelect, .characterSelect, .enteringGame, .inGame:
            break
        }

        // Window chrome above the content, like the original client.
        if let frame = assets.frame, let frameTexture {
            let rect = Rectangle(x: centerX - Float(frame.originX), y: centerY - Float(frame.originY),
                                 width: Float(frame.width), height: Float(frame.height))
            context.renderer.draw(frameTexture, in: rect)
        }

        if snapshot.message.isEmpty == false {
            let scale: Float = 0.45
            let width = context.text.width(of: snapshot.message, scale: scale)
            context.text.draw(snapshot.message, x: centerX - width / 2, y: centerY + 268,
                              scale: scale, color: .white, using: context.renderer)
        }
    }

    /// ID/PW entry over the login signboard, with the real BtLogin button.
    private func drawLoginForm(_ assets: LoginAssets, snapshot: LoginModel.Snapshot,
                               centerX: Float, centerY: Float, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text

        // Field boxes in design space.
        let fieldX: Float = -110
        let fieldWidth: Float = 150
        let fieldHeight: Float = 21
        let idY: Float = -25
        let pwY: Float = 1

        func drawField(_ value: String, active: Bool, y: Float) {
            let rect = Rectangle(x: centerX + fieldX, y: centerY + y, width: fieldWidth, height: fieldHeight)
            renderer.fill(rect, color: RGBAColor(red: 1, green: 1, blue: 1, alpha: active ? 0.95 : 0.75))
            var shown = value
            if active, Int(time * 2) % 2 == 0 { shown += "|" }
            text.draw(shown, x: rect.x + 5, y: rect.y + 3, scale: 0.45,
                      color: RGBAColor(red: 0.1, green: 0.1, blue: 0.25, alpha: 1), using: renderer)
        }
        drawField(snapshot.username, active: snapshot.activeField == 0, y: idY)
        drawField(String(repeating: "*", count: snapshot.password.count),
                  active: snapshot.activeField == 1, y: pwY)

        // The real login button, pressed state while flashing after a click.
        let pressed = time < loginButtonPressedUntil
        let buttonFrame = pressed ? (assets.buttonPressed ?? assets.buttonNormal) : assets.buttonNormal
        let buttonTexture = pressed ? (buttonPressedTexture ?? buttonNormalTexture) : buttonNormalTexture
        if let buttonFrame, let buttonTexture {
            let rect = Rectangle(x: centerX + fieldX + fieldWidth + 8, y: centerY + idY,
                                 width: Float(buttonFrame.width), height: Float(buttonFrame.height))
            context.renderer.draw(buttonTexture, in: rect)
            loginButtonRect = rect
        }
    }

    /// World select: the unrolled paper scroll with the world tower buttons,
    /// the selected world's logo, and the channel board.
    private func drawWorldSelect(_ assets: LoginAssets, snapshot: LoginModel.Snapshot,
                                 centerX: Float, centerY: Float, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text

        if let scroll = assets.worldScroll, let worldScrollTexture {
            let rect = Rectangle(x: centerX - Float(scroll.width) / 2, y: centerY - 235,
                                 width: Float(scroll.width), height: Float(scroll.height))
            renderer.draw(worldScrollTexture, in: rect)
        }

        // One tower button per world reported by the server.
        let buttonCount = min(snapshot.worlds.count, worldButtonNormalTextures.count)
        let spacing: Float = 28
        let rowWidth = Float(buttonCount) * spacing
        let rowX = centerX - rowWidth / 2
        for index in 0 ..< buttonCount {
            let selected = index == snapshot.selectedWorld
            let pressed = index < worldButtonPressedTextures.count ? worldButtonPressedTextures[index] : nil
            guard let texture = (selected ? pressed : nil) ?? worldButtonNormalTextures[index] else { continue }
            let frame = assets.worldButtonNormal[index]
            let rect = Rectangle(x: rowX + Float(index) * spacing, y: centerY - 195,
                                 width: Float(frame.width), height: Float(frame.height))
            renderer.draw(texture, in: rect)
            // The server's world name under its tower button.
            if selected {
                let name = snapshot.worlds[index]
                let nameWidth = text.width(of: name, scale: 0.4)
                text.draw(name, x: rect.x + rect.width / 2 - nameWidth / 2, y: rect.y + rect.height + 4,
                          scale: 0.4, color: RGBAColor(red: 0.35, green: 0.2, blue: 0.05, alpha: 1), using: renderer)
            }
        }

        // Selected world logo beside the tower row.
        if snapshot.selectedWorld < worldLogoTextures.count,
           let logoTexture = worldLogoTextures[snapshot.selectedWorld] {
            let frame = assets.worldLogos[snapshot.selectedWorld]
            let rect = Rectangle(x: rowX + rowWidth + 16, y: centerY - 185,
                                 width: Float(frame.width), height: Float(frame.height))
            renderer.draw(logoTexture, in: rect)
        }

        // Channel board with its channel-number grid (channel 0 is joined
        // automatically for now).
        if let board = assets.channelBoard, let channelBoardTexture {
            let boardRect = Rectangle(x: centerX - Float(board.width) / 2, y: centerY - 55,
                                      width: Float(board.width), height: Float(board.height))
            renderer.draw(channelBoardTexture, in: boardRect)
            for (index, texture) in channelButtonTextures.enumerated() {
                guard let texture, index < assets.channelButtons.count else { continue }
                let frame = assets.channelButtons[index]
                let column = index % 4
                let row = index / 4
                let rect = Rectangle(x: boardRect.x + 40 + Float(column) * 96,
                                     y: boardRect.y + 55 + Float(row) * 36,
                                     width: Float(frame.width), height: Float(frame.height))
                renderer.draw(texture, in: rect)
            }
        }
        if let go = assets.goWorldButton, let goWorldTexture {
            let rect = Rectangle(x: centerX + 122, y: centerY + 152,
                                 width: Float(go.width), height: Float(go.height))
            renderer.draw(goWorldTexture, in: rect)
        }
    }

    /// Character select: name plates on the forest floor plus the stat card
    /// and action buttons on the right, from CharSelect art.
    private func drawCharacterSelect(_ assets: LoginAssets, snapshot: LoginModel.Snapshot,
                                     centerX: Float, centerY: Float, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text

        // Rebuild avatar cache when the character list changes.
        if avatarLooks != snapshot.characterLooks {
            avatarLooks = snapshot.characterLooks
            avatars.removeAll()
        }

        for (index, name) in snapshot.characters.enumerated() {
            let x = centerX - 300 + Float(index) * 130
            let y = centerY + 40
            let selected = index == snapshot.selectedCharacter
            if selected {
                renderer.fill(Rectangle(x: x - 10, y: y - 96, width: 90, height: 120),
                              color: RGBAColor(red: 1, green: 0.9, blue: 0.4, alpha: 0.22))
            }
            // The character standing on the forest floor.
            if let avatar = avatar(at: index) {
                avatar.draw(x: x + 35, y: y - 4, time: time, renderer: renderer)
            }
            let nameWidth = text.width(of: name, scale: 0.45)
            let plate = Rectangle(x: x + 35 - nameWidth / 2 - 4, y: y, width: nameWidth + 8, height: 20)
            renderer.fill(plate, color: RGBAColor(red: 0, green: 0, blue: 0,
                                                  alpha: selected ? 0.85 : 0.55))
            text.draw(name, x: plate.x + 4, y: plate.y + 3, scale: 0.45,
                      color: selected ? RGBAColor(red: 1, green: 0.9, blue: 0.4, alpha: 1) : .white,
                      using: renderer)
        }

        drawCharacterCard(assets, snapshot: snapshot, centerX: centerX, centerY: centerY, context: context)
    }

    /// Build (once) and return the stand-pose avatar for a character.
    private func avatar(at index: Int) -> CharacterSpriteView? {
        if let cached = avatars[index] { return cached }
        guard let loader = assets?.characterLoader,
              index < avatarLooks.count, let look = avatarLooks[index] else {
            avatars.updateValue(nil, forKey: index)
            return nil
        }
        let equipment = look.equipment.compactMap(WzEquipItem.init(itemID:))
            + [WzEquipItem(category: "Hair", id: look.hair)]
        let view = (try? loader.loadStand(skin: look.skin, faceID: look.face, equipment: equipment))
            .map(CharacterSpriteView.init)
        avatars[index] = view
        return view
    }

    private func drawCharacterCard(_ assets: LoginAssets, snapshot: LoginModel.Snapshot,
                                   centerX: Float, centerY: Float, context: RenderContext) {
        let renderer = context.renderer
        let text = context.text

        // Stat card + buttons column, right side like the original.
        if let card = assets.charInfoCard, let charInfoTexture {
            let rect = Rectangle(x: centerX + 195 - Float(card.originX), y: centerY - 130 - Float(card.originY),
                                 width: Float(card.width), height: Float(card.height))
            renderer.draw(charInfoTexture, in: rect)
            if snapshot.selectedCharacter < snapshot.characters.count {
                let name = snapshot.characters[snapshot.selectedCharacter]
                let nameWidth = text.width(of: name, scale: 0.4)
                text.draw(name, x: rect.x + Float(card.width) / 2 - nameWidth / 2,
                          y: rect.y - 16, scale: 0.4, color: .white, using: renderer)
            }
        }
        var buttonY = centerY - 40
        for (frame, texture) in [(assets.selectButton, selectButtonTexture),
                                 (assets.newCharButton, newCharButtonTexture),
                                 (assets.deleteCharButton, deleteCharButtonTexture)] {
            guard let frame, let texture else { continue }
            let rect = Rectangle(x: centerX + 200, y: buttonY,
                                 width: Float(frame.width), height: Float(frame.height))
            renderer.draw(texture, in: rect)
            buttonY += Float(frame.height) + 8
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
            loginButtonPressedUntil = time + 0.15
            submitLogin()
        case let .mouseDown(x, y):
            if let rect = loginButtonRect,
               x >= rect.x, x <= rect.x + rect.width,
               y >= rect.y, y <= rect.y + rect.height {
                loginButtonPressedUntil = time + 0.15
                submitLogin()
            }
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
