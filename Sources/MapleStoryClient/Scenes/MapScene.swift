//
//  MapScene.swift
//  MapleStoryClient
//
//  Renders a decoded WZ map (backgrounds, tiles, objects, foregrounds) through
//  the sprite renderer with a scrolling camera. Background parallax/tiling
//  follows the reference client's `Background::draw` formula: the screen
//  position already incorporates the camera offset via `rx`/`ry`, so
//  backgrounds are drawn directly in screen space rather than through
//  `Camera.screen(forWorldX:worldY:)`.
//

import Foundation
import MapleStoryFile

public final class MapScene: Scene {

    private let map: WzLoadedMap
    private var built = false
    private var backgroundTextures: [(texture: Texture, layer: WzMapBackground)] = []
    private var foregroundTextures: [(texture: Texture, layer: WzMapBackground)] = []
    private var tiles: [(texture: Texture, sprite: WzMapSprite)] = []
    private var objects: [(texture: Texture, sprite: WzMapSprite)] = []

    private var cameraX: Float
    private var cameraY: Float

    public init(map: WzLoadedMap) {
        self.map = map
        self.cameraX = Float(map.left + map.right) / 2
        self.cameraY = Float(map.top + map.bottom) / 2
    }

    /// Upload sprite pixels to GL textures (must run with a current GL context).
    private func buildTextures() {
        backgroundTextures = MapScene.backgroundTextures(for: map.backgrounds)
        foregroundTextures = MapScene.backgroundTextures(for: map.foregrounds)
        tiles = MapScene.textures(for: map.tiles)
        objects = MapScene.textures(for: map.objects)
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
        for (texture, layer) in foregroundTextures {
            draw(layer, texture: texture, camera: camera, context: context)
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

    public func handle(_ event: InputEvent) {
        let step: Float = 40
        switch event {
        case .control(.left): cameraX -= step
        case .control(.right): cameraX += step
        case .control(.up): cameraY -= step
        case .control(.down): cameraY += step
        default: break
        }
    }
}
