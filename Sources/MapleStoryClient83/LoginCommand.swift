//
//  LoginCommand.swift
//  MapleStoryClient83
//

import Foundation
import ArgumentParser
import MapleStory
import MapleStoryClient

struct LoginCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Connect to a login server and show the login screen."
    )

    @Option(name: .shortAndLong, help: "Login server host to connect to.")
    var host: String = "127.0.0.1"

    @Option(name: .shortAndLong, help: "Login server port.")
    var port: UInt16 = 8484

    @Flag(name: .shortAndLong, help: "Log network traffic to stdout.")
    var verbose = false

    @Option(name: .long, help: "Capture a screenshot to this PNG path and exit.")
    var screenshot: String?

    func run() throws {
        guard let destination = MapleStoryAddress(address: host, port: port) else {
            throw ValidationError("Invalid server address \(host):\(port)")
        }
        let configuration = ClientConfiguration(destination: destination)
        let game = try Game(title: "MapleStory v83", width: 1024, height: 768)
        let scene = LoginScene(configuration: configuration, verbose: verbose)
        game.setScene(scene)
        scene.start()
        if let screenshot {
            game.capturePath = screenshot
            game.captureAfterFrames = 10
        }
        try game.run()
        if let screenshot {
            print("Saved screenshot to \(screenshot)")
        }
    }
}
