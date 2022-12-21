//
//  Login.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import ArgumentParser
import MapleStory
import Socket

struct Login: AsyncParsableCommand {
    
    @Option(help: "Path to file.")
    var path: String?
    
    @Option(help: "Address to bind server.")
    var address: String?
    
    @Option(help: "Port to bind server.")
    var port: UInt16 = 8484
    
    @Option(help: "Server backlog.")
    var backlog: Int = 1000
    
    func run() async throws {
        
        // Load static server list file
        //let data = try Data(contentsOf: URL(fileURLWithPath: path), options: [.mappedIfSafe])
        //let decoder = JSONDecoder()
        //let directory = try decoder.decode(ServerDirectory.self, from: data)
        
        // start server
        let ipAddress = self.address ?? IPv4Address.any.rawValue
        guard let address = MapleStoryAddress(address: ipAddress, port: port) else {
            throw MapleStoryError.invalidAddress(ipAddress)
        }
        let configuration = MapleStoryServerConfiguration(
            address: address,
            backlog: backlog
        )
        let dataSource = InMemoryMapleStoryServerDataSource()
        await dataSource.update { _ in
            //$0.serverDirectory = directory
        }
        let server = try await MapleStoryServer(
            configuration: configuration,
            dataSource: dataSource,
            socket: MapleStorySocketIPv4TCP.self
        )
        
        // run indefinitely
        try await Task.sleep(until: .now.advanced(by: Duration(secondsComponent: Int64(Date.distantFuture.timeIntervalSinceNow), attosecondsComponent: .zero)), clock: .suspending)
        
        withExtendedLifetime(server, { })
    }
}
