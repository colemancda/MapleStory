//
//  Game.swift
//  MapleStoryClient
//
//  Owns the SDL3 window + OpenGL context and runs the main loop, mirroring the
//  reference client's `Window` + `MapleStory.cpp` entry point.
//

import Foundation
import SDL3Swift

/// The application shell: creates an OpenGL window and runs the render loop,
/// forwarding input and drawing to the active ``Scene``.
///
/// Must be created and run on the main thread (SDL / OpenGL requirement).
public final class Game {

    public let window: SDLWindow
    private let glContext: SDLGLContext
    private let renderer: SpriteRenderer
    private let text: TextRenderer
    private var scene: Scene?
    private var isRunning = true

    /// Background clear color.
    public var clearColor: RGBAColor = .gray(0.08)

    public init(title: String, width: Int = 1024, height: Int = 768) throws {
        try SDL.initialize(subSystems: [.video])
        try SDL.glSetAttribute(.contextProfileMask, GLAttribute.Profile.core.rawValue)
        try SDL.glSetAttribute(.contextMajorVersion, 3)
        try SDL.glSetAttribute(.contextMinorVersion, 3)

        let window = try SDLWindow(
            title: title,
            frame: (x: .centered, y: .centered, width: width, height: height),
            options: [.opengl]
        )
        let glContext = try SDLGLContext(window: window)
        try glContext.makeCurrent(in: window)
        try? SDL.glSetSwapInterval(1)

        self.window = window
        self.glContext = glContext
        self.renderer = try SpriteRenderer()
        self.text = try TextRenderer()
        GL.enableAlphaBlending()
    }

    public func setScene(_ scene: Scene) {
        self.scene = scene
    }

    public func stop() {
        isRunning = false
    }

    /// Run the blocking main loop until the window is closed.
    public func run() throws {
        var last = SDL.ticks
        while isRunning {
            while let event = SDL.pollEvent() {
                translate(event)
            }
            let now = SDL.ticks
            let deltaTime = Double(now &- last) / 1000
            last = now

            scene?.update(deltaTime: deltaTime)

            let (pointWidth, pointHeight) = window.size
            let (pixelWidth, pixelHeight) = window.drawableSize
            GL.viewport(width: pixelWidth, height: pixelHeight)
            GL.clear(red: clearColor.red, green: clearColor.green, blue: clearColor.blue, alpha: clearColor.alpha)
            renderer.begin(width: pointWidth, height: pointHeight)
            if let scene {
                scene.render(RenderContext(renderer: renderer, text: text, width: pointWidth, height: pointHeight))
            }
            try window.glSwap()
        }
        SDL.quit()
    }

    // MARK: - Event Translation

    private func translate(_ event: SDLEvent) {
        switch event {
        case .quit, .windowCloseRequested:
            isRunning = false
            scene?.handle(.quit)
        case let .keyDown(scancode, _):
            if let translated = Game.map(scancode: scancode.rawValue) {
                scene?.handle(translated)
            }
        case let .mouseButtonDown(_, x, y, _):
            scene?.handle(.mouseDown(x: x, y: y))
        case let .windowResized(_, width, height):
            scene?.handle(.resize(width: Int(width), height: Int(height)))
        default:
            break
        }
    }

    /// Map a raw SDL scancode to an ``InputEvent``. Values are the stable SDL
    /// USB-HID scancodes; only the subset needed for text entry is handled.
    private static func map(scancode: UInt32) -> InputEvent? {
        switch scancode {
        case 4...29: // A...Z
            let letter = Character(UnicodeScalar(UInt8(97 + (scancode - 4))))
            return .character(letter)
        case 30...38: // 1...9
            let digit = Character(UnicodeScalar(UInt8(49 + (scancode - 30))))
            return .character(digit)
        case 39: // 0
            return .character("0")
        case 44: // space
            return .character(" ")
        case 40: // return
            return .control(.enter)
        case 41: // escape
            return .control(.escape)
        case 42: // backspace
            return .control(.backspace)
        case 43: // tab
            return .control(.tab)
        default:
            return nil
        }
    }
}
