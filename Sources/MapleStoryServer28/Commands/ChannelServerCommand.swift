//
//  ChannelServer.swift
//  
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import ArgumentParser
import NIO
import Socket
import CoreModel
import MongoDBModel
import MapleStory28
import MapleStoryServer

struct ChannelServerCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "channel",
        abstract: "Run the channel server."
    )
    
    @Option(help: "World Index")
    var world: Int = 1
    
    @Option(help: "Channel Index")
    var channel: Int = 1
    
    @Option(help: "Address to bind server.")
    var address: String?
    
    @Option(help: "Port to bind server.")
    var port: UInt16 = 7575
    
    @Option(help: "Server backlog.")
    var backlog: Int = 1000
    
    @Option(help: "Database URL.")
    var databaseURL: String = "mongodb://localhost:27017"
    
    @Option(help: "Database username.")
    var databaseUsername: String?
    
    @Option(help: "Database password.")
    var databasePassword: String?
    
    @Option(help: "Database name.")
    var databaseName: String = "maplestory"
    
    @Flag(help: "Whether AES encryption is enabled.")
    var aesEncryption: Bool = false
    
    func validate() throws {
        if let address {
            guard let _ = MapleStoryAddress(address: address, port: port) else {
                throw MapleStoryError.invalidAddress(address)
            }
        }
        guard world > 0 else {
            throw MapleStoryError.invalidWorld
        }
        guard channel > 0 else {
            throw MapleStoryError.invalidChannel
        }
    }
    
    func run() async throws {
        
        defer { cleanupMongoSwift() }
        
        // start server
        let ipAddress = self.address ?? IPv4Address.any.rawValue
        guard let address = MapleStoryAddress(address: ipAddress, port: port) else {
            throw MapleStoryError.invalidAddress(ipAddress)
        }
        
        let configuration = ServerConfiguration(
            address: address,
            backlog: backlog,
            version: .v28,
            key: aesEncryption ? .default : nil
        )
        
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        
        defer {
            try? elg.syncShutdownGracefully()
        }
        
        let mongoClient = try MongoClient(
            databaseURL,
            using: elg,
            options: MongoClientOptions(
                credential: MongoCredential(
                    username: databaseUsername,
                    password: databasePassword
                )
            )
        )
        
        defer {
            try? mongoClient.syncClose()
        }
        
        let store = MongoModelStorage(
            database: mongoClient.db(databaseName),
            model: .mapleStory
        )
        
        let server = try await MapleStoryServer<MapleStorySocketIPv4TCP, MongoModelStorage, ClientOpcode, ServerOpcode>(
            configuration: configuration,
            database: store,
            socket: MapleStorySocketIPv4TCP.self
        )
        
        let worldIndex = World.Index(self.world - 1)
        guard let world = try await World.fetch(
            index: worldIndex,
            version: configuration.version,
            region: configuration.region,
            in: store
        ) else {
            throw MapleStoryError.invalidWorld
        }
        
        let channelIndex = Channel.Index(self.channel - 1)
        guard let channel = try await MapleStory.Channel.fetch(
            channelIndex,
            world: world.id,
            in: store
        ) else {
            throw MapleStoryError.invalidChannel
        }
        
        await server.registerChannelServer(
            channel: channel.id
        )
        
        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))
        
        // retain
        let _ = server
    }
}

public extension MapleStoryServer where ClientOpcode == MapleStory28.ClientOpcode, ServerOpcode == MapleStory28.ServerOpcode {
    
    func registerChannelServer(
        channel: MapleStory.Channel.ID
    ) async {
        await register(HandshakeHandler(channel: channel))
        await register(PlayerLoginHandler(channel: channel))
        await register(PingHandler())
    }
}
