//
//  Socket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import Socket

/// MapleStory Socket protocol
public protocol MapleStorySocket {
    
    /// Socket address
    var address: MapleStoryAddress { get }
    
    /// Event stream
    var event: MapleStorySocketEventStream { get }
    
    /// Write to the socket.
    func send(_ data: Data) async throws
    
    /// Reads from the socket.
    func recieve(_ bufferSize: Int) async throws -> Data
    
    /// Attempt to accept an incoming connection.
    func accept() async throws -> Self
    
    /// Close immediately.
    func close() async
    
    static func client(
        address: MapleStoryAddress,
        destination: MapleStoryAddress
    ) async throws -> Self
    
    static func server(
        address: MapleStoryAddress,
        backlog: Int
    ) async throws -> Self
}

public protocol MapleStorySocketUDP {
    
    /// Initialize with address
    init(address: MapleStoryAddress) async throws
    
    /// Socket address
    var address: MapleStoryAddress { get }
    
    /// Event stream
    var event: MapleStorySocketEventStream { get }
    
    /// Write to the socket.
    func send(_ data: Data, to destination: MapleStoryAddress) async throws
    
    /// Reads from the socket.
    func recieve(_ bufferSize: Int) async throws -> (Data, MapleStoryAddress)
}

/// MapleStory Socket Event
public enum MapleStorySocketEvent {
    
    /// New connection
    case connection
    
    /// Pending read
    case read
    
    /// Pending Write
    case write
    
    /// Did read
    case didRead(Int)
    
    /// Did write
    case didWrite(Int)
    
    /// Error ocurred
    case error(Error)
    
    /// Socket closed
    case close
}

public typealias MapleStorySocketEventStream = AsyncStream<MapleStorySocketEvent>

// MARK: - Implementation

public final class MapleStorySocketIPv4TCP: MapleStorySocket {
    
    // MARK: - Properties
    
    public let address: MapleStoryAddress
    
    @usableFromInline
    internal let socket: Socket
    
    public var event: MapleStorySocketEventStream {
        let stream = self.socket.event
        var iterator = stream.makeAsyncIterator()
        return MapleStorySocketEventStream(unfolding: {
            await iterator
                .next()
                .map { .init($0) }
        })
    }
    
    // MARK: - Initialization
    
    deinit {
        // TODO: Fix crash
        /*
        Task(priority: .high) {
            await socket.close()
        }
         */
    }
    
    internal init(
        socket: Socket,
        address: MapleStoryAddress
    ) {
        self.socket = socket
        self.address = address
    }
    
    internal init(
        fileDescriptor: SocketDescriptor,
        address: MapleStoryAddress
    ) async {
        self.socket = await Socket(fileDescriptor: fileDescriptor)
        self.address = address
    }
    
    public static func client(
        address localAddress: MapleStoryAddress,
        destination destinationAddress: MapleStoryAddress
    ) async throws -> Self {
        let fileDescriptor = try SocketDescriptor.tcp(localAddress) // [.closeOnExec, .nonBlocking])
        let socket = await Socket(fileDescriptor: fileDescriptor)
        try fileDescriptor.closeIfThrows {
            try fileDescriptor.setSocketOption(GenericSocketOption.ReuseAddress(true))
            try fileDescriptor.setNonblocking()
        }
        try await socket.connect(to: IPv4SocketAddress(destinationAddress))
        return Self(
            socket: socket,
            address: localAddress
        )
    }
    
    public static func server(
        address: MapleStoryAddress,
        backlog: Int = 100
    ) async throws -> Self {
        let fileDescriptor = try SocketDescriptor.tcp(address) // [.closeOnExec, .nonBlocking])
        try fileDescriptor.closeIfThrows {
            try fileDescriptor.listen(backlog: backlog)
            try fileDescriptor.setNonblocking()
        }
        return await Self(
            fileDescriptor: fileDescriptor,
            address: address
        )
    }
    
    // MARK: - Methods
    
    public func accept() async throws -> Self {
        let (clientFileSocket, clientAddress) = try await socket.accept(IPv4SocketAddress.self)
        let address = MapleStoryAddress(
            ipAddress: clientAddress.address,
            port: clientAddress.port
        )
        return Self(
            socket: clientFileSocket,
            address: address
        )
    }
    
    /// Write to the socket.
    public func send(_ data: Data) async throws {
        try await socket.write(data)
    }
    
    /// Reads from the socket.
    public func recieve(_ bufferSize: Int) async throws -> Data {
        return try await socket.read(bufferSize)
    }
    
    public func close() async {
        await socket.close()
    }
}

internal extension MapleStorySocketEvent {
    
    init(_ event: Socket.Event) {
        // TODO: Create with switch statement
        self = unsafeBitCast(event, to: MapleStorySocketEvent.self)
    }
}

internal extension SocketDescriptor {
    
    /// Creates a TCP socket binded to the specified address.
    @usableFromInline
    static func tcp(
        _ address: MapleStoryAddress
    ) throws -> SocketDescriptor {
        let socketProtocol = IPv4Protocol.tcp
        let socketAddress = IPv4SocketAddress(address)
        return try self.init(socketProtocol, bind: socketAddress)
    }
    
    @usableFromInline
    func setNonblocking(retryOnInterrupt: Bool = true) throws {
        var flags = try getStatus(retryOnInterrupt: retryOnInterrupt)
        flags.insert(.nonBlocking)
        try setStatus(flags, retryOnInterrupt: retryOnInterrupt)
    }
}
