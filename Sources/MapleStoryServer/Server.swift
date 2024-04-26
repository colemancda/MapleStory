import Foundation
import SystemPackage
import CoreModel
@_exported import MapleStory

/// MapleStory Classic Server
public final class MapleStoryServer <Socket: MapleStorySocket, Storage: CoreModel.ModelStorage> {
    
    // MARK: - Properties
    
    public let configuration: ServerConfiguration
        
    public let dataSource: DataSource
    
    internal let log: ((String) -> ())?
    
    internal let socket: Socket
    
    private var tcpListenTask: Task<(), Never>?
    
    let connections = Connections()
    
    // MARK: - Initialization
    
    deinit {
        stop()
    }
    
    public init(
        configuration: ServerConfiguration,
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
        log?("Started MapleStory v\(configuration.version.rawValue) Server")
        // listening run loop
        self.tcpListenTask = Task.detached(priority: .high) { [weak self] in
            while let socket = self?.socket {
                do {
                    // wait for incoming sockets
                    let newSocket = try await socket.accept()
                    if let self = self {
                        self.log?("[\(newSocket.address.address)] New connection")
                        let connection = await MapleStoryServer.Connection(socket: newSocket, server: self)
                        await self.connections.newConnection(connection)
                        //await self.dataSource.didConnect(newSocket.address)
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
        let connections = self.connections
        self.tcpListenTask?.cancel()
        self.tcpListenTask = nil
        self.log?("Stopped Server")
        Task {
            await connections.removeAllConnections()
        }
    }
    
    public func send<T>(
        _ packet: T,
        to address: MapleStoryAddress
    ) async throws where T: MapleStoryPacket, T: Encodable {
        guard let connection = await self.connections.connections[address] else {
            throw MapleStoryError.disconnected(address)
        }
        try await connection.send(packet)
    }
}

// MARK: - Supporting Types

public extension MapleStoryServer {
    
    struct DataSource {
        
        public let storage: Storage
        
        public let handlers: [(any ServerHandler.Type)]
        
        public init(
            storage: Storage,
            handlers: [any ServerHandler.Type]
        ) {
            self.storage = storage
            self.handlers = handlers
        }
    }
}

internal extension MapleStoryServer {
    
    actor Connections {
        
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

// MARK: - Connection

public extension MapleStoryServer {
    
    actor Connection {
        
        // MARK: - Properties
        
        public let address: MapleStoryAddress
        
        internal let connection: MapleStory.Connection<Socket>
        
        internal unowned var server: MapleStoryServer
        
        internal let log: (String) -> ()
        
        internal var state = ClientState()
        
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
                //let username = await server.connections.connections[address]?.connection.username
                await server.connections.removeConnection(address)
                //await server.dataSource.didDisconnect(address, username: username)
            }
            // always send handshake on connection
            Task {
                try await self.sendHandshake()
            }
        }
        
        private func registerLoginHandlers() async {
            
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
        public func send <Request, Response> (
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
        public func respond <T> (_ response: T) async throws where T: MapleStoryPacket, T: Encodable {
            log("Response: \(response)")
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    guard let _ = await self.connection.queue(response, didWrite: continuation)
                        else { fatalError("Could not add PDU to queue: \(response)") }
                }
            }
        }
        
        /// Send a server-initiated PDU message.
        public func send <T> (_ notification: T) async throws where T: MapleStoryPacket, T: Encodable  {
            log("Notification: \(notification)")
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    guard let _ = await self.connection.queue(notification, didWrite: continuation)
                        else { fatalError("Could not add PDU to queue: \(notification)") }
                }
            }
        }
        
        public func close(_ error: Error) async {
            log("Error: \(error)")
            await self.connection.close()
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
            let packet = await HelloPacket(
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
