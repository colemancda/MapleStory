import Foundation
import SystemPackage

/// MapleStory Classic Server
public final class MapleStoryServer <Socket: MapleStorySocket, DataSource: MapleStoryServerDataSource> {
    
    // MARK: - Properties
    
    public let configuration: MapleStory.ServerConfiguration
        
    public let dataSource: DataSource
    
    internal let log: ((String) -> ())?
    
    internal let socket: Socket
    
    private var tcpListenTask: Task<(), Never>?
    
    let storage = Storage()
    
    // MARK: - Initialization
    
    deinit {
        stop()
    }
    
    public init(
        configuration: MapleStory.ServerConfiguration,
        log: ((String) -> ())? = nil,
        dataSource: DataSource,
        socket: Socket.Type
    ) async throws {
        #if DEBUG
        let log = log ?? {
            NSLog("MapleStoryServer: \($0)")
        }
        #endif
        self.configuration = configuration
        self.log = log
        self.dataSource = dataSource
        // create listening socket
        self.socket = try await Socket.server(
            address: configuration.address,
            backlog: configuration.backlog
        )
        // start running server
        start()
    }
    
    // MARK: - Methods
    
    private func start() {
        assert(tcpListenTask == nil)
        log?("Started MapleStory Server")
        // listening run loop
        self.tcpListenTask = Task.detached(priority: .high) { [weak self] in
            while let socket = self?.socket {
                do {
                    // wait for incoming sockets
                    let newSocket = try await socket.accept()
                    if let self = self {
                        self.log?("[\(newSocket.address.address)] New connection")
                        let connection = await MapleStoryServer.Connection(socket: newSocket, server: self)
                        await self.storage.newConnection(connection)
                        await self.dataSource.didConnect(newSocket.address)
                    }
                }
                catch _ as CancellationError { }
                catch Errno.resourceTemporarilyUnavailable {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                catch {
                    self?.log?("Error waiting for new TCP connection: \(error)")
                }
            }
        }
    }
    
    public func stop() {
        assert(tcpListenTask != nil)
        let storage = self.storage
        self.tcpListenTask?.cancel()
        self.tcpListenTask = nil
        self.log?("Stopped Server")
        Task {
            await storage.removeAllConnections()
        }
    }
    
    public func send<T>(
        _ packet: T,
        to address: MapleStoryAddress
    ) async throws where T: MapleStoryPacket, T: Encodable {
        guard let connection = await self.storage.connections[address] else {
            throw MapleStoryError.disconnected(address)
        }
        try await connection.send(packet)
    }
}

// MARK: - Supporting Types

/// MapleStory Server Data Source
public protocol MapleStoryServerDataSource: AnyObject {
        
    func didConnect(_ address: MapleStoryAddress) async
    
    func didDisconnect(_ address: MapleStoryAddress, username: String?) async
}

internal extension MapleStoryServer {
    
    actor Storage {
        
        var connections = [MapleStoryAddress: Connection](minimumCapacity: 100)
        
        fileprivate init() { }
        
        func newConnection(_ connection: Connection) {
            connections[connection.address] = connection
        }
        
        func removeConnection(_ address: MapleStoryAddress) {
            self.connections[address] = nil
        }
        
        func removeAllConnections() {
            self.connections.removeAll()
        }
    }
}

internal extension MapleStoryServer.Connection {
    
    struct ClientState: Equatable, Hashable {
        
        var channel: UInt8 = 0x00
        
        var world: UInt8 = 0x00
    }
}

internal extension MapleStoryServer {
    
    actor Connection {
        
        // MARK: - Properties
        
        let address: MapleStoryAddress
        
        private let connection: MapleStory.Connection<Socket>
        
        private unowned var server: MapleStoryServer
        
        private let log: (String) -> ()
        
        var state = ClientState()
        
        // MARK: - Initialization
        
        init(
            socket: Socket,
            server: MapleStoryServer
        ) async {
            let address = socket.address
            let serverLog = server.log
            let log: (String) -> () = { serverLog?("[\(address.address)] \($0)") }
            self.log = log
            self.address = address
            self.server = server
            self.connection = await MapleStory.Connection(
                socket: socket, 
                log: log,
                version: server.configuration.version,
                region: server.configuration.region,
                key: server.configuration.key
            ) { error in
                let username = await server.storage.connections[address]?.connection.username
                await server.storage.removeConnection(address)
                await server.dataSource.didDisconnect(address, username: username)
            }
            await self.registerHandlers()
            Task {
                try await self.sendHandshake()
            }
        }
        
        private func registerHandlers() async {
            
            // login
            //await register { [unowned self] in try await self.login($0) }
            //await register { [unowned self] in try await self.guestLogin($0) }
            //await register { [unowned self] in try await self.pinOperation($0) }
            //await connection.register { [unowned self] in await self.serverList($0) }
            //await register { [unowned self] in try await self.serverStatus($0) }
            //await register { [unowned self] in try await self.characterList($0) }
            //await connection.register { [unowned self] in await self.allCharacters($0) }
            //await register { [unowned self] in try await self.selectCharacter($0) }
            //await register { [unowned self] in try await self.selectAllCharacter($0) }
            //await register { [unowned self] in try await self.createCharacter($0) }
            //await register { [unowned self] in try await self.deleteCharacter($0) }
            //await register { [unowned self] in try await self.checkCharacterName($0) }
        }
        
        /// Respond to a client-initiated PDU message.
        internal func send <Request, Response> (
            _ request: Request,
            response: Response.Type
        ) async throws -> Response where Request: MapleStoryPacket, Request: Encodable, Response: MapleStoryPacket, Response: Decodable {
            log("Request: \(request)")
            let responsePacket = try await withCheckedThrowingContinuation { continuation in
                Task {
                    guard let _ = await self.connection.queue(request, didWrite: nil, response: (continuation, response)) else {
                        fatalError("Could not add PDU to queue: \(request)")
                    }
                }
            }
            return responsePacket as! Response
        }
        
        /// Respond to a client-initiated PDU message.
        internal func respond <T> (_ response: T) async throws where T: MapleStoryPacket, T: Encodable {
            log("Response: \(response)")
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    guard let _ = await self.connection.queue(response, didWrite: continuation)
                        else { fatalError("Could not add PDU to queue: \(response)") }
                }
            }
        }
        
        /// Send a server-initiated PDU message.
        internal func send <T> (_ notification: T) async throws where T: MapleStoryPacket, T: Encodable  {
            log("Notification: \(notification)")
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    guard let _ = await self.connection.queue(notification, didWrite: continuation)
                        else { fatalError("Could not add PDU to queue: \(notification)") }
                }
            }
        }
        
        internal func close(_ error: Error) async {
            log("Error: \(error)")
            await self.connection.socket.close()
        }
        
        @discardableResult
        private func register <Request, Response> (
            _ callback: @escaping (Request) async throws -> (Response)
        ) async -> UInt where Request: MapleStoryPacket, Request: Decodable, Response: MapleStoryPacket, Response: Encodable {
            await self.connection.register { [unowned self] request in
                do {
                    let response = try await callback(request)
                    try await self.respond(response)
                }
                catch {
                    await self.close(error)
                }
            }
        }
        
        internal func sendHandshake() async throws {
            let packet = HelloPacket(
                version: self.connection.version,
                recieveNonce: await self.connection.recieveNonce,
                sendNonce: await self.connection.sendNonce,
                region: self.connection.region
            )
            try await send(packet)
            await connection.startEncryption()
        }
    }
}
