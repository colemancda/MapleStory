//
//  Shader.swift
//  MapleStoryClient
//

#if canImport(OpenGL)
@preconcurrency import OpenGL.GL3
#endif

import Foundation

/// A compiled + linked GLSL program.
final class Shader {

    let program: GLuint

    init(vertex: String, fragment: String) throws {
        let vs = try Shader.compile(source: vertex, type: GLenum(GL_VERTEX_SHADER))
        let fs = try Shader.compile(source: fragment, type: GLenum(GL_FRAGMENT_SHADER))
        let program = glCreateProgram()
        glAttachShader(program, vs)
        glAttachShader(program, fs)
        glLinkProgram(program)
        glDeleteShader(vs)
        glDeleteShader(fs)

        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        guard status == GL_TRUE else {
            var length: GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &length)
            var log = [GLchar](repeating: 0, count: Int(max(length, 1)))
            glGetProgramInfoLog(program, GLsizei(log.count), nil, &log)
            glDeleteProgram(program)
            throw ClientGraphicsError.shaderLinkFailed(String(cString: log))
        }
        self.program = program
    }

    deinit {
        glDeleteProgram(program)
    }

    func use() {
        glUseProgram(program)
    }

    func uniformLocation(_ name: String) -> GLint {
        name.withCString { glGetUniformLocation(program, $0) }
    }

    func set(_ name: String, _ value: Int32) {
        glUniform1i(uniformLocation(name), value)
    }

    func set(_ name: String, _ v: (Float, Float, Float, Float)) {
        glUniform4f(uniformLocation(name), v.0, v.1, v.2, v.3)
    }

    /// Set a column-major 4x4 matrix uniform.
    func set(_ name: String, matrix: [Float]) {
        precondition(matrix.count == 16)
        var m = matrix
        glUniformMatrix4fv(uniformLocation(name), 1, GLboolean(GL_FALSE), &m)
    }

    // MARK: - Compilation

    private static func compile(source: String, type: GLenum) throws -> GLuint {
        let shader = glCreateShader(type)
        try source.withCString { cstr in
            var pointer: UnsafePointer<GLchar>? = cstr
            glShaderSource(shader, 1, &pointer, nil)
        }
        glCompileShader(shader)

        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        guard status == GL_TRUE else {
            var length: GLint = 0
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &length)
            var log = [GLchar](repeating: 0, count: Int(max(length, 1)))
            glGetShaderInfoLog(shader, GLsizei(log.count), nil, &log)
            glDeleteShader(shader)
            throw ClientGraphicsError.shaderCompileFailed(String(cString: log))
        }
        return shader
    }
}

enum ClientGraphicsError: Error {
    case shaderCompileFailed(String)
    case shaderLinkFailed(String)
    case textureCreationFailed
    case fontRasterizationFailed
    case imageDecodeFailed
}
