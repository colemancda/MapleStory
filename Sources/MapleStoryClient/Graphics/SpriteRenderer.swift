//
//  SpriteRenderer.swift
//  MapleStoryClient
//
//  A batching shader-based 2D renderer: solid and textured quads in screen space
//  (top-left origin, pixel coordinates). Quads accumulate into one large
//  per-frame vertex buffer and flush only when the bound texture changes, so a
//  frame costs a handful of buffer writes instead of a sync stall per quad.
//

#if canImport(OpenGL)
@preconcurrency import OpenGL.GL3
#endif

import Foundation

/// An axis-aligned rectangle in pixel coordinates.
public struct Rectangle: Sendable {
    public var x: Float
    public var y: Float
    public var width: Float
    public var height: Float
    public init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x; self.y = y; self.width = width; self.height = height
    }
}

/// RGBA color, components in `0...1`.
public struct RGBAColor: Sendable {
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float
    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
    }

    public static let white = RGBAColor(red: 1, green: 1, blue: 1, alpha: 1)
    public static let black = RGBAColor(red: 0, green: 0, blue: 0, alpha: 1)

    public static func gray(_ v: Float, alpha: Float = 1) -> RGBAColor {
        RGBAColor(red: v, green: v, blue: v, alpha: alpha)
    }
}

public final class SpriteRenderer {

    private let shader: Shader
    private var vao: GLuint = 0
    private var vbo: GLuint = 0
    /// Solid fills sample this 1×1 white texture so every quad takes the same path.
    private let white: Texture
    private let uProjection: GLint
    private let uTexture: GLint

    // The whole frame is recorded CPU-side and submitted in one buffer upload
    // in `end()`: Apple's GL-on-Metal driver flushes the entire context (and
    // blocks on a semaphore) whenever a buffer is written while it has pending
    // draws, so mid-frame `glBufferSubData` costs milliseconds each.
    private struct DrawCommand {
        var texture: Texture   // strong ref keeps the GL texture alive until submit
        var firstVertex: Int
        var vertexCount: Int
    }
    private var vertices: [Float] = []
    private var commands: [DrawCommand] = []
    private static let floatsPerVertex = 8   // pos(2) + uv(2) + color(4)

    private static let vertexSource = """
    #version 330 core
    layout (location = 0) in vec2 aPos;
    layout (location = 1) in vec2 aUV;
    layout (location = 2) in vec4 aColor;
    out vec2 vUV;
    out vec4 vColor;
    uniform mat4 uProjection;
    void main() {
        vUV = aUV;
        vColor = aColor;
        gl_Position = uProjection * vec4(aPos, 0.0, 1.0);
    }
    """

    private static let fragmentSource = """
    #version 330 core
    in vec2 vUV;
    in vec4 vColor;
    out vec4 fragColor;
    uniform sampler2D uTexture;
    void main() {
        fragColor = texture(uTexture, vUV) * vColor;
    }
    """

    init() throws {
        self.shader = try Shader(vertex: SpriteRenderer.vertexSource, fragment: SpriteRenderer.fragmentSource)
        self.white = try Texture(width: 1, height: 1, rgba: [255, 255, 255, 255])
        self.uProjection = shader.uniformLocation("uProjection")
        self.uTexture = shader.uniformLocation("uTexture")
        glGenVertexArrays(1, &vao)
        glGenBuffers(1, &vbo)
        glBindVertexArray(vao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        let stride = GLsizei(SpriteRenderer.floatsPerVertex * MemoryLayout<Float>.size)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, nil)
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, UnsafeRawPointer(bitPattern: 2 * MemoryLayout<Float>.size))
        glEnableVertexAttribArray(2)
        glVertexAttribPointer(2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, UnsafeRawPointer(bitPattern: 4 * MemoryLayout<Float>.size))
        glBindVertexArray(0)
        vertices.reserveCapacity(4096 * SpriteRenderer.floatsPerVertex)
    }

    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }

    /// Begin a frame: bind the shader, set the orthographic projection for a
    /// `width`×`height` screen (origin top-left), and start recording.
    public func begin(width: Int, height: Int) {
        shader.use()
        var matrix = SpriteRenderer.orthographic(width: Float(width), height: Float(height))
        glUniformMatrix4fv(uProjection, 1, GLboolean(GL_FALSE), &matrix)
        glUniform1i(uTexture, 0)
        vertices.removeAll(keepingCapacity: true)
        commands.removeAll(keepingCapacity: true)
    }

    /// End the frame: upload every recorded vertex in one buffer write, then
    /// replay the draw commands. Must be called before the buffer swap.
    public func end() {
        guard commands.isEmpty == false else { return }
        glBindVertexArray(vao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        vertices.withUnsafeBytes { buffer in
            glBufferData(GLenum(GL_ARRAY_BUFFER), buffer.count, buffer.baseAddress, GLenum(GL_STREAM_DRAW))
        }
        for command in commands {
            command.texture.bind(unit: 0)
            glDrawArrays(GLenum(GL_TRIANGLES), GLint(command.firstVertex), GLsizei(command.vertexCount))
        }
        glBindVertexArray(0)
        commands.removeAll(keepingCapacity: true)
        vertices.removeAll(keepingCapacity: true)
    }

    /// Draw a solid-color rectangle.
    public func fill(_ rect: Rectangle, color: RGBAColor) {
        append(texture: white, rect: rect, u0: 0, v0: 0, u1: 1, v1: 1, color: color)
    }

    /// Draw a textured rectangle, sampling the sub-region `uv` (0...1) of `texture`.
    public func draw(_ texture: Texture, in rect: Rectangle, uv: Rectangle = Rectangle(x: 0, y: 0, width: 1, height: 1), tint: RGBAColor = .white) {
        append(texture: texture, rect: rect, u0: uv.x, v0: uv.y, u1: uv.x + uv.width, v1: uv.y + uv.height, color: tint)
    }

    // MARK: - Batching

    private func append(texture: Texture, rect: Rectangle, u0: Float, v0: Float, u1: Float, v1: Float, color: RGBAColor) {
        let firstVertex = vertices.count / SpriteRenderer.floatsPerVertex
        let x0 = rect.x, y0 = rect.y
        let x1 = rect.x + rect.width, y1 = rect.y + rect.height
        let r = color.red, g = color.green, b = color.blue, a = color.alpha
        vertices.append(contentsOf: [
            x0, y0, u0, v0, r, g, b, a,
            x1, y0, u1, v0, r, g, b, a,
            x1, y1, u1, v1, r, g, b, a,
            x0, y0, u0, v0, r, g, b, a,
            x1, y1, u1, v1, r, g, b, a,
            x0, y1, u0, v1, r, g, b, a,
        ])
        // Extend the current command when the texture is unchanged (draw order
        // is preserved because vertices are contiguous).
        if commands.isEmpty == false, commands[commands.count - 1].texture.id == texture.id {
            commands[commands.count - 1].vertexCount += 6
        } else {
            commands.append(DrawCommand(texture: texture, firstVertex: firstVertex, vertexCount: 6))
        }
    }

    /// Column-major orthographic projection: (0,0) top-left → (width,height) bottom-right.
    static func orthographic(width: Float, height: Float) -> [Float] {
        return [
            2 / width, 0, 0, 0,
            0, -2 / height, 0, 0,
            0, 0, -1, 0,
            -1, 1, 0, 1,
        ]
    }
}
