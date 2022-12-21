import Foundation
import ArgumentParser

/// MapleStory Classic Server
public final class MapleStoryServer <Socket: MapleStorySocket, DataSource: MapleStoryServerDataSource> {
    
    // MARK: - Properties
    
    public let configuration: MapleStoryServerConfiguration
    
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
        configuration: MapleStoryServerConfiguration,
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
            do {
                while let socket = self?.socket {
                    // wait for incoming sockets
                    let newSocket = try await socket.accept()
                    if let self = self {
                        self.log?("[\(newSocket.address.address)] New connection")
                        let connection = await MapleStoryServer.Connection(socket: newSocket, server: self)
                        await self.storage.newConnection(connection)
                        await self.dataSource.didConnect(newSocket.address)
                    }
                }
            }
            catch _ as CancellationError { }
            catch {
                self?.log?("Error waiting for new TCP connection: \(error)")
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
        await connection.send(packet)
    }
}

// MARK: - Supporting Types

/// MapleStory Server Data Source
public protocol MapleStoryServerDataSource: AnyObject {
    
    var command: ParsableCommand.Type { get }
    
    func didConnect(_ address: MapleStoryAddress) async
    
    func didDisconnect(_ address: MapleStoryAddress, username: String?) async
    
}

public actor InMemoryMapleStoryServerDataSource: MapleStoryServerDataSource {
    
    /// Initializer
    public init(
        stateChanged: ((State) -> ())? = nil
    ) {
        self.stateChanged = stateChanged
    }
    
    ///
    public private(set) var state = State() {
        didSet {
            if let stateChanged = self.stateChanged, state != oldValue {
                stateChanged(state)
            }
        }
    }
    
    internal let stateChanged: ((State) -> ())?
    
    public nonisolated var command: ParsableCommand.Type {
        fatalError() //DefaultCommand.self
    }
    
    public func update(_ body: (inout State) throws -> ()) rethrows {
        try body(&state)
    }
    
    public func didConnect(_ address: MapleStoryAddress) {
        
    }
    
    public func didDisconnect(_ address: MapleStoryAddress, username: String?) {
        
    }
}

public extension InMemoryMapleStoryServerDataSource {
    
    struct State: Equatable, Hashable, Codable {
        
        public var autoRegister = true
        
        //public var users = [String: User]()
        
        public var passwords = [String: String]()
        
        //public var channels = [Channel.ID: Channel]()
    }
}

public struct MapleStoryServerConfiguration: Equatable, Hashable, Codable {
    
    public let address: MapleStoryAddress
                    
    public let backlog: Int
    
    public init(
        address: MapleStoryAddress = .loginServerDefault,
        backlog: Int = 1000
    ) {
        self.address = address
        self.backlog = backlog
    }
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
        
        var channel: UInt16 = 0x00
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
        
        private var sendContinuations = [UInt: @Sendable (Swift.Error) -> ()]()
        
        private var sendID: UInt = 0
        
        // MARK: - Initialization
        
        deinit {
            let continuations = self.sendContinuations.values
            continuations.forEach { continuation in
                continuation(CancellationError())
            }
        }
        
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
            self.connection = await MapleStory.Connection(socket: socket, log: log) { error in
                let username = await server.storage.connections[address]?.connection.username
                await server.storage.removeConnection(address)
                await server.dataSource.didDisconnect(address, username: username)
            }
            await self.registerHandlers()
        }
        
        private func registerHandlers() async {
            // server directory
            //await register { [unowned self] in try await self.serverDirectory($0) }
        }
        
        /// Respond to a client-initiated PDU message.
        internal func send <Request, Response> (
            _ request: Request,
            response: Response.Type
        ) async throws -> Response where Request: MapleStoryPacket, Request: Encodable, Response: MapleStoryPacket, Response: Decodable {
            log("Request: \(request)")
            sendID += 1
            let id = sendID
            return try await withCheckedThrowingContinuation { [unowned self] continuation in
                Task {
                    let responseType: MapleStoryPacket.Type = response
                    // callback if no I/O errors or disconnect
                    let callback: (MapleStoryPacket) -> () = {
                        self.log("Response: \($0)")
                        self.sendContinuations[id] = nil
                        continuation.resume(returning: $0 as! Response)
                    }
                    guard let _ = await self.connection.queue(request, response: (callback, responseType))
                        else { fatalError("Could not add PDU to queue: \(request)") }
                    // store continuation in case it doesnt get called
                    self.sendContinuations[id] = { error in
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        
        /// Respond to a client-initiated PDU message.
        internal func respond <T> (_ response: T) async where T: MapleStoryPacket, T: Encodable {
            log("Response: \(response)")
            guard let _ = await connection.queue(response)
                else { fatalError("Could not add PDU to queue: \(response)") }
        }
        
        /// Send a server-initiated PDU message.
        internal func send <T> (_ notification: T) async where T: MapleStoryPacket, T: Encodable  {
            log("Notification: \(notification)")
            guard let _ = await connection.queue(notification)
                else { fatalError("Could not add PDU to queue: \(notification)") }
        }
        
        internal func close(_ error: Error) async {
            log("Error: \(error)")
            await self.connection.socket.close()
        }
        
        internal func sendHandshake() async {
            let packet = HelloPacket(
                version: self.connection.version,
                recieveNonce: await self.connection.recieveNonce,
                sendNonce: await self.connection.sendNonce,
                region: self.connection.region
            )
            //didHandshake = true
            await send(packet)
        }
        
        // MARK: - Requests
        
        
    }
}
