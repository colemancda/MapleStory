//
//  WzNode.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// A node in a parsed WZ `.img.xml` file.
public struct WzNode: Equatable, Sendable {

    public let name: String
    public let value: WzValue
}

// MARK: - WzValue

public enum WzValue: Equatable, Sendable {

    /// `<imgdir>` — named container with child nodes.
    case directory([WzNode])

    /// `<int>` — 32-bit signed integer.
    case int(Int32)

    /// `<short>` — 16-bit signed integer.
    case short(Int16)

    /// `<float>` — single-precision float.
    case float(Float)

    /// `<double>` — double-precision float.
    case double(Double)

    /// `<string>` — UTF-8 string.
    case string(String)

    /// `<canvas>` — image frame with optional child nodes (vectors, ints).
    case canvas(width: Int32, height: Int32, children: [WzNode])

    /// `<vector>` — 2D integer point.
    case vector(x: Int32, y: Int32)

    /// `<null>` — empty/placeholder node.
    case null

    /// `<sound>` — audio asset reference.
    case sound

    /// `<uol>` — user object link (path reference to another node).
    case uol(String)
}

// MARK: - Children

public extension WzNode {

    /// Child nodes, if this node is a directory or canvas.
    var children: [WzNode] {
        switch value {
        case .directory(let nodes), .canvas(_, _, let nodes):
            return nodes
        default:
            return []
        }
    }

    /// Returns the first child with the given name.
    subscript(name: String) -> WzNode? {
        children.first(where: { $0.name == name })
    }

    /// Navigates a "/" separated path, e.g. `"info/maxHP"`.
    func child(at path: String) -> WzNode? {
        var components = path.split(separator: "/", omittingEmptySubsequences: true)
        guard !components.isEmpty else { return self }
        var current: WzNode = self
        while !components.isEmpty {
            let name = String(components.removeFirst())
            guard let next = current[name] else { return nil }
            current = next
        }
        return current
    }
}

// MARK: - Typed Value Accessors

public extension WzNode {

    var intValue: Int32? {
        switch value {
        case .int(let v): return v
        case .short(let v): return Int32(v)
        default: return nil
        }
    }

    var floatValue: Float? {
        switch value {
        case .float(let v): return v
        case .double(let v): return Float(v)
        default: return nil
        }
    }

    var doubleValue: Double? {
        if case .double(let v) = value { return v }
        if case .float(let v) = value { return Double(v) }
        return nil
    }

    var stringValue: String? {
        if case .string(let v) = value { return v }
        if case .uol(let v) = value { return v }
        return nil
    }

    /// x component if this node is a `<vector>`.
    var vectorX: Int32? {
        if case .vector(let x, _) = value { return x }
        return nil
    }

    /// y component if this node is a `<vector>`.
    var vectorY: Int32? {
        if case .vector(_, let y) = value { return y }
        return nil
    }
}
