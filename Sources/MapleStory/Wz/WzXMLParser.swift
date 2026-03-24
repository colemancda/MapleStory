//
//  WzXMLParser.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// Parses a WZ `.img.xml` file into a `WzNode` tree.
public struct WzXMLParser {

    public init() { }

    /// Parse XML data from a `.img.xml` file.
    /// Returns the root `<imgdir>` node.
    public func parse(_ data: Data) throws -> WzNode {
        let delegate = ParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else {
            throw delegate.error ?? parser.parserError ?? WzParseError.unknown
        }
        guard let root = delegate.root else {
            throw WzParseError.emptyDocument
        }
        return root
    }

    /// Parse the XML file at the given URL.
    public func parse(contentsOf url: URL) throws -> WzNode {
        let data = try Data(contentsOf: url)
        return try parse(data)
    }
}

// MARK: - Errors

public enum WzParseError: Error {
    case unknown
    case emptyDocument
    case unexpectedElement(String)
    case missingAttribute(String, element: String)
    case invalidValue(String, attribute: String)
}

// MARK: - SAX Delegate

private final class ParserDelegate: NSObject, XMLParserDelegate {

    // Stack of (name, partial children) being built bottom-up.
    private struct Frame {
        var name: String
        var element: String
        var attributes: [String: String]
        var children: [WzNode]
    }

    private var stack: [Frame] = []
    var root: WzNode?
    var error: Error?

    func parser(
        _ parser: XMLParser,
        didStartElement element: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes: [String: String] = [:]
    ) {
        guard element != "imgdir" || stack.isEmpty else {
            // nested imgdir — push normally
            let name = attributes["name"] ?? ""
            stack.append(Frame(name: name, element: element, attributes: attributes, children: []))
            return
        }
        if element == "imgdir" {
            // root imgdir
            let name = attributes["name"] ?? ""
            stack.append(Frame(name: name, element: element, attributes: attributes, children: []))
        } else {
            let name = attributes["name"] ?? ""
            stack.append(Frame(name: name, element: element, attributes: attributes, children: []))
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement element: String,
        namespaceURI: String?,
        qualifiedName: String?
    ) {
        guard var frame = stack.popLast() else { return }

        do {
            let node = try makeNode(from: &frame)
            if stack.isEmpty {
                root = node
            } else {
                stack[stack.count - 1].children.append(node)
            }
        } catch {
            self.error = error
            parser.abortParsing()
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        error = parseError
    }

    // MARK: Private

    private func makeNode(from frame: inout Frame) throws -> WzNode {
        let name = frame.name
        let attrs = frame.attributes
        let children = frame.children

        func require(_ key: String) throws -> String {
            guard let v = attrs[key] else {
                throw WzParseError.missingAttribute(key, element: frame.element)
            }
            return v
        }

        switch frame.element {
        case "imgdir":
            return WzNode(name: name, value: .directory(children))

        case "int":
            let raw = try require("value")
            guard let v = Int32(raw) else {
                throw WzParseError.invalidValue(raw, attribute: "value")
            }
            return WzNode(name: name, value: .int(v))

        case "short":
            let raw = try require("value")
            guard let v = Int16(raw) else {
                throw WzParseError.invalidValue(raw, attribute: "value")
            }
            return WzNode(name: name, value: .short(v))

        case "float":
            let raw = try require("value")
            guard let v = Float(raw) else {
                throw WzParseError.invalidValue(raw, attribute: "value")
            }
            return WzNode(name: name, value: .float(v))

        case "double":
            let raw = try require("value")
            guard let v = Double(raw) else {
                throw WzParseError.invalidValue(raw, attribute: "value")
            }
            return WzNode(name: name, value: .double(v))

        case "string":
            return WzNode(name: name, value: .string(try require("value")))

        case "uol":
            return WzNode(name: name, value: .uol(try require("value")))

        case "vector":
            let rawX = try require("x")
            let rawY = try require("y")
            guard let x = Int32(rawX) else {
                throw WzParseError.invalidValue(rawX, attribute: "x")
            }
            guard let y = Int32(rawY) else {
                throw WzParseError.invalidValue(rawY, attribute: "y")
            }
            return WzNode(name: name, value: .vector(x: x, y: y))

        case "canvas":
            let rawW = try require("width")
            let rawH = try require("height")
            guard let w = Int32(rawW) else {
                throw WzParseError.invalidValue(rawW, attribute: "width")
            }
            guard let h = Int32(rawH) else {
                throw WzParseError.invalidValue(rawH, attribute: "height")
            }
            return WzNode(name: name, value: .canvas(width: w, height: h, children: children))

        case "null":
            return WzNode(name: name, value: .null)

        case "sound":
            return WzNode(name: name, value: .sound)

        default:
            throw WzParseError.unexpectedElement(frame.element)
        }
    }
}
