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
    
    func register(
        username: String,
        password: String
    ) async throws -> Bool
    
    /// get the credentials for a user
    func password(
        for username: String
    ) async throws -> String
    
    /// get the credentials for a user
    func pin(
        for username: String
    ) async throws -> String
    
    /// check user exists
    func userExists(
        for username: String
    ) async throws -> Bool
    
    func worlds() async throws -> [World]
    
    func channel(
        _ id: Channel.ID,
        in world: World.ID
    ) async throws -> Channel
    
    func characters(
        for user: String
    ) async throws -> [World.ID: [Character]]
    
    func characters(
        for user: String,
        in world: World.ID,
        channel: Channel.ID
    ) async throws -> [Character]
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
            
            // login
            await register { [unowned self] in try await self.login($0) }
            await register { [unowned self] in try await self.guestLogin($0) }
            await register { [unowned self] in try await self.pinOperation($0) }
            await connection.register { [unowned self] in await self.serverList($0) }
            await register { [unowned self] in try await self.serverStatus($0) }
            await register { [unowned self] in try await self.characterList($0) }
            await connection.register { [unowned self] in await self.allCharacters($0) }
            await register { [unowned self] in try await self.selectCharacter($0) }
            await register { [unowned self] in try await self.selectAllCharacter($0) }
            
            // Channel
            await connection.register { [unowned self] in await self.playerLogin($0) }
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
                        
            // create if doesnt exist and autoregister enabled
            guard try await server.dataSource.register(username: request.username, password: request.password) == false else {
                log("Registered User - \(request.username)")
                await connection.authenticate(username: request.username)
                return .success(username: request.username)
            }
            
            // check if user exists
            guard try await self.server.dataSource.userExists(for: request.username) else {
                throw MapleStoryError.unknownUser(request.username) //.success(username: request.username) // TODO: Failure
            }
            
            // validate password
            let password = try await self.server.dataSource.password(for: request.username)
            guard password == request.password else {
                throw MapleStoryError.invalidPassword //return .success(username: request.username) // TODO: Failure
            }
            
            await connection.authenticate(username: request.username)
            return .success(username: request.username)
        }
        
        private func guestLogin(_ request: GuestLoginRequest) async throws -> LoginResponse {
            log("Guest Login")
            return .success(username: "Guest\(UUID())")
        }
        
        private func pinOperation(_ request: PinOperationRequest) async throws -> PinOperationResponse {
            log("Pin Operation")
            return .success
        }
        
        private func serverList(_ request: ServerListRequest) async {
            log("Server List")
            do {
                let worlds = try await server.dataSource.worlds()
                let responses: [ServerListResponse] = worlds
                    .map { .world(.init($0)) } + [.end]
                // send responses
                for response in responses {
                    try await respond(response)
                }
            }
            catch {
                await close(error)
            }
        }
        
        private func serverStatus(_ request: ServerStatusRequest) async throws -> ServerStatusResponse {
            log("Server Status - World \(request.world) Channel \(request.channel)")
            let channel = try await server.dataSource.channel(
                request.channel,
                in: request.world
            )
            return .init(channel.status)
        }
        
        private func characterList(_ request: CharacterListRequest) async throws -> CharacterListResponse {
            log("Character List - World \(request.world) Channel \(request.channel)")
            guard let username = await self.connection.username else {
                throw MapleStoryError.notAuthenticated
            }
            let characters = try await server.dataSource.characters(
                for: username,
                in: request.world,
                channel: request.channel
            )
            return CharacterListResponse(
                value0: 0x00,
                characters: characters.map { .init($0) },
                maxCharacters: 3
            )
        }
        
        private func allCharacters(_ request: AllCharactersRequest) async {
            log("All Character List")
            do {
                guard let username = await self.connection.username else {
                    throw MapleStoryError.notAuthenticated
                }
                let charactersByWorld = try await self.server.dataSource
                    .characters(for: username)
                    .sorted(by: { $0.key < $1.key })
                let count = charactersByWorld.reduce(0, { $0 + $1.value.count })
                let responses: [AllCharactersResponse] = [.count(count)]
                    + charactersByWorld.map { .characters(world: $0.key, characters: $0.value.map({ .init($0) })) }
                for response in responses {
                    try await respond(response)
                }
            }
            catch {
                await close(error)
            }
        }
        
        private func selectCharacter(_ request: CharacterSelectRequest) async throws -> ServerIPResponse {
            log("Select Character - Client \(request.client)")
            return ServerIPResponse(
                value0: 0,
                address: MapleStoryAddress(rawValue: "192.168.1.119:7575")!,
                client: request.client,
                value1: 0,
                value2: 0
            )
        }
        
        private func selectAllCharacter(_ request: AllCharactersSelectRequest) async throws -> ServerIPResponse {
            log("Select All Character - Client \(request.client)")
            return ServerIPResponse(
                value0: 0,
                address: MapleStoryAddress(rawValue: "192.168.1.119:7575")!,
                client: request.client,
                value1: 0,
                value2: 0
            )
        }
        
        private func playerLogin(_ request: PlayerLoginRequest) async {
            log("Player Login - Client \(request.client)")
            do {
                let warpMap = WarpToMapNotification.characterInfo(WarpToMapNotification.CharacterInfo(
                    channel: 0,
                    random0: 2339392202,
                    random1: 332863480,
                    random2: 2024654285,
                    stats: MapleStory.CharacterListResponse.CharacterStats(
                        id: 14,
                        name: "colemancda",
                        gender: .male,
                        skinColor: .normal,
                        face: 20000,
                        hair: 30023,
                        value0: 0,
                        value1: 0,
                        value2: 0,
                        level: 1,
                        job: .beginner,
                        str: 4,
                        dex: 4,
                        int: 4,
                        luk: 4,
                        hp: 50,
                        maxHp: 50,
                        mp: 5,
                        maxMp: 5,
                        ap: 9,
                        sp: 0,
                        exp: 12,
                        fame: 0,
                        isMarried: 0,
                        currentMap: 40000,
                        spawnPoint: 2,
                        value3: 0
                    ),
                    buddyListSize: 20,
                    meso: 13,
                    equipSlots: 100,
                    useSlots: 100,
                    setupSlots: 100,
                    etcSlots: 100,
                    cashSlots: 100
                ))
                
                try await send(warpMap)
            }
            catch {
                await close(error)
            }
        }
    }
}
