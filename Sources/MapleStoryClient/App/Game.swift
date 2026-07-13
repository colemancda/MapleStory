//
//  Game.swift
//  MapleStoryClient
//
//  Owns the SDL3 window + OpenGL context and runs the main loop, mirroring the
//  reference client's `Window` + `MapleStory.cpp` entry point.
//

import Foundation
import SDL3Swift
import CoreGraphics
import ImageIO
#if canImport(OpenGL)
@preconcurrency import OpenGL.GL3
#endif

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

    /// If set, capture the framebuffer to this PNG path after `captureAfterFrames`
    /// frames and then stop the loop (for headless verification).
    public var capturePath: String?
    public var captureAfterFrames: Int = 3
    private var frameCount = 0

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

            scene?.updateInput(held: Game.heldMovementKeys())
            scene?.update(deltaTime: deltaTime)

            let (pointWidth, pointHeight) = window.size
            let (pixelWidth, pixelHeight) = window.drawableSize
            GL.viewport(width: pixelWidth, height: pixelHeight)
            GL.clear(red: clearColor.red, green: clearColor.green, blue: clearColor.blue, alpha: clearColor.alpha)
            renderer.begin(width: pointWidth, height: pointHeight)
            if let scene {
                scene.render(RenderContext(renderer: renderer, text: text, width: pointWidth, height: pointHeight))
            }
            renderer.end()
            try window.glSwap()

            frameCount += 1
            if let capturePath, frameCount >= captureAfterFrames {
                captureFramebuffer(width: pixelWidth, height: pixelHeight, to: capturePath)
                isRunning = false
            }
        }
        SDL.quit()
    }

    /// Read the GL framebuffer and write it to a PNG (rows flipped to top-left origin).
    private func captureFramebuffer(width: Int, height: Int, to path: String) {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        glReadPixels(0, 0, GLsizei(width), GLsizei(height), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &pixels)

        let rowBytes = width * 4
        var flipped = [UInt8](repeating: 0, count: pixels.count)
        for y in 0 ..< height {
            let src = (height - 1 - y) * rowBytes
            let dst = y * rowBytes
            flipped.replaceSubrange(dst ..< dst + rowBytes, with: pixels[src ..< src + rowBytes])
        }
        // Force opaque so the screenshot isn't transparent where alpha wasn't written.
        for p in 0 ..< (width * height) { flipped[p * 4 + 3] = 255 }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: rowBytes, space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
        flipped.withUnsafeBytes { buffer in
            context.data?.copyMemory(from: buffer.baseAddress!, byteCount: buffer.count)
        }
        guard let image = context.makeImage() else { return }
        let url = URL(fileURLWithPath: path) as CFURL
        guard let destination = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
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

    /// The movement scancodes currently held down, for continuous motion.
    private static func heldMovementKeys() -> Set<ControlKey> {
        let state = SDL.keyboardState
        var held = Set<ControlKey>()
        let scancodes: [(Int, ControlKey)] = [(79, .right), (80, .left), (81, .down), (82, .up)]
        for (scancode, key) in scancodes where scancode < state.count && state[scancode] {
            held.insert(key)
        }
        return held
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
        case 79: // right
            return .control(.right)
        case 80: // left
            return .control(.left)
        case 81: // down
            return .control(.down)
        case 82: // up
            return .control(.up)
        case 224, 228: // left/right control
            return .control(.attack)
        default:
            return nil
        }
    }
}
