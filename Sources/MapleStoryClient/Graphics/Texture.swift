//
//  Texture.swift
//  MapleStoryClient
//

#if canImport(OpenGL)
@preconcurrency import OpenGL.GL3
#endif

import Foundation

/// A 2D RGBA OpenGL texture.
public final class Texture {

    let id: GLuint
    public let width: Int
    public let height: Int

    /// Create a texture from tightly-packed RGBA8 pixel data (`width * height * 4` bytes).
    public init(width: Int, height: Int, rgba: [UInt8]) throws {
        precondition(rgba.count == width * height * 4)
        var id: GLuint = 0
        glGenTextures(1, &id)
        guard id != 0 else { throw ClientGraphicsError.textureCreationFailed }
        glBindTexture(GLenum(GL_TEXTURE_2D), id)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        rgba.withUnsafeBytes { buffer in
            glTexImage2D(
                GLenum(GL_TEXTURE_2D),
                0,
                GL_RGBA,
                GLsizei(width),
                GLsizei(height),
                0,
                GLenum(GL_RGBA),
                GLenum(GL_UNSIGNED_BYTE),
                buffer.baseAddress
            )
        }
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        self.id = id
        self.width = width
        self.height = height
    }

    deinit {
        var id = self.id
        glDeleteTextures(1, &id)
    }

    public func bind(unit: Int = 0) {
        glActiveTexture(GLenum(GL_TEXTURE0 + Int32(unit)))
        glBindTexture(GLenum(GL_TEXTURE_2D), id)
    }
}
