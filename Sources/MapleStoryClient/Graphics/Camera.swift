//
//  Camera.swift
//  MapleStoryClient
//
//  A 2D camera that maps world coordinates to screen coordinates, centered on its
//  position — the client analogue of the reference client's `Camera`.
//

import Foundation

public struct Camera: Sendable, Equatable {

    /// World-space position the camera is centered on.
    public var x: Float
    public var y: Float

    /// Viewport size in screen points.
    public var viewportWidth: Float
    public var viewportHeight: Float

    public init(x: Float = 0, y: Float = 0, viewportWidth: Float, viewportHeight: Float) {
        self.x = x
        self.y = y
        self.viewportWidth = viewportWidth
        self.viewportHeight = viewportHeight
    }

    /// Convert a world-space point to a screen-space point.
    public func screen(forWorldX worldX: Float, worldY: Float) -> (x: Float, y: Float) {
        (x: worldX - x + viewportWidth / 2, y: worldY - y + viewportHeight / 2)
    }

    /// The screen-space rectangle for a world-space rectangle of the given size.
    public func screenRect(worldX: Float, worldY: Float, width: Float, height: Float) -> Rectangle {
        let origin = screen(forWorldX: worldX, worldY: worldY)
        return Rectangle(x: origin.x, y: origin.y, width: width, height: height)
    }
}
