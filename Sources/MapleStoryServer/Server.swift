import Foundation
import SystemPackage
import CoreModel
@_exported import MapleStory

/// MapleStory Classic Server
public final class MapleStoryServer <Socket: MapleStorySocket, Database: CoreModel.ModelStorage> {
    
    // MARK: - Properties
    
    public let configuration: ServerConfiguration
        
    public let database: Database
    
    internal let log: ((String) -> ())?
    
    internal let socket: Socket
    
    private var tcpListenTask: Task<(), Never>?
    
    let storage = InternalStorage()
    
    // MARK: - Initialization
    
    deinit {
        stop()
    }
    
    public init(
        configuration: ServerConfiguration,
        log: ((String) -> ())? = nil,
        database: Database,
        socket: Socket.Type
    ) async throws {
        #if DEBUG
        let log = log ?? {
            NSLog("MapleStoryServer: \($0)")
        }
        #endif
        self.configuration = configuration
        self.log = log
        self.database = database
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
                        await self.storage.newConnection(connection)
                        self.didConnect(connection: connection)
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
    
    /// Registers a callback for an opcode and returns the ID associated with that callback.
    internal func register <Packet> (
        _ callback: @escaping (Packet, Connection) async -> ()
    ) async where Packet: MapleStoryPacket, Packet: Decodable {
        let registerBlock: (Connection) async -> () = { connection in
            await connection.register { [unowned connection] (packet: Packet) in
                await callback(packet, connection)
            }
        }
        // run block when client connects
        return await storage.register(handler: registerBlock)
    }
    
    public func register<T: PacketHandler>(_ handler: T) async {
        await register { (packet, connection) in
            do {
                try await handler.handle(packet: packet, connection: connection)
            }
            catch {
                await connection.close(error)
            }
        }
    }
    
    internal func didConnect(connection: Connection) {
        
    }
    
    internal func didDisconnect(address: MapleStoryAddress) {
        
    }
}

// MARK: - Supporting Types

internal extension MapleStoryServer {
    
    actor InternalStorage {
        
        var connections = [MapleStoryAddress: Connection](minimumCapacity: 10_000)
        
        var handlers = [(Connection) async -> ()]()
        
        fileprivate init() { }
        
        func newConnection(_ connection: Connection) {
            connections[connection.address] = connection
        }
        
        func removeConnection(_ address: MapleStoryAddress) {
            connections[address] = nil
        }
        
        func removeAllConnections() {
            connections.removeAll()
        }
        
        func register(handler: @escaping (Connection) async -> ()) {
            handlers.append(handler)
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
        
        public nonisolated var address: MapleStoryAddress {
            connection.address
        }
        
        public var region: MapleStory.Region {
            connection.region
        }
        
        public var version: MapleStory.Version {
            connection.version
        }
        
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
            self.server = server
            self.connection = await MapleStory.Connection(
                socket: socket, 
                log: log,
                version: server.configuration.version,
                region: server.configuration.region,
                key: server.configuration.key
            ) { error in
                await server.storage.removeConnection(address)
                server.didDisconnect(address: address)
            }
            // register packet handlers
            await registerPacketHandlers()
            // always send handshake on connection
            Task {
                try await self.sendHandshake()
            }
        }
        
        // MARK: - Methods
        
        /// Registers a callback for an opcode and returns the ID associated with that callback.
        @discardableResult
        internal func register <T> (_ callback: @escaping (T) async -> ()) async -> UInt where T: MapleStoryPacket, T: Decodable {
            await connection.register(callback)
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
        
        private func registerPacketHandlers() async {
            let handlers = await server.storage.handlers
            for handler in handlers {
                await handler(self) // register handler
            }
        }
    }
}
