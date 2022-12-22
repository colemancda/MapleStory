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
        try await connection.send(packet)
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
            self.connection = await MapleStory.Connection(socket: socket, log: log) { error in
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
            await register { [unowned self] in try await self.login($0) }
            await register { [unowned self] in try await self.guestLogin($0) }
            await register { [unowned self] in try await self.pinOperation($0) }
            await connection.register { [unowned self] in await self.serverList($0) }
            await register { [unowned self] in try await self.serverStatus($0) }
            await register { [unowned self] in try await self.characterList($0) }
            await connection.register { [unowned self] in await self.allCharacters($0) }
            await register { [unowned self] in try await self.selectCharacter($0) }
            await register { [unowned self] in try await self.selectAllCharacter($0) }
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
        
        // MARK: - Requests
        
        private func login(_ request: LoginRequest) async throws -> LoginResponse {
            log("Login - \(request.username)")
            return LoginResponse.success(username: request.username)
        }
        
        private func guestLogin(_ request: GuestLoginRequest) async throws -> LoginResponse {
            log("Guest Login")
            return LoginResponse.success(username: "Guest\(UUID())")
        }
        
        private func pinOperation(_ request: PinOperationRequest) async throws -> PinOperationResponse {
            log("Pin Operation")
            return PinOperationResponse.success
        }
        
        private func serverList(_ request: ServerListRequest) async {
            log("Server List")
            do {
                let value = ServerListResponse.world(.init(
                    id: 0,
                    name: " World 0",
                    flags: 0x02,
                    eventMessage: "",
                    rateModifier: 0x64,
                    eventXP: 0x00,
                    rateModifier2: 0x64,
                    dropRate: 0x00,
                    value0: 0x00,
                    channels: [
                        ServerListResponse.Channel(
                            name: " World 0-1",
                            load: 0,
                            value0: 0x01,
                            id: 0
                        )
                    ],
                    value1: 0x00
                ))
                
                try await respond(value)
                try await respond(ServerListResponse.end)
            }
            catch {
                await close(error)
            }
        }
        
        private func serverStatus(_ request: ServerStatusRequest) async throws -> ServerStatusResponse {
            log("Server Status - World \(request.world) Channel \(request.channel)")
            return .normal
        }
        
        private func characterList(_ request: CharacterListRequest) async throws -> CharacterListResponse {
            log("Character List - World \(request.world) Channel \(request.channel)")
            return CharacterListResponse(
                value0: 0x00,
                characters: [
                    MapleStory.CharacterListResponse.Character(
                        stats: MapleStory.CharacterListResponse.CharacterStats(
                            id: 1,
                            name: "Admin",
                            gender: .male,
                            skinColor: .normal,
                            face: 20000,
                            hair: 30030,
                            value0: 0,
                            value1: 0,
                            value2: 0,
                            level: 254,
                            job: .buccaneer,
                            str: 32767,
                            dex: 32767,
                            int: 32767,
                            luk: 32767,
                            hp: 30000,
                            maxHp: 30000,
                            mp: 26474,
                            maxMp: 30000,
                            ap: 0,
                            sp: 0,
                            exp: 0,
                            fame: 13337,
                            isMarried: 0,
                            currentMap: 910000000,
                            spawnPoint: 1,
                            value3: 0
                        ),
                        appearance: MapleStory.CharacterListResponse.CharacterAppeareance(
                            gender: .male,
                            skinColor: .normal,
                            face: 20000,
                            mega: true,
                            hair: 30030,
                            equipment: [5: 0x82DE0F00, 6: 0xA22C1000, 9: 0xD9D01000, 1: 0x754B0F00, 7: 0x815B1000, 11: 0x279D1600],
                            maskedEquipment: [:],
                            cashWeapon: 0,
                            value0: 0,
                            value1: 0
                        ),
                        rank: MapleStory.CharacterListResponse.Rank(
                            worldRank: 1,
                            rankMove: 0,
                            jobRank: 1,
                            jobRankMove: 0
                        )
                    )
                ],
                maxCharacters: 3
            )
        }
        
        private func allCharacters(_ request: AllCharactersRequest) async {
            log("All Character List")
            do {
                let count = 1
                let unk = count + (3 - count % 3)
                let countPacket = AllCharactersResponse.count(characters: UInt32(count), value0: UInt32(unk))
                let worldPacket = AllCharactersResponse.characters(world: 0, characters: [
                    MapleStory.CharacterListResponse.Character(
                        stats: MapleStory.CharacterListResponse.CharacterStats(
                            id: 1,
                            name: "Admin",
                            gender: .male,
                            skinColor: .normal,
                            face: 20000,
                            hair: 30030,
                            value0: 0,
                            value1: 0,
                            value2: 0,
                            level: 254,
                            job: .buccaneer,
                            str: 32767,
                            dex: 32767,
                            int: 32767,
                            luk: 32767,
                            hp: 30000,
                            maxHp: 30000,
                            mp: 26474,
                            maxMp: 30000,
                            ap: 0,
                            sp: 0,
                            exp: 0,
                            fame: 13337,
                            isMarried: 0,
                            currentMap: 910000000,
                            spawnPoint: 1,
                            value3: 0
                        ),
                        appearance: MapleStory.CharacterListResponse.CharacterAppeareance(
                            gender: .male,
                            skinColor: .normal,
                            face: 20000,
                            mega: true,
                            hair: 30030,
                            equipment: [5: 0x82DE0F00, 6: 0xA22C1000, 9: 0xD9D01000, 1: 0x754B0F00, 7: 0x815B1000, 11: 0x279D1600],
                            maskedEquipment: [:],
                            cashWeapon: 0,
                            value0: 0,
                            value1: 0
                        ),
                        rank: MapleStory.CharacterListResponse.Rank(
                            worldRank: 1,
                            rankMove: 0,
                            jobRank: 1,
                            jobRankMove: 0
                        )
                    )
                ])
                try await respond(countPacket)
                try await respond(worldPacket)
            }
            catch {
                await close(error)
            }
        }
        
        private func selectCharacter(_ request: CharacterSelectRequest) async throws -> ServerIPResponse {
            log("Select Character - Client \(request.client)")
            return ServerIPResponse(
                value0: 0,
                address: MapleStoryAddress(rawValue: "192.168.1.119:8484")!,
                client: request.client,
                value1: 0,
                value2: 0
            )
        }
        
        private func selectAllCharacter(_ request: AllCharactersSelectRequest) async throws -> ServerIPResponse {
            log("Select All Character - Client \(request.client)")
            return ServerIPResponse(
                value0: 0,
                address: MapleStoryAddress(rawValue: "192.168.1.119:8484")!,
                client: request.client,
                value1: 0,
                value2: 0
            )
        }
    }
}
