//
//  Command.swift
//  MapleStoryClient83
//

import Foundation
import ArgumentParser

@main
struct MapleStoryClient83: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "MapleStoryClient83",
        abstract: "MapleStory v83 OpenGL game client",
        version: "1.0.0",
        subcommands: [LoginCommand.self, MapCommand.self, DumpCommand.self],
        defaultSubcommand: LoginCommand.self
    )
}
