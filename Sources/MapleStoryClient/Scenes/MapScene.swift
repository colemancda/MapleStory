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
    private let lifeSprites: [WzLifeSprite]
    private var built = false
    /// Uploaded animation frames with precomputed timing.
    private struct FrameAnimation {
        var frames: [(texture: Texture, frame: WzSpriteFrame)]
        /// Cumulative end time of each frame, in milliseconds.
        var frameEnds: [Double]
        var totalMilliseconds: Double

        /// Upload one texture per frame; `nil` when no frame is usable.
        init?(_ source: [WzSpriteFrame]) {
            var frames: [(texture: Texture, frame: WzSpriteFrame)] = []
            for frame in source {
                guard frame.width > 0, frame.height > 0,
                      let texture = try? Texture(width: frame.width, height: frame.height, rgba: frame.rgba) else {
                    continue
                }
                frames.append((texture, frame))
            }
            guard frames.isEmpty == false else { return nil }
            var frameEnds: [Double] = []
            var total: Double = 0
            for (_, frame) in frames {
                total += Double(frame.delayMilliseconds)
                frameEnds.append(total)
            }
            self.frames = frames
            self.frameEnds = frameEnds
            self.totalMilliseconds = total
        }

        /// The frame to show at `time` (seconds since scene start).
        func frame(at time: Double) -> (texture: Texture, frame: WzSpriteFrame) {
            guard frames.count > 1, totalMilliseconds > 0 else { return frames[0] }
            let cycle = (time * 1000).truncatingRemainder(dividingBy: totalMilliseconds)
            for (index, end) in frameEnds.enumerated() where cycle < end {
                return frames[index]
            }
            return frames[frames.count - 1]
        }
    }

    /// A positioned map sprite with its animation.
    private struct AnimatedSprite {
        var sprite: WzMapSprite
        var animation: FrameAnimation

        func frame(at time: Double) -> (texture: Texture, frame: WzSpriteFrame) {
            animation.frame(at: time)
        }
    }

    private var backgroundTextures: [(animation: FrameAnimation, layer: WzMapBackground)] = []
    private var foregroundTextures: [(animation: FrameAnimation, layer: WzMapBackground)] = []

    /// Per map layer (0...7): that layer's objects (z-sorted) followed by its
    /// tiles (z-sorted) - the reference client's `TilesObjs::draw` order.
    private var layerSprites: [[AnimatedSprite]] = []

    /// Per map layer: NPCs standing on that layer's footholds, drawn after the
    /// layer's tiles/objects (the reference client's per-layer draw order).
    private var layerNpcs: [[AnimatedSprite]] = []

    /// A mob that patrols its foothold chain between its spawn bounds.
    private enum MobState { case patrol, hurt, dying }

    private struct MobEntity {
        var x: Float
        var y: Float
        var facingRight = false
        var walking = true
        /// Seconds until the next walk/pause decision.
        var decisionTimer: Double
        var frameIndex = 0
        var frameTimer: Double = 0
        var speed: Float
        var minX: Float
        var maxX: Float
        var layer: Int
        var name: String?
        var stand: FrameAnimation?
        var move: FrameAnimation?
        var hit: FrameAnimation?
        var die: FrameAnimation?
        var hp: Int
        var maxHP: Int
        var state: MobState = .patrol
        /// Seconds remaining in the current hurt/dying state.
        var stateTimer: Double = 0
        var isDead = false

        var currentAnimation: FrameAnimation? {
            switch state {
            case .dying: return die ?? stand
            case .hurt:  return hit ?? stand
            case .patrol: return walking ? (move ?? stand) : (stand ?? move)
            }
        }
    }

    private var mobs: [MobEntity] = []
    private var mobRandom = SystemRandomNumberGenerator()

    /// Base mob walking speed in world units per second (scaled by each mob's
    /// `info/speed` percent modifier).
    public var mobBaseSpeed: Float = 100

    /// Scene clock driving map animations.
    private var sceneTime: Double = 0
    private var standFrames: [CharacterFrameTextures] = []
    private var walkFrames: [CharacterFrameTextures] = []
    private var jumpFrames: [CharacterFrameTextures] = []
    private var attackFrames: [CharacterFrameTextures] = []
    private var ladderFrames: [CharacterFrameTextures] = []
    private var ropeFrames: [CharacterFrameTextures] = []

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

    // Climbing: while attached to a ladder/rope, gravity is suspended and
    // up/down move along it.
    private var isClimbing = false
    private var currentLadder: WzMapLadder?

    // Attacking: plays the swing animation and damages mobs in front on its
    // hit frame.
    private var isAttacking = false
    private var attackHitApplied = false

    /// A floating damage number rising above a struck mob.
    private struct DamageNumber {
        var x: Float
        var y: Float
        var text: String
        var age: Double = 0
    }
    private var damageNumbers: [DamageNumber] = []
    private let damageNumberLifetime: Double = 0.8

    private func spawnDamageNumber(_ amount: Int, x: Float, y: Float) {
        damageNumbers.append(DamageNumber(x: x, y: y, text: "\(amount)"))
    }

    /// Climb speed in world units per second.
    public var climbSpeed: Float = 120

    /// Fade-in duration when the scene starts (masks map-load transitions).
    public var fadeInDuration: Double = 0.4

    /// The player's foot position in world coordinates (read-only; for tests/UI).
    public var playerPosition: (x: Float, y: Float) { (playerX, playerY) }

    /// Whether the player is attached to a ladder/rope.
    public var isPlayerClimbing: Bool { isClimbing }

    /// The map layer of the foothold the player stands on; the player draws
    /// after this layer's content (drawn on top of everything until known).
    private var playerLayer = 7

    /// Walking speed in world units per second.
    public var walkSpeed: Float = 150

    /// Downward acceleration in world units per second².
    public var gravity: Float = 2000

    /// Initial upward velocity of a jump, in world units per second.
    public var jumpSpeed: Float = 700

    /// How far above/below the current feet a foothold still counts as walkable
    /// ground when following slopes and steps.
    public var climbTolerance: Float = 40

    /// Draw foothold segments as red dotted lines (debug).
    public var showFootholds = false

    /// Portal swirl animation frames (from `WzMapLoader.loadPortalAnimation`).
    private let portalFrames: [WzSpriteFrame]
    private var portalSprites: [AnimatedSprite] = []

    /// Called when the player enters a usable portal (up arrow while standing
    /// on it). The host decides whether/how to load the target map.
    public var onEnterPortal: ((WzMapPortal) -> Void)?

    /// Name tags (world foot position + display name) for named life sprites.
    private var nameTags: [(x: Float, y: Float, name: String)] = []

    /// Scale for name-tag text.
    public var nameTagScale: Float = 0.4

    /// Movement keys always treated as held (for headless/debug capture).
    public var debugHeldKeys: Set<ControlKey> = []

    /// Continuously re-trigger the attack (for headless/debug capture).
    public var debugAttack = false

    public init(
        map: WzLoadedMap,
        character: WzLoadedCharacter? = nil,
        lifeSprites: [WzLifeSprite] = [],
        portalFrames: [WzSpriteFrame] = [],
        playerStart: (x: Int, y: Int)? = nil
    ) {
        self.map = map
        self.character = character
        self.lifeSprites = lifeSprites
        self.portalFrames = portalFrames
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
        /// Parts already z-sorted back-to-front by the loader.
        var parts: [CharacterPartTexture]
    }

    /// Upload sprite pixels to GL textures (must run with a current GL context).
    private func buildTextures() {
        backgroundTextures = MapScene.backgroundTextures(for: map.backgrounds)
        foregroundTextures = MapScene.backgroundTextures(for: map.foregrounds)
        // Objects before tiles within each layer (loader arrays are z-sorted).
        let objectTextures = MapScene.animatedSprites(for: map.objects)
        let tileTextures = MapScene.animatedSprites(for: map.tiles)
        layerSprites = (0 ... 7).map { layer in
            objectTextures.filter { $0.sprite.layer == layer } + tileTextures.filter { $0.sprite.layer == layer }
        }

        // NPCs: synthesize positioned sprites, assigned to their foothold's layer.
        let footholdLayers = Dictionary(map.footholds.map { ($0.id, $0.layer) }, uniquingKeysWith: { first, _ in first })
        let npcSprites = lifeSprites.compactMap { npc -> WzMapSprite? in
            guard npc.life.type == "n", npc.life.hidden == false,
                  let first = npc.standFrames.first else { return nil }
            return WzMapSprite(
                rgba: first.rgba, width: first.width, height: first.height,
                x: npc.life.x, y: npc.life.y,
                originX: first.originX, originY: first.originY,
                layer: footholdLayers[npc.life.footholdID] ?? 7,
                z: 0, flipped: npc.life.flipped,
                frames: npc.standFrames
            )
        }
        let npcTextures = MapScene.animatedSprites(for: npcSprites)
        layerNpcs = (0 ... 7).map { layer in
            npcTextures.filter { $0.sprite.layer == layer }
        }

        // Mobs: dynamic entities that patrol their spawn bounds.
        mobs = lifeSprites.compactMap { entry -> MobEntity? in
            guard entry.life.type == "m", entry.life.hidden == false,
                  entry.standFrames.isEmpty == false || entry.moveFrames.isEmpty == false else { return nil }
            let speedScale = Float(max(100 + entry.speedPercent, 10)) / 100
            return MobEntity(
                x: Float(entry.life.x),
                y: Float(entry.life.y),
                facingRight: Bool.random(using: &mobRandom),
                walking: true,
                decisionTimer: Double.random(in: 1 ... 4, using: &mobRandom),
                speed: mobBaseSpeed * speedScale,
                minX: Float(entry.life.patrolMinX ?? (entry.life.x - 150)),
                maxX: Float(entry.life.patrolMaxX ?? (entry.life.x + 150)),
                layer: footholdLayers[entry.life.footholdID] ?? 7,
                name: entry.name,
                stand: FrameAnimation(entry.standFrames),
                move: FrameAnimation(entry.moveFrames),
                hit: FrameAnimation(entry.hitFrames),
                die: FrameAnimation(entry.dieFrames),
                hp: max(entry.maxHP, 1),
                maxHP: max(entry.maxHP, 1)
            )
        }
        nameTags = lifeSprites.compactMap { entry in
            guard entry.life.type == "n", let name = entry.name, name.isEmpty == false,
                  entry.life.hidden == false else { return nil }
            return (Float(entry.life.x), Float(entry.life.y), name)
        }

        // Visible portals: the shared swirl animation at each portal's position.
        if portalFrames.isEmpty == false, let first = portalFrames.first {
            let sprites = map.portals.filter(\.isVisible).map { portal in
                WzMapSprite(rgba: first.rgba, width: first.width, height: first.height,
                            x: portal.x, y: portal.y,
                            originX: first.originX, originY: first.originY,
                            layer: 7, z: 0, flipped: false, frames: portalFrames)
            }
            portalSprites = MapScene.animatedSprites(for: sprites)
        }
        if let character {
            standFrames = MapScene.characterTextures(for: character.stand)
            walkFrames = MapScene.characterTextures(for: character.walk)
            jumpFrames = MapScene.characterTextures(for: character.jump)
            attackFrames = MapScene.characterTextures(for: character.attack)
            ladderFrames = MapScene.characterTextures(for: character.ladder)
            ropeFrames = MapScene.characterTextures(for: character.rope)
        }
        built = true
    }

    private static func animatedSprites(for sprites: [WzMapSprite]) -> [AnimatedSprite] {
        sprites.compactMap { sprite in
            guard let animation = FrameAnimation(sprite.frames) else { return nil }
            return AnimatedSprite(sprite: sprite, animation: animation)
        }
    }

    private static func backgroundTextures(for layers: [WzMapBackground]) -> [(FrameAnimation, WzMapBackground)] {
        layers.compactMap { layer in
            guard let animation = FrameAnimation(layer.frames) else { return nil }
            return (animation, layer)
        }
    }

    private static func characterTextures(for animation: WzCharacterAnimation) -> [CharacterFrameTextures] {
        animation.frames.map { frame in
            CharacterFrameTextures(
                delayMilliseconds: frame.delayMilliseconds,
                parts: frame.parts.compactMap(partTexture)
            )
        }
    }

    private static func partTexture(_ part: WzCharacterPart) -> CharacterPartTexture? {
        guard part.width > 0, part.height > 0,
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
        sceneTime += deltaTime
        // Clamp the simulation step so frame-time spikes (e.g. the first frame,
        // which uploads every texture) can't teleport the player or break the
        // ground-crossing check.
        let deltaTime = min(deltaTime, 0.05)
        heldKeys.formUnion(debugHeldKeys)
        if debugAttack, isAttacking == false, onGround, isClimbing == false, attackFrames.isEmpty == false {
            isAttacking = true
            attackHitApplied = false
            frameIndex = 0
            frameTimer = 0
        }
        updateMobs(deltaTime: deltaTime)
        guard character != nil else {
            // No player: arrows pan the camera directly.
            let step = walkSpeed * Float(deltaTime)
            if heldKeys.contains(.left) { cameraX -= step }
            if heldKeys.contains(.right) { cameraX += step }
            if heldKeys.contains(.up) { cameraY -= step }
            if heldKeys.contains(.down) { cameraY += step }
            return
        }

        updateDamageNumbers(deltaTime: deltaTime)

        if isClimbing {
            updateClimbing(deltaTime: deltaTime)
            cameraX = playerX
            cameraY = playerY
            return
        }

        // Attacking freezes horizontal movement; gravity still applies.
        if isAttacking {
            updateVerticalPhysics(deltaTime: deltaTime)
            cameraX = playerX
            cameraY = playerY
            advanceAttack(deltaTime: deltaTime)
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

        // Holding up mid-air grabs a passing ladder/rope (classic MS behavior).
        if onGround == false, heldKeys.contains(.up), let ladder = ladderAtPlayer() {
            attach(to: ladder)
            return
        }

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

    /// Advance the one-shot attack animation; deal damage on its second frame,
    /// end when it completes.
    private func advanceAttack(deltaTime: Double) {
        guard attackFrames.isEmpty == false else { isAttacking = false; return }
        // Hit lands as the swing connects (frame 1 onward).
        if frameIndex >= 1 && attackHitApplied == false {
            performAttack()
            attackHitApplied = true
        }
        frameTimer += deltaTime * 1000
        let delay = Double(max(attackFrames[frameIndex % attackFrames.count].delayMilliseconds, 1))
        if frameTimer >= delay {
            frameTimer -= delay
            frameIndex += 1
            if frameIndex >= attackFrames.count {
                isAttacking = false
                frameIndex = 0
                frameTimer = 0
            }
        }
    }

    private func updateDamageNumbers(deltaTime: Double) {
        for index in damageNumbers.indices {
            damageNumbers[index].age += deltaTime
            damageNumbers[index].y -= Float(deltaTime) * 60  // rise
        }
        damageNumbers.removeAll { $0.age >= damageNumberLifetime }
    }

    /// Patrol AI: walk along the foothold chain, reversing at patrol bounds or
    /// edges, pausing at random intervals.
    private func updateMobs(deltaTime: Double) {
        for index in mobs.indices {
            var mob = mobs[index]
            switch mob.state {
            case .dying:
                mob.stateTimer -= deltaTime
                advanceAnimation(&mob, deltaTime: deltaTime, loop: false)
                if mob.stateTimer <= 0 { mob.isDead = true }
            case .hurt:
                mob.stateTimer -= deltaTime
                advanceAnimation(&mob, deltaTime: deltaTime, loop: true)
                if mob.stateTimer <= 0 {
                    mob.state = .patrol
                    mob.frameIndex = 0
                    mob.frameTimer = 0
                }
            case .patrol:
                mob.decisionTimer -= deltaTime
                if mob.decisionTimer <= 0 {
                    mob.decisionTimer = Double.random(in: 1.5 ... 4, using: &mobRandom)
                    mob.walking.toggle()
                    if mob.walking { mob.facingRight = Bool.random(using: &mobRandom) }
                    mob.frameIndex = 0
                    mob.frameTimer = 0
                }
                if mob.walking {
                    let step = mob.speed * Float(deltaTime)
                    let newX = mob.x + (mob.facingRight ? step : -step)
                    if newX < mob.minX || newX > mob.maxX {
                        mob.facingRight.toggle()
                    } else if let ground = map.ground(atX: newX, below: mob.y, tolerance: 40),
                              abs(ground.y - mob.y) <= 40 {
                        mob.x = newX
                        mob.y = ground.y
                        mob.layer = ground.foothold.layer
                    } else {
                        mob.facingRight.toggle()
                    }
                }
                advanceAnimation(&mob, deltaTime: deltaTime, loop: true)
            }
            mobs[index] = mob
        }
        mobs.removeAll { $0.isDead }
    }

    /// Advance a mob's current animation; when `loop` is false it holds on the
    /// last frame.
    private func advanceAnimation(_ mob: inout MobEntity, deltaTime: Double, loop: Bool) {
        guard let animation = mob.currentAnimation, animation.frames.count > 1 else { return }
        mob.frameTimer += deltaTime * 1000
        let delay = Double(max(animation.frames[mob.frameIndex % animation.frames.count].frame.delayMilliseconds, 1))
        if mob.frameTimer >= delay {
            mob.frameTimer -= delay
            if loop {
                mob.frameIndex = (mob.frameIndex + 1) % animation.frames.count
            } else {
                mob.frameIndex = min(mob.frameIndex + 1, animation.frames.count - 1)
            }
        }
    }

    /// Damage all living mobs in the attack box in front of the player.
    private func performAttack() {
        let range: Float = 100
        let minX = facingRight ? playerX : playerX - range
        let maxX = facingRight ? playerX + range : playerX
        for index in mobs.indices where mobs[index].state != .dying {
            let mob = mobs[index]
            guard mob.x >= minX, mob.x <= maxX, abs(mob.y - playerY) < 80 else { continue }
            let damage = Int.random(in: 6 ... 14, using: &mobRandom)
            mobs[index].hp -= damage
            spawnDamageNumber(damage, x: mob.x, y: mob.y - 60)
            mobs[index].frameIndex = 0
            mobs[index].frameTimer = 0
            if mobs[index].hp <= 0 {
                mobs[index].state = .dying
                mobs[index].stateTimer = animationDuration(mobs[index].die) + 0.1
            } else {
                mobs[index].state = .hurt
                mobs[index].stateTimer = 0.35
                // Knockback away from the player.
                let knockback: Float = facingRight ? 14 : -14
                mobs[index].x = min(max(mobs[index].x + knockback, mobs[index].minX), mobs[index].maxX)
            }
        }
    }

    private func animationDuration(_ animation: FrameAnimation?) -> Double {
        (animation.map { $0.totalMilliseconds / 1000 }) ?? 0.5
    }

    // MARK: - Climbing

    private func ladderAtPlayer() -> WzMapLadder? {
        map.ladders.first { $0.contains(x: playerX, y: playerY) }
    }

    private func attach(to ladder: WzMapLadder) {
        isClimbing = true
        currentLadder = ladder
        playerX = Float(ladder.x)
        playerY = min(max(playerY, Float(ladder.y1)), Float(ladder.y2))
        velocityY = 0
        onGround = false
        frameIndex = 0
        frameTimer = 0
        cameraX = playerX
        cameraY = playerY
    }

    private func updateClimbing(deltaTime: Double) {
        guard let ladder = currentLadder else {
            isClimbing = false
            return
        }
        let up = heldKeys.contains(.up)
        let down = heldKeys.contains(.down)
        let moving = up != down

        if moving {
            let step = climbSpeed * Float(deltaTime)
            playerY += up ? -step : step
            // Advance the climb animation only while moving.
            let frames = ladder.isLadder ? ladderFrames : ropeFrames
            if frames.isEmpty == false {
                frameTimer += deltaTime * 1000
                let delay = Double(max(frames[frameIndex % frames.count].delayMilliseconds, 1))
                if frameTimer >= delay {
                    frameTimer -= delay
                    frameIndex = (frameIndex + 1) % frames.count
                }
            }
        }

        if playerY <= Float(ladder.y1) {
            // Climbed off the top: step onto the platform above.
            playerY = Float(ladder.y1) - 2
            detachFromLadder()
        } else if playerY >= Float(ladder.y2) {
            // Slid off the bottom: fall.
            playerY = Float(ladder.y2)
            detachFromLadder()
        }
    }

    private func detachFromLadder() {
        isClimbing = false
        currentLadder = nil
        velocityY = 0
        onGround = false
        frameIndex = 0
        frameTimer = 0
    }

    /// Keep the player's feet on foothold geometry: follow slopes/steps while
    /// grounded, otherwise fall under gravity until landing on a foothold.
    private func updateVerticalPhysics(deltaTime: Double) {
        guard map.footholds.isEmpty == false else { return }

        if onGround {
            // Follow the terrain under the (possibly moved) feet.
            if let ground = map.ground(atX: playerX, below: playerY, tolerance: climbTolerance),
               ground.y <= playerY + climbTolerance {
                playerY = ground.y
                playerLayer = ground.foothold.layer
            } else {
                // Walked off an edge.
                onGround = false
                velocityY = 0
            }
        }

        if onGround == false {
            velocityY += gravity * Float(deltaTime)
            let newY = playerY + velocityY * Float(deltaTime)
            // Land on the first foothold crossed while falling. The small
            // tolerance keeps ground reachable when float drift leaves the feet
            // fractionally past it.
            if velocityY > 0,
               let ground = map.ground(atX: playerX, below: playerY, tolerance: 2),
               ground.y <= newY {
                playerY = ground.y
                velocityY = 0
                onGround = true
                playerLayer = ground.foothold.layer
            } else {
                playerY = newY
            }
        }
    }

    // MARK: - Rendering

    public func render(_ context: RenderContext) {
        if built == false { buildTextures() }
        let camera = Camera(x: cameraX, y: cameraY, viewportWidth: Float(context.width), viewportHeight: Float(context.height))

        for (animation, layer) in backgroundTextures {
            let (texture, frame) = animation.frame(at: sceneTime)
            draw(layer, frame: frame, texture: texture, camera: camera, context: context)
        }
        for (layer, sprites) in layerSprites.enumerated() {
            for animated in sprites {
                let (texture, frame) = animated.frame(at: sceneTime)
                drawWorldSprite(animated.sprite, frame: frame, texture: texture, camera: camera, context: context)
            }
            for animated in layerNpcs[layer] {
                let (texture, frame) = animated.frame(at: sceneTime)
                drawWorldSprite(animated.sprite, frame: frame, texture: texture, camera: camera, context: context)
            }
            for mob in mobs where mob.layer == layer {
                drawMob(mob, camera: camera, context: context)
            }
            // The player belongs to its foothold's layer.
            if character != nil && layer == min(playerLayer, layerSprites.count - 1) {
                drawPlayer(camera: camera, context: context)
            }
        }
        for animated in portalSprites {
            let (texture, frame) = animated.frame(at: sceneTime)
            drawWorldSprite(animated.sprite, frame: frame, texture: texture, camera: camera, context: context)
        }
        drawNameTags(camera: camera, context: context)
        drawDamageNumbers(camera: camera, context: context)
        for (animation, layer) in foregroundTextures {
            let (texture, frame) = animation.frame(at: sceneTime)
            draw(layer, frame: frame, texture: texture, camera: camera, context: context)
        }
        if showFootholds {
            drawFootholds(camera: camera, context: context)
        }
        // Fade in from black when the scene starts (masks map transitions).
        if fadeInDuration > 0, sceneTime < fadeInDuration {
            let alpha = Float(1 - sceneTime / fadeInDuration)
            context.renderer.fill(
                Rectangle(x: 0, y: 0, width: Float(context.width), height: Float(context.height)),
                color: RGBAColor(red: 0, green: 0, blue: 0, alpha: alpha)
            )
        }
    }

    /// A mob at its current patrol position (mob art faces left by default).
    private func drawMob(_ mob: MobEntity, camera: Camera, context: RenderContext) {
        guard let animation = mob.currentAnimation, animation.frames.isEmpty == false else { return }
        let (texture, frame) = animation.frames[mob.frameIndex % animation.frames.count]
        let flip = mob.facingRight
        let effectiveOriginX = flip ? (frame.width - frame.originX) : frame.originX
        let screen = camera.screen(forWorldX: mob.x - Float(effectiveOriginX), worldY: mob.y - Float(frame.originY))
        let rect = Rectangle(x: screen.x, y: screen.y, width: Float(frame.width), height: Float(frame.height))
        let uv = flip ? Rectangle(x: 1, y: 0, width: -1, height: 1) : Rectangle(x: 0, y: 0, width: 1, height: 1)
        context.renderer.draw(texture, in: rect, uv: uv)
    }

    /// Name tags: a dark pill under each named life sprite's feet, like the
    /// real client's NPC/mob labels. NPC tags are static; mob tags follow.
    private func drawNameTags(camera: Camera, context: RenderContext) {
        for tag in nameTags {
            drawNameTag(tag.name, x: tag.x, y: tag.y, camera: camera, context: context)
        }
        for mob in mobs {
            if let name = mob.name {
                drawNameTag(name, x: mob.x, y: mob.y, camera: camera, context: context)
            }
        }
    }

    /// Floating damage numbers: rise and fade above struck mobs.
    private func drawDamageNumbers(camera: Camera, context: RenderContext) {
        for number in damageNumbers {
            let alpha = Float(max(0, 1 - number.age / damageNumberLifetime))
            let screen = camera.screen(forWorldX: number.x, worldY: number.y)
            let textWidth = context.text.width(of: number.text, scale: damageNumberScale)
            context.text.draw(number.text, x: screen.x - textWidth / 2, y: screen.y,
                              scale: damageNumberScale,
                              color: RGBAColor(red: 1, green: 0.85, blue: 0.1, alpha: alpha),
                              using: context.renderer)
        }
    }

    private let damageNumberScale: Float = 1.4

    private func drawNameTag(_ name: String, x: Float, y: Float, camera: Camera, context: RenderContext) {
        let screen = camera.screen(forWorldX: x, worldY: y)
        let textWidth = context.text.width(of: name, scale: nameTagScale)
        let textHeight = context.text.lineHeight * nameTagScale
        let padding: Float = 3
        let rect = Rectangle(x: screen.x - textWidth / 2 - padding,
                             y: screen.y + 3,
                             width: textWidth + padding * 2,
                             height: textHeight + padding * 2)
        context.renderer.fill(rect, color: RGBAColor(red: 0, green: 0, blue: 0, alpha: 0.6))
        context.text.draw(name, x: screen.x - textWidth / 2, y: screen.y + 3 + padding,
                          scale: nameTagScale, color: .white, using: context.renderer)
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

    private func drawWorldSprite(_ sprite: WzMapSprite, frame: WzSpriteFrame, texture: Texture, camera: Camera, context: RenderContext) {
        // A flipped sprite mirrors around its origin, so the effective origin x
        // mirrors too.
        let effectiveOriginX = sprite.flipped ? (frame.width - frame.originX) : frame.originX
        let origin = camera.screen(forWorldX: Float(sprite.x - effectiveOriginX), worldY: Float(sprite.y - frame.originY))
        let rect = Rectangle(x: origin.x, y: origin.y, width: Float(frame.width), height: Float(frame.height))
        let uv = sprite.flipped ? Rectangle(x: 1, y: 0, width: -1, height: 1) : Rectangle(x: 0, y: 0, width: 1, height: 1)
        context.renderer.draw(texture, in: rect, uv: uv)
    }

    /// Draw a background/foreground layer with parallax scrolling and tiling.
    private func draw(_ layer: WzMapBackground, frame: WzSpriteFrame, texture: Texture, camera: Camera, context: RenderContext) {
        let viewX = Double(camera.x)
        let viewY = Double(camera.y)
        let wOffset = Double(camera.viewportWidth) / 2
        let hOffset = Double(camera.viewportHeight) / 2

        let shiftX = Double(layer.rx) * (wOffset - viewX) / 100 + wOffset
        let shiftY = Double(layer.ry) * (hOffset - viewY) / 100 + hOffset

        var x = Double(layer.x - frame.originX) + shiftX
        var y = Double(layer.y - frame.originY) + shiftY

        let cx = layer.cx > 0 ? layer.cx : max(frame.width, 1)
        let cy = layer.cy > 0 ? layer.cy : max(frame.height, 1)

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
                                     width: Float(frame.width), height: Float(frame.height))
                context.renderer.draw(texture, in: rect, tint: tint)
                ty += cy
            }
            tx += cx
        }
    }

    /// Draw the player character by attaching parts via matching anchor points:
    /// arm/body via "navel", head/body via "neck", face/head via "brow".
    /// The animation for the player's current pose.
    private func currentPlayerFrames() -> [CharacterFrameTextures] {
        if isAttacking && attackFrames.isEmpty == false {
            return attackFrames
        }
        if isClimbing {
            let frames = (currentLadder?.isLadder ?? true) ? ladderFrames : ropeFrames
            if frames.isEmpty == false { return frames }
        }
        if onGround == false && isClimbing == false && jumpFrames.isEmpty == false {
            return jumpFrames
        }
        return isWalking ? walkFrames : standFrames
    }

    /// Assemble and draw the layered character. Each part's world position comes
    /// from aligning its anchor point to the body skeleton; the whole assembly is
    /// mirrored horizontally around the body pivot when facing left.
    private func drawPlayer(camera: Camera, context: RenderContext) {
        let frames = currentPlayerFrames()
        guard frames.isEmpty == false else { return }
        let frame = frames[frameIndex % frames.count]
        guard let body = frame.parts.first(where: { $0.part.anchor == .root }) else { return }

        // The base character art faces left, so mirror it to face right (matching
        // the mob convention). Climbing poses are drawn unflipped.
        let flip = facingRight && isClimbing == false
        let bodyOrigin = (x: Double(playerX), y: Double(playerY))
        let bodyNavel = add(bodyOrigin, body.part.point("navel"))
        let bodyNeck = add(bodyOrigin, body.part.point("neck"))

        // Head defines the "brow" reference for hair/face/cap.
        var headBrow = bodyNeck
        if let head = frame.parts.first(where: { $0.part.zLayer == "head" }) {
            let headOrigin = subtract(bodyNeck, head.part.point("neck"))
            headBrow = add(headOrigin, head.part.point("brow"))
        }

        // Arm defines the "hand" reference for weapons/gloves.
        var armHand = bodyNavel
        if let arm = frame.parts.first(where: { $0.part.zLayer == "arm" }) {
            let armOrigin = subtract(bodyNavel, arm.part.point("navel"))
            armHand = add(armOrigin, arm.part.point("hand"))
        }

        for part in frame.parts {
            let anchorPoint: (x: Double, y: Double)
            switch part.part.anchor {
            case .root:  anchorPoint = bodyOrigin
            case .navel: anchorPoint = subtract(bodyNavel, part.part.point("navel"))
            case .neck:  anchorPoint = subtract(bodyNeck, part.part.point("neck"))
            case .brow:  anchorPoint = subtract(headBrow, part.part.point("brow"))
            case .hand:  anchorPoint = subtract(armHand, part.part.point("hand"))
            }
            drawPart(part, atOrigin: anchorPoint, pivotX: Double(playerX), flip: flip, camera: camera, context: context)
        }
    }

    private func drawPart(_ part: CharacterPartTexture, atOrigin origin: (x: Double, y: Double), pivotX: Double, flip: Bool, camera: Camera, context: RenderContext) {
        // Facing-right top-left, then mirror the whole part around the body pivot.
        let topLeftY = origin.y - Double(part.part.originY)
        var topLeftX = origin.x - Double(part.part.originX)
        if flip {
            topLeftX = 2 * pivotX - topLeftX - Double(part.part.width)
        }
        let screen = camera.screen(forWorldX: Float(topLeftX), worldY: Float(topLeftY))
        let rect = Rectangle(x: screen.x, y: screen.y, width: Float(part.part.width), height: Float(part.part.height))
        let uv = flip ? Rectangle(x: 1, y: 0, width: -1, height: 1) : Rectangle(x: 0, y: 0, width: 1, height: 1)
        context.renderer.draw(part.texture, in: rect, uv: uv)
    }

    public func handle(_ event: InputEvent) {
        // Continuous movement is driven by `updateInput(held:)`; jumping is a
        // discrete key press (space, matching common private-server bindings).
        if case .character(" ") = event, character != nil {
            if isClimbing {
                // Jump off the ladder/rope.
                detachFromLadder()
                velocityY = -jumpSpeed * 0.6
            } else if onGround {
                velocityY = -jumpSpeed
                onGround = false
            }
        }
        // Control triggers a one-shot ground attack.
        if case .control(.attack) = event, character != nil,
           isAttacking == false, isClimbing == false, onGround,
           attackFrames.isEmpty == false {
            isAttacking = true
            attackHitApplied = false
            frameIndex = 0
            frameTimer = 0
        }
        // Up enters a portal the player stands on, or grabs a ladder/rope.
        if case .control(.up) = event, isClimbing == false {
            if let portal = portalAtPlayer() {
                onEnterPortal?(portal)
            } else if character != nil, let ladder = ladderAtPlayer() {
                attach(to: ladder)
            }
        }
    }

    /// The usable portal the player currently overlaps, if any.
    public func portalAtPlayer() -> WzMapPortal? {
        map.portals.first { portal in
            portal.isUsable &&
            abs(Float(portal.x) - playerX) <= 30 &&
            abs(Float(portal.y) - playerY) <= 60
        }
    }

    private func add(_ origin: (x: Double, y: Double), _ point: (x: Int, y: Int)) -> (x: Double, y: Double) {
        (origin.x + Double(point.x), origin.y + Double(point.y))
    }

    private func subtract(_ origin: (x: Double, y: Double), _ point: (x: Int, y: Int)) -> (x: Double, y: Double) {
        (origin.x - Double(point.x), origin.y - Double(point.y))
    }
}
