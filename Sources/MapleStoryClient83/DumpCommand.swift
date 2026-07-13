//
//  DumpCommand.swift
//  MapleStoryClient83
//
//  Developer tool: print a WZ archive's property tree, for discovering asset
//  paths (e.g. the login UI nodes in UI.wz).
//

import Foundation
import ArgumentParser
import MapleStoryFile

struct DumpCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "dump",
        abstract: "Print the property tree of a WZ image."
    )

    @Option(name: .long, help: "Path to the .wz file.")
    var wz: String

    @Option(name: .long, help: "Image path inside the archive (e.g. Login.img). Omit to list images.")
    var image: String?

    @Option(name: .long, help: "Property path inside the image (slash-separated).")
    var path: String?

    @Option(name: .long, help: "Maximum tree depth to print.")
    var depth: Int = 3

    @Option(name: .long, help: "WZ region: GMS, EMS or BMS.")
    var region: String = "GMS"

    func run() throws {
        let version: WzMapleVersion
        switch region.lowercased() {
        case "ems": version = .ems
        case "bms": version = .bms
        default: version = .gms
        }
        let archive = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: wz)), mapleVersion: version)
        guard let image else {
            print("Images in \(wz):")
            for entry in archive.root.images { print("  \(entry.name)") }
            for directory in archive.root.subdirectories { print("  \(directory.name)/") }
            return
        }
        guard let node = archive.root[image] else {
            throw ValidationError("Image \(image) not found")
        }
        var props = try archive.properties(of: node)
        if let path {
            guard let target = props.property(at: path) else {
                throw ValidationError("Path \(path) not found in \(image)")
            }
            props = target.children
            print("\(image)/\(path):")
        } else {
            print("\(image):")
        }
        printTree(props, indent: 1, remaining: depth)
    }

    private func printTree(_ props: [WzNamedProperty], indent: Int, remaining: Int) {
        guard remaining > 0 else { return }
        for entry in props {
            let pad = String(repeating: "  ", count: indent)
            print("\(pad)\(entry.name): \(describe(entry.value))")
            printTree(entry.value.children, indent: indent + 1, remaining: remaining - 1)
        }
    }

    private func describe(_ property: WzProperty) -> String {
        switch property {
        case .canvas(let canvas):
            return "canvas \(canvas.width)x\(canvas.height)"
        case .vector(let x, let y):
            return "vector (\(x), \(y))"
        case .uol(let target):
            return "uol -> \(target)"
        case .sound:
            return "sound"
        case .string(let value):
            return "\"\(value)\""
        case .int16(let value):
            return "\(value)"
        case .int32(let value):
            return "\(value)"
        case .int64(let value):
            return "\(value)"
        case .float(let value):
            return "\(value)"
        case .double(let value):
            return "\(value)"
        case .null:
            return "(null)"
        case .sub:
            return ""
        case .convex:
            return "(convex)"
        }
    }
}
