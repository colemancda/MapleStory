//
//  MapScene.swift
//  MapleStoryClient
//
//  Renders a decoded WZ map (backgrounds, tiles, objects, foregrounds) through
//  the sprite renderer with a scrolling camera, plus an optional walking player
//  character. Background parallax/tiling follows the reference client's
//  `Background::draw` formula: the screen position already incorporates the
//  camera offset via `rx`/`ry`, so backgrounds are drawn directly in screen
//  space rather than through `Camera.screen(forWorldX:worldY:)`.
//
//  Character parts are attached to each other by matching same-named anchor
//  points (e.g. arm's "navel" to body's "navel"), which are stored relative to
//  each part's own canvas origin. See `WzCharacterLoader`.
//

import Foundation
import MapleStoryFile

public final class MapScene: Scene {

    private let map: WzLoadedMap
    private let character: WzLoadedCharacter?
    private var built = false
    private var backgroundTextures: [(texture: Texture, layer: WzMapBackground)] = []
    private var foregroundTextures: [(texture: Texture, layer: WzMapBackground)] = []
    private var tiles: [(texture: Texture, sprite: WzMapSprite)] = []
    private var objects: [(texture: Texture, sprite: WzMapSprite)] = []
    private var standFrames: [CharacterFrameTextures] = []
    private var walkFrames: [CharacterFrameTextures] = []

    private var cameraX: Float
    private var cameraY: Float

    // Player state (only used when `character != nil`).
    private var playerX: Float
    private var playerY: Float
    private var facingRight = true
    private var isWalking = false
    private var frameIndex = 0
    private var frameTimer: Double = 0
    private var heldKeys: Set<ControlKey> = []

    // Vertical physics: the player position is the foot point; footholds are ground.
    private var velocityY: Float = 0
    private var onGround = false

    /// Walking speed in world units per second.
    public var walkSpeed: Float = 150

    /// Downward acceleration in world units per second².
    public var gravity: Float = 2000

    /// How far above/below the current feet a foothold still counts as walkable
    /// ground when following slopes and steps.
    public var climbTolerance: Float = 40

    /// Draw foothold segments as red dotted lines (debug).
    public var showFootholds = false

    public init(map: WzLoadedMap, character: WzLoadedCharacter? = nil, playerStart: (x: Int, y: Int)? = nil) {
        self.map = map
        self.character = character
        self.cameraX = Float(map.left + map.right) / 2
        self.cameraY = Float(map.top + map.bottom) / 2
        let start = playerStart ?? (map.spawnX, map.spawnY)
        self.playerX = Float(start.x)
        self.playerY = Float(start.y)
    }

    // MARK: - Texture upload

    private struct CharacterPartTexture {
        var texture: Texture
        var part: WzCharacterPart
    }

    private struct CharacterFrameTextures {
        var delayMilliseconds: Int
        var body: CharacterPartTexture?
        var arm: CharacterPartTexture?
        var head: CharacterPartTexture?
        var face: CharacterPartTexture?
    }

    /// Upload sprite pixels to GL textures (must run with a current GL context).
    private func buildTextures() {
        backgroundTextures = MapScene.backgroundTextures(for: map.backgrounds)
        foregroundTextures = MapScene.backgroundTextures(for: map.foregrounds)
        tiles = MapScene.textures(for: map.tiles)
        objects = MapScene.textures(for: map.objects)
        if let character {
            standFrames = MapScene.characterTextures(for: character.stand)
            walkFrames = MapScene.characterTextures(for: character.walk)
        }
        built = true
    }

    private static func textures(for sprites: [WzMapSprite]) -> [(Texture, WzMapSprite)] {
        sprites.compactMap { sprite in
            guard sprite.width > 0, sprite.height > 0,
                  let texture = try? Texture(width: sprite.width, height: sprite.height, rgba: sprite.rgba) else {
                return nil
            }
            return (texture, sprite)
        }
    }

    private static func backgroundTextures(for layers: [WzMapBackground]) -> [(Texture, WzMapBackground)] {
        layers.compactMap { layer in
            guard layer.width > 0, layer.height > 0,
                  let texture = try? Texture(width: layer.width, height: layer.height, rgba: layer.rgba) else {
                return nil
            }
            return (texture, layer)
        }
    }

    private static func characterTextures(for animation: WzCharacterAnimation) -> [CharacterFrameTextures] {
        animation.frames.map { frame in
            CharacterFrameTextures(
                delayMilliseconds: frame.delayMilliseconds,
                body: partTexture(frame.body),
                arm: partTexture(frame.arm),
                head: partTexture(frame.head),
                face: partTexture(frame.face)
            )
        }
    }

    private static func partTexture(_ part: WzCharacterPart?) -> CharacterPartTexture? {
        guard let part, part.width > 0, part.height > 0,
              let texture = try? Texture(width: part.width, height: part.height, rgba: part.rgba) else {
            return nil
        }
        return CharacterPartTexture(texture: texture, part: part)
    }

    // MARK: - Input

    public func updateInput(held: Set<ControlKey>) {
        heldKeys = held
    }

    public func update(deltaTime: Double) {
        guard character != nil else {
            // No player: arrows pan the camera directly.
            let step = walkSpeed * Float(deltaTime)
            if heldKeys.contains(.left) { cameraX -= step }
            if heldKeys.contains(.right) { cameraX += step }
            if heldKeys.contains(.up) { cameraY -= step }
            if heldKeys.contains(.down) { cameraY += step }
            return
        }

        let movingLeft = heldKeys.contains(.left)
        let movingRight = heldKeys.contains(.right)
        let wasWalking = isWalking
        isWalking = movingLeft != movingRight

        let step = walkSpeed * Float(deltaTime)
        if movingRight && movingLeft == false {
            playerX += step
            facingRight = true
        } else if movingLeft && movingRight == false {
            playerX -= step
            facingRight = false
        }
        playerX = min(max(playerX, Float(map.left)), Float(map.right))

        updateVerticalPhysics(deltaTime: deltaTime)

        cameraX = playerX
        cameraY = playerY

        if isWalking != wasWalking {
            frameIndex = 0
            frameTimer = 0
        }

        let frames = isWalking ? walkFrames : standFrames
        guard frames.isEmpty == false else { return }
        frameTimer += deltaTime * 1000
        let delay = Double(max(frames[frameIndex % frames.count].delayMilliseconds, 1))
        if frameTimer >= delay {
            frameTimer -= delay
            frameIndex = (frameIndex + 1) % frames.count
        }
    }

    /// Keep the player's feet on foothold geometry: follow slopes/steps while
    /// grounded, otherwise fall under gravity until landing on a foothold.
    private func updateVerticalPhysics(deltaTime: Double) {
        guard map.footholds.isEmpty == false else { return }

        if onGround {
            // Follow the terrain under the (possibly moved) feet.
            if let ground = map.groundY(atX: playerX, below: playerY, tolerance: climbTolerance),
               ground <= playerY + climbTolerance {
                playerY = ground
            } else {
                // Walked off an edge.
                onGround = false
                velocityY = 0
            }
        }

        if onGround == false {
            velocityY += gravity * Float(deltaTime)
            let newY = playerY + velocityY * Float(deltaTime)
            // Land on the first foothold crossed while falling.
            if velocityY > 0,
               let ground = map.groundY(atX: playerX, below: playerY),
               ground <= newY {
                playerY = ground
                velocityY = 0
                onGround = true
            } else {
                playerY = newY
            }
        }
    }

    // MARK: - Rendering

    public func render(_ context: RenderContext) {
        if built == false { buildTextures() }
        let camera = Camera(x: cameraX, y: cameraY, viewportWidth: Float(context.width), viewportHeight: Float(context.height))

        for (texture, layer) in backgroundTextures {
            draw(layer, texture: texture, camera: camera, context: context)
        }
        for (texture, sprite) in tiles {
            drawWorldSprite(sprite, texture: texture, camera: camera, context: context)
        }
        for (texture, sprite) in objects {
            drawWorldSprite(sprite, texture: texture, camera: camera, context: context)
        }
        if character != nil {
            drawPlayer(camera: camera, context: context)
        }
        for (texture, layer) in foregroundTextures {
            draw(layer, texture: texture, camera: camera, context: context)
        }
        if showFootholds {
            drawFootholds(camera: camera, context: context)
        }
    }

    /// Debug overlay: each foothold as a dotted line (red = ground, blue = wall).
    private func drawFootholds(camera: Camera, context: RenderContext) {
        let ground = RGBAColor(red: 1, green: 0.1, blue: 0.1, alpha: 0.9)
        let wall = RGBAColor(red: 0.2, green: 0.4, blue: 1, alpha: 0.9)
        for foothold in map.footholds {
            let steps = max(Int(max(abs(foothold.x2 - foothold.x1), abs(foothold.y2 - foothold.y1))) / 4, 1)
            for step in 0 ... steps {
                let t = Float(step) / Float(steps)
                let x = Float(foothold.x1) + t * Float(foothold.x2 - foothold.x1)
                let y = Float(foothold.y1) + t * Float(foothold.y2 - foothold.y1)
                let screen = camera.screen(forWorldX: x, worldY: y)
                context.renderer.fill(
                    Rectangle(x: screen.x - 1, y: screen.y - 1, width: 3, height: 3),
                    color: foothold.isWall ? wall : ground
                )
            }
        }
    }

    private func drawWorldSprite(_ sprite: WzMapSprite, texture: Texture, camera: Camera, context: RenderContext) {
        let origin = camera.screen(forWorldX: Float(sprite.x - sprite.originX), worldY: Float(sprite.y - sprite.originY))
        let rect = Rectangle(x: origin.x, y: origin.y, width: Float(sprite.width), height: Float(sprite.height))
        context.renderer.draw(texture, in: rect)
    }

    /// Draw a background/foreground layer with parallax scrolling and tiling.
    private func draw(_ layer: WzMapBackground, texture: Texture, camera: Camera, context: RenderContext) {
        let viewX = Double(camera.x)
        let viewY = Double(camera.y)
        let wOffset = Double(camera.viewportWidth) / 2
        let hOffset = Double(camera.viewportHeight) / 2

        let shiftX = Double(layer.rx) * (wOffset - viewX) / 100 + wOffset
        let shiftY = Double(layer.ry) * (hOffset - viewY) / 100 + hOffset

        var x = Double(layer.x - layer.originX) + shiftX
        var y = Double(layer.y - layer.originY) + shiftY

        let cx = layer.cx > 0 ? layer.cx : max(layer.width, 1)
        let cy = layer.cy > 0 ? layer.cy : max(layer.height, 1)

        if layer.horizontalTile {
            while x > 0 { x -= Double(cx) }
            while x < Double(-cx) { x += Double(cx) }
        }
        if layer.verticalTile {
            while y > 0 { y -= Double(cy) }
            while y < Double(-cy) { y += Double(cy) }
        }

        let horizontalTiles = layer.horizontalTile ? Int(camera.viewportWidth) / cx + 3 : 1
        let verticalTiles = layer.verticalTile ? Int(camera.viewportHeight) / cy + 3 : 1

        let tint = RGBAColor(red: 1, green: 1, blue: 1, alpha: layer.opacity)
        var tx = 0
        while tx < cx * horizontalTiles {
            var ty = 0
            while ty < cy * verticalTiles {
                let rect = Rectangle(x: Float(x) + Float(tx), y: Float(y) + Float(ty),
                                     width: Float(layer.width), height: Float(layer.height))
                context.renderer.draw(texture, in: rect, tint: tint)
                ty += cy
            }
            tx += cx
        }
    }

    /// Draw the player character by attaching parts via matching anchor points:
    /// arm/body via "navel", head/body via "neck", face/head via "brow".
    private func drawPlayer(camera: Camera, context: RenderContext) {
        let frames = isWalking ? walkFrames : standFrames
        guard frames.isEmpty == false else { return }
        let frame = frames[frameIndex % frames.count]
        guard let body = frame.body else { return }

        let flip = facingRight == false
        let bodyOrigin = (x: Double(playerX), y: Double(playerY))
        drawPart(body, atOrigin: bodyOrigin, flip: flip, camera: camera, context: context)

        if let arm = frame.arm {
            let bodyNavel = add(bodyOrigin, body.part.point("navel"))
            let armOrigin = subtract(bodyNavel, arm.part.point("navel"))
            drawPart(arm, atOrigin: armOrigin, flip: flip, camera: camera, context: context)
        }
        if let head = frame.head {
            let bodyNeck = add(bodyOrigin, body.part.point("neck"))
            let headOrigin = subtract(bodyNeck, head.part.point("neck"))
            drawPart(head, atOrigin: headOrigin, flip: flip, camera: camera, context: context)

            if let face = frame.face {
                let headBrow = add(headOrigin, head.part.point("brow"))
                let faceOrigin = subtract(headBrow, face.part.point("brow"))
                drawPart(face, atOrigin: faceOrigin, flip: flip, camera: camera, context: context)
            }
        }
    }

    private func drawPart(_ part: CharacterPartTexture, atOrigin origin: (x: Double, y: Double), flip: Bool, camera: Camera, context: RenderContext) {
        let effectiveOriginX = flip ? (part.part.width - part.part.originX) : part.part.originX
        let topLeftX = origin.x - Double(effectiveOriginX)
        let topLeftY = origin.y - Double(part.part.originY)
        let screen = camera.screen(forWorldX: Float(topLeftX), worldY: Float(topLeftY))
        let rect = Rectangle(x: screen.x, y: screen.y, width: Float(part.part.width), height: Float(part.part.height))
        let uv = flip ? Rectangle(x: 1, y: 0, width: -1, height: 1) : Rectangle(x: 0, y: 0, width: 1, height: 1)
        context.renderer.draw(part.texture, in: rect, uv: uv)
    }

    public func handle(_ event: InputEvent) {
        // Movement is driven by `updateInput(held:)`; no discrete events to handle.
    }

    private func add(_ origin: (x: Double, y: Double), _ point: (x: Int, y: Int)) -> (x: Double, y: Double) {
        (origin.x + Double(point.x), origin.y + Double(point.y))
    }

    private func subtract(_ origin: (x: Double, y: Double), _ point: (x: Int, y: Int)) -> (x: Double, y: Double) {
        (origin.x - Double(point.x), origin.y - Double(point.y))
    }
}
