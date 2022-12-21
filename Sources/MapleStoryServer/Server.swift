//
//  Server.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import ArgumentParser
import MapleStory

@main
struct Server: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "MapleStoryServer",
        abstract: "MapleStory Server emulator",
        version: "1.0.0",
        subcommands: [
            Login.self
        ]
    )
}
