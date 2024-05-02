//
//  Server.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation
import ArgumentParser
import MapleStoryServer
import Socket
import MongoSwift

@main
struct Server: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "MapleStoryServer",
        abstract: "MapleStory v28 Server emulator",
        version: "1.0.0",
        subcommands: [
            LoginServerCommand.self,
            ChannelServerCommand.self
        ]
    )
}

