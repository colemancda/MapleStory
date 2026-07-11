//
//  SpriteRenderer.swift
//  MapleStoryClient
//
//  A minimal shader-based 2D renderer: solid and textured quads in screen space
//  (top-left origin, pixel coordinates). The rendering core the reference client's
//  `Graphics` module builds sprites on.
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

    private static let vertexSource = """
    #version 330 core
    layout (location = 0) in vec2 aPos;
    layout (location = 1) in vec2 aUV;
    out vec2 vUV;
    uniform mat4 uProjection;
    void main() {
        vUV = aUV;
        gl_Position = uProjection * vec4(aPos, 0.0, 1.0);
    }
    """

    private static let fragmentSource = """
    #version 330 core
    in vec2 vUV;
    out vec4 fragColor;
    uniform sampler2D uTexture;
    uniform int uUseTexture;
    uniform vec4 uColor;
    void main() {
        if (uUseTexture == 1) {
            fragColor = texture(uTexture, vUV) * uColor;
        } else {
            fragColor = uColor;
        }
    }
    """

    init() throws {
        self.shader = try Shader(vertex: SpriteRenderer.vertexSource, fragment: SpriteRenderer.fragmentSource)
        glGenVertexArrays(1, &vao)
        glGenBuffers(1, &vbo)
        glBindVertexArray(vao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // 6 vertices * 4 floats, dynamically updated per draw
        glBufferData(GLenum(GL_ARRAY_BUFFER), 6 * 4 * MemoryLayout<Float>.size, nil, GLenum(GL_DYNAMIC_DRAW))
        let stride = GLsizei(4 * MemoryLayout<Float>.size)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, nil)
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, UnsafeRawPointer(bitPattern: 2 * MemoryLayout<Float>.size))
        glBindVertexArray(0)
    }

    deinit {
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }

    /// Begin a frame: bind the shader and set the orthographic projection for a
    /// `width`×`height` screen with the origin at the top-left.
    public func begin(width: Int, height: Int) {
        shader.use()
        shader.set("uProjection", matrix: SpriteRenderer.orthographic(width: Float(width), height: Float(height)))
    }

    /// Draw a solid-color rectangle.
    public func fill(_ rect: Rectangle, color: RGBAColor) {
        shader.set("uUseTexture", 0)
        shader.set("uColor", (color.red, color.green, color.blue, color.alpha))
        draw(rect, u0: 0, v0: 0, u1: 1, v1: 1)
    }

    /// Draw a textured rectangle, sampling the sub-region `uv` (0...1) of `texture`.
    public func draw(_ texture: Texture, in rect: Rectangle, uv: Rectangle = Rectangle(x: 0, y: 0, width: 1, height: 1), tint: RGBAColor = .white) {
        shader.set("uUseTexture", 1)
        shader.set("uColor", (tint.red, tint.green, tint.blue, tint.alpha))
        texture.bind(unit: 0)
        shader.set("uTexture", 0)
        draw(rect, u0: uv.x, v0: uv.y, u1: uv.x + uv.width, v1: uv.y + uv.height)
    }

    // MARK: - Internal

    private func draw(_ rect: Rectangle, u0: Float, v0: Float, u1: Float, v1: Float) {
        let x0 = rect.x, y0 = rect.y
        let x1 = rect.x + rect.width, y1 = rect.y + rect.height
        let vertices: [Float] = [
            x0, y0, u0, v0,
            x1, y0, u1, v0,
            x1, y1, u1, v1,
            x0, y0, u0, v0,
            x1, y1, u1, v1,
            x0, y1, u0, v1,
        ]
        glBindVertexArray(vao)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        vertices.withUnsafeBytes { buffer in
            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, buffer.count, buffer.baseAddress)
        }
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        glBindVertexArray(0)
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
