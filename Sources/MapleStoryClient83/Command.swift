//
//  Command.swift
//  MapleStoryClient83
//

import Foundation
import ArgumentParser
import MapleStory
import MapleStory83
import MapleStoryClient

@main
struct MapleStoryClient83: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "MapleStoryClient83",
        abstract: "MapleStory v83 OpenGL game client",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "Login server host to connect to.")
    var host: String = "127.0.0.1"

    @Option(name: .shortAndLong, help: "Login server port.")
    var port: UInt16 = 8484

    @Flag(name: .shortAndLong, help: "Log network traffic to stdout.")
    var verbose = false

    func run() throws {
        guard let destination = MapleStoryAddress(address: host, port: port) else {
            throw ValidationError("Invalid server address \(host):\(port)")
        }
        let configuration = ClientConfiguration(destination: destination)

        // SDL + OpenGL must run on the main thread; `run()` is invoked there.
        let game = try Game(title: "MapleStory v83", width: 1024, height: 768)
        let scene = LoginScene(configuration: configuration, verbose: verbose)
        game.setScene(scene)
        scene.start()
        try game.run()
    }
}
