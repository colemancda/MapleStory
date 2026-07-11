//
//  GL.swift
//  MapleStoryClient
//
//  Thin conveniences over the platform OpenGL API. macOS provides OpenGL 4.1
//  core via the system framework (deprecated but functional); this is the same
//  fixed-function-free pipeline the reference client targets.
//

#if canImport(OpenGL)
@preconcurrency import OpenGL.GL3
#endif

import Foundation

enum GL {

    /// Set the clear color and clear the color buffer.
    static func clear(red: Float, green: Float, blue: Float, alpha: Float = 1) {
        glClearColor(red, green, blue, alpha)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }

    /// Set the viewport in pixels.
    static func viewport(width: Int, height: Int) {
        glViewport(0, 0, GLsizei(width), GLsizei(height))
    }

    /// Enable standard alpha blending for 2D sprites.
    static func enableAlphaBlending() {
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
    }
}
