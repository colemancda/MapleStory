import Foundation
import SystemPackage
import CoreModel
@_exported import MapleStory

/// MapleStory Classic Server
public final class MapleStoryServer <Socket: MapleStorySocket, Database: CoreModel.ModelStorage, ClientOpcode: MapleStoryOpcode, ServerOpcode: MapleStoryOpcode> {
        
    // MARK: - Properties
    
    public let configuration: ServerConfiguration
        
    public nonisolated let database: Database
    
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
                        do {
                            try await self.didConnect(connection: connection)
                        }
                        catch {
                           await connection.close(error)
                        }
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
    
    internal func stop() {
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
    ) async throws where T: MapleStoryPacket, T: Encodable, T.Opcode == ServerOpcode {
        guard let connection = await self.storage.connections[address] else {
            throw MapleStoryError.disconnected(address)
        }
        try await connection.send(packet)
    }
    
    /// Registers a callback for an opcode and returns the ID associated with that callback.
    internal func register <Packet> (
        _ callback: @escaping (Packet, Connection) async -> ()
    ) async where Packet: MapleStoryPacket, Packet: Decodable, Packet.Opcode == ClientOpcode {
        let registerBlock: (Connection) async -> () = { connection in
            await connection.register { [unowned connection] (packet: Packet) in
                await callback(packet, connection)
            }
        }
        // run block when client connects
        return await storage.register(handler: registerBlock)
    }
    
    public func register<T>(_ handler: T) async where T: PacketHandler, T.Packet.Opcode == ClientOpcode, T.ServerOpcode == ServerOpcode {
        await register { (packet, connection) in
            do {
                try await handler.handle(packet: packet, connection: connection)
            }
            catch {
                await connection.close(error)
            }
        }
    }
    
    public func register<Handler>(
        _ handler: Handler
    ) async where Handler: ServerHandler, Handler.ClientOpcode == ClientOpcode, Handler.ServerOpcode == ServerOpcode, Handler.Socket == Socket, Handler.Database == Database {
        let handler = ServerConnectionHandler { connection in
            try await handler.didConnect(connection: connection)
        } didDisconnect: { [unowned self] address in
            try await handler.didDisconnect(address: address, server: self)
        }
        await storage.register(handler: handler)
    }
    
    internal func didConnect(connection: Connection) async throws {
        let handlers = await self.storage.serverHandlers
        for handler in handlers {
            try await handler.didConnect(connection)
        }
    }
    
    internal func didDisconnect(address: MapleStoryAddress) async {
        let handlers = await self.storage.serverHandlers
        for handler in handlers {
            do {
                try await handler.didDisconnect(address)
            }
            catch {
                log?("\(type(of: handler)) error: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types

internal extension MapleStoryServer {
    
    actor InternalStorage {
                
        var connections = [MapleStoryAddress: Connection](minimumCapacity: 10_000)
        
        var serverHandlers = [ServerConnectionHandler]()
        
        var packetHandlers = [(Connection) async -> ()]()
        
        fileprivate init() { }
        
        func newConnection(_ connection: Connection) {
            connections[connection.address] = connection
        }
        
        func removeConnection(_ address: MapleStoryAddress) {
            connections[address] = nil
        }
        
        func removeAllConnections() {
            connections.removeAll(keepingCapacity: true)
        }
        
        func register(handler: @escaping (Connection) async -> ()) {
            packetHandlers.append(handler)
        }
        
        func register(handler: ServerConnectionHandler) {
            serverHandlers.append(handler)
        }
    }
}

internal extension MapleStoryServer.Connection {
    
    struct ClientState: Equatable, Hashable {
        
        var channel: Channel.ID?
        
        var world: Channel.ID?
        
        var user: User.ID?
        
        var character: Character.ID?
        
        var session: Session.ID?
    }
}

internal extension MapleStoryServer {
    
    struct ServerConnectionHandler {
        
        var didConnect: (Connection) async throws -> ()
        
        var didDisconnect: (MapleStoryAddress) async throws -> ()
    }
}

// MARK: - Connection

public extension MapleStoryServer {
    
    actor Connection {
        
        // MARK: - Properties
        
        public nonisolated var address: MapleStoryAddress {
            connection.address
        }
        
        public nonisolated var region: MapleStory.Region {
            connection.region
        }
        
        public nonisolated var version: MapleStory.Version {
            connection.version
        }
        
        public var recieveNonce: MapleStory.Nonce {
            get async {
                await connection.recieveNonce
            }
        }
        
        public var sendNonce: MapleStory.Nonce {
            get async {
                await connection.sendNonce
            }
        }
        
        internal let connection: MapleStory.Connection<Socket, ClientOpcode, ServerOpcode>
        
        internal unowned var server: MapleStoryServer
        
        internal let log: (String) -> ()
        
        public let database: Database
        
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
            self.database = server.database
            self.connection = await MapleStory.Connection(
                socket: socket,
                log: log,
                version: server.configuration.version,
                region: server.configuration.region,
                key: server.configuration.key
            ) { error in
                await server.storage.removeConnection(address)
                await server.didDisconnect(address: address)
            }
            // register packet handlers
            await registerPacketHandlers()
        }
        
        // MARK: - Methods
        
        /// Registers a callback for an opcode and returns the ID associated with that callback.
        internal func register <T> (
            _ callback: @escaping (T) async -> ()
        ) async where T: MapleStoryPacket, T: Decodable, T.Opcode == ClientOpcode {
            await connection.register(callback)
        }
        
        /// Respond to a client-initiated PDU message.
        public func send <T> (_ response: T) async throws where T: MapleStoryPacket, T: Encodable, T.Opcode == ServerOpcode {
            log("Send: \(response)")
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    do {
                        _ = try await self.connection.queue(response, didWrite: continuation)
                    }
                    catch {
                        assertionFailure("Could not add PDU to queue: \(response). \(error)")
                    }
                }
            }
        }
        
        /// Respond to a client-initiated PDU message.
        public func send(_ data: Data) async throws {
            log("Send: \(data.hexString)")
            return try await withCheckedThrowingContinuation { continuation in
                Task {
                    do {
                        _ = try await self.connection.queue(data, didWrite: continuation)
                    }
                    catch {
                        assertionFailure("Could not add PDU to queue: \(data). \(error)")
                    }
                }
            }
        }
        
        public func close(_ error: Error? = nil) async {
            if let error {
                log("Error: \(error)")
            }
            await self.connection.close()
        }
        
        public func encrypt() async {
            await connection.startEncryption()
        }
        
        private func registerPacketHandlers() async {
            let handlers = await server.storage.packetHandlers
            for handler in handlers {
                await handler(self) // register handler
            }
        }
    }
}

public extension MapleStoryServer.Connection {
    
    func authenticate(user: User) async {
        await connection.authenticate(username: user.username)
        self.state.user = user.id
    }
    
    func setNonce(send sendNonce: Nonce, recieve receiveNonce: Nonce) async {
        await connection.setNonce(send: sendNonce, recieve: receiveNonce)
    }
    
    var user: User? {
        get async throws {
            guard let id = self.state.user else {
                return nil
            }
            return try await database.fetch(User.self, for: id)
        }
    }
    
    var world: World? {
        get async throws {
            guard let id = self.state.world else {
                return nil
            }
            return try await database.fetch(World.self, for: id)
        }
    }
    
    var channel: Channel? {
        get async throws {
            guard let id = self.state.channel else {
                return nil
            }
            return try await database.fetch(Channel.self, for: id)
        }
    }
    
    var character: Character? {
        get async throws {
            guard let id = self.state.character else {
                return nil
            }
            return try await database.fetch(Character.self, for: id)
        }
    }
    
    var session: Session? {
        get async throws {
            guard let id = self.state.session else {
                return nil
            }
            return try await database.fetch(Session.self, for: id)
        }
    }
}
