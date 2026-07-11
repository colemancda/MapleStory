//
//  MapScene.swift
//  MapleStoryClient
//
//  Renders a decoded WZ map (backgrounds, tiles, objects) through the sprite
//  renderer with a scrolling camera.
//

import Foundation
import MapleStoryFile

public final class MapScene: Scene {

    private let map: WzLoadedMap
    private var built = false
    private var backgrounds: [(texture: Texture, sprite: WzMapSprite)] = []
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
        backgrounds = MapScene.textures(for: map.backgrounds)
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

    public func render(_ context: RenderContext) {
        if built == false { buildTextures() }
        let camera = Camera(x: cameraX, y: cameraY, viewportWidth: Float(context.width), viewportHeight: Float(context.height))
        for group in [backgrounds, tiles, objects] {
            for (texture, sprite) in group {
                let origin = camera.screen(forWorldX: Float(sprite.x - sprite.originX), worldY: Float(sprite.y - sprite.originY))
                let rect = Rectangle(x: origin.x, y: origin.y, width: Float(sprite.width), height: Float(sprite.height))
                context.renderer.draw(texture, in: rect)
            }
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
