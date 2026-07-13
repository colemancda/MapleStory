//
//  Scene.swift
//  MapleStoryClient
//

import Foundation

/// Per-frame drawing context handed to a ``Scene``.
///
/// Coordinates are in logical points with the origin at the top-left.
public struct RenderContext {
    public let renderer: SpriteRenderer
    public let text: TextRenderer
    public let width: Int
    public let height: Int
}

/// A screen of the client (login, world select, gameplay, …), driven by ``Game``.
///
/// The client analogue of the reference client's `UIStateLogin` / `UIStateGame`.
public protocol Scene: AnyObject {

    /// Called once per frame with the set of movement keys currently held down,
    /// before ``update(deltaTime:)``. For continuous motion (walking, camera
    /// panning) rather than discrete key-press events.
    func updateInput(held: Set<ControlKey>)

    /// Advance simulation/animation by `deltaTime` seconds.
    func update(deltaTime: Double)

    /// Draw the scene for the current frame.
    func render(_ context: RenderContext)

    /// Handle a translated input event.
    func handle(_ event: InputEvent)
}

public extension Scene {
    func updateInput(held: Set<ControlKey>) {}
    func update(deltaTime: Double) {}
}
