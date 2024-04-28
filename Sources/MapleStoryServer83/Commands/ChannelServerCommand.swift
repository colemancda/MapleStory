//
//  ChannelServer.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import ArgumentParser
import MapleStoryServer
import Socket
import CoreModel
import MongoDBModel

struct ChannelServerCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "channel",
        abstract: "Run the channel server."
    )
    
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
            version: .v83
        )
        
        guard let databaseURL = URL(string: databaseURL) else {
            throw MapleStoryError.invalidAddress(databaseURL)
        }
        
        /*
        let database = try await MapleStoryDatabase(
            url: databaseURL,
            name: databaseName,
            username: databaseUsername,
            password: databasePassword
        )
        
        let server = try await MapleStoryServer(
            configuration: configuration, 
            dataSource: database,
            socket: MapleStorySocketIPv4TCP.self
        )
        
        // create DB tables
        #if DEBUG
        NSLog("Users: \(try await database.userCount)")
        #endif
        */
        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))
        
        // retain
        //let _ = server
    }
}
