//
//  LoginServer.swift
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

struct LoginServerCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Run the login server."
    )
    
    @Option(help: "Address to bind server.")
    var address: String?
    
    @Option(help: "Port to bind server.")
    var port: UInt16 = 8484
    
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
        
        try await store.initializeMapleStory(
            version: configuration.version,
            region: configuration.region,
            address: ipAddress
        )
        
        let server = try await MapleStoryServer<MapleStorySocketIPv4TCP, MongoModelStorage, ClientOpcode, ServerOpcode>(
            configuration: configuration,
            database: store,
            socket: MapleStorySocketIPv4TCP.self
        )
        
        await server.registerLoginServer()
        
        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))
        
        // retain
        let _ = server
    }
}

public extension MapleStoryServer where ClientOpcode == MapleStory28.ClientOpcode, ServerOpcode == MapleStory28.ServerOpcode {
    
    func registerLoginServer() async {
        await registerServerHandler(.init(didConnect: { connection in
            HandshakeHandler.didConnect(connection: connection)
        }))
        // await register(PingHandler())
        await register(LoginHandler())
        await register(AcceptLicenseHandler())
        await register(SetGenderHandler())
        await register(PinCodeHandler())
        //await register(CharacterListHandler())
        await register(CheckCharacterNameHandler())
        await register(CreateCharacterHandler())
        await register(DeleteCharacterHandler())
    }
}
