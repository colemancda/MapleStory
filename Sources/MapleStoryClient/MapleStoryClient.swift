//
//  MapleStoryClient.swift
//  MapleStoryClient
//
//  Ported from the `Net` layer of https://github.com/ryantpayton/MapleStory-Client
//

import Foundation
import MapleStory

/// A MapleStory client network session.
///
/// Establishes a TCP connection to a MapleStory server, performs the unencrypted
/// handshake, then reads and writes AES + MapleStory-encrypted packets. Incoming
/// server packets are dispatched to registered callbacks; outgoing client packets
/// are encrypted and queued.
///
/// This mirrors the reference client's `Session` / `PacketSwitch`, and the server's
/// `Connection` actor, but from the client's point of view: it *reads* ``ServerOpcode``
/// packets and *writes* ``ClientOpcode`` packets.
public actor MapleStoryClient <
    Socket: MapleStorySocket,
    Handshake: HandshakePacket,
    ClientOpcode: MapleStoryOpcode,
    ServerOpcode: MapleStoryOpcode
> {

    // MARK: - Properties

    public nonisolated let destination: MapleStoryAddress

    nonisolated(unsafe) let socket: Socket

    nonisolated(unsafe) let log: ((String) -> ())?

    public private(set) var version: Version = .v83

    public private(set) var region: Region = .global

    public let key: Key?

    public private(set) var handshake: Handshake?

    public private(set) var isConnected = true

    private var isEncrypted = false

    private var sendNonce = Nonce()

    private var recieveNonce = Nonce()

    nonisolated(unsafe) let encoder = MapleStoryEncoder()

    nonisolated(unsafe) let decoder = MapleStoryDecoder()

    private var writeQueue = [Data]()

    private var notifyList = [ServerOpcode: ClientNotifyType]()

    private var handshakeContinuation: CheckedContinuation<Handshake, Error>?

    private let didDisconnect: (@Sendable (Error?) async -> ())?

    // MARK: - Initialization

    internal init(
        socket: Socket,
        destination: MapleStoryAddress,
        key: Key?,
        log: ((String) -> ())?,
        didDisconnect: (@Sendable (Error?) async -> ())?
    ) {
        self.socket = socket
        self.destination = destination
        self.key = key
        self.log = log
        self.didDisconnect = didDisconnect
        self.writeQueue.reserveCapacity(10)
        self.notifyList.reserveCapacity(25)
    }

    // MARK: - Connecting

    /// Connect to a server and complete the handshake.
    ///
    /// - Returns: A ready-to-use client whose ``handshake`` has been received and whose
    ///   ciphers are seeded.
    public static func connect(
        configuration: ClientConfiguration,
        log: (@Sendable (String) -> ())? = nil,
        didDisconnect: (@Sendable (Error?) async -> ())? = nil
    ) async throws -> MapleStoryClient {
        log?("Connecting to \(configuration.destination)")
        let socket = try await Socket.client(
            address: configuration.address,
            destination: configuration.destination
        )
        let client = MapleStoryClient(
            socket: socket,
            destination: configuration.destination,
            key: configuration.key,
            log: log,
            didDisconnect: didDisconnect
        )
        await client.run()
        // wait for the server's handshake before returning
        _ = try await client.waitForHandshake()
        return client
    }

    private func waitForHandshake() async throws -> Handshake {
        if let handshake = self.handshake {
            return handshake
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.handshakeContinuation = continuation
        }
    }

    public func close() async {
        isConnected = false
        await socket.close()
    }

    // MARK: - Run Loop

    private func run() {
        let stream = socket.event
        Task.detached(priority: .high) { [weak self] in
            for await event in stream {
                await self?.socketEvent(event)
            }
        }
    }

    private func socketEvent(_ event: MapleStorySocketEvent) async {
        switch event {
        case .read:
            do { try await read() }
            catch {
                log?("Unable to read. \(error)")
                await close()
            }
        case .didWrite:
            do { try await write() }
            catch { log?("Unable to write. \(error)") }
        case .close:
            isConnected = false
            handshakeContinuation?.resume(throwing: MapleStoryError.disconnected(destination))
            handshakeContinuation = nil
            await didDisconnect?(nil)
        case .didRead, .connection, .write, .error:
            break
        }
    }

    // MARK: - Reading

    private func read() async throws {
        if isEncrypted {
            try await readEncrypted()
        } else {
            try await readHandshake()
        }
    }

    /// The first packet the server sends is the unencrypted handshake.
    private func readHandshake() async throws {
        let data = try await socket.recieve(Int(UInt16.max))
        let handshake = try decoder.decode(Handshake.self, from: data)
        log?("Received handshake (version \(handshake.version), region \(handshake.region))")
        self.handshake = handshake
        self.version = handshake.version
        self.region = handshake.region
        // From the client's perspective the server's send cipher is our receive cipher.
        self.recieveNonce = handshake.sendNonce
        self.sendNonce = handshake.recieveNonce
        self.isEncrypted = true
        handshakeContinuation?.resume(returning: handshake)
        handshakeContinuation = nil
    }

    private func readEncrypted() async throws {
        // read the 4-byte encrypted header
        let header = try await socket.recieve(EncryptedPacket.minSize)
        guard header.count >= EncryptedPacket.minSize else {
            throw MapleStoryError.invalidData(header)
        }
        let headerBytes = [UInt8](header)
        let b0 = UInt32(headerBytes[0])
        let b1 = UInt32(headerBytes[1]) << 8
        let b2 = UInt32(headerBytes[2]) << 16
        let b3 = UInt32(headerBytes[3]) << 24
        let encryptedHeader = b0 | b1 | b2 | b3
        let length = EncryptedPacket.length(header: encryptedHeader)
        let body = try await socket.recieve(length)
        let packet: Packet<ServerOpcode> = try Packet.decrypt(
            body,
            key: key,
            nonce: recieveNonce,
            version: version
        )
        recieveNonce.shuffle()
        log?("Received \(packet.opcode) (\(packet.data.count) bytes)")
        try await dispatch(packet)
    }

    // MARK: - Writing

    /// Encode, encrypt, and queue a client packet for sending.
    public func send <T> (
        _ packet: T
    ) async throws where T: MapleStoryPacket, T: Encodable, T.Opcode == ClientOpcode {
        let encoded = try encoder.encodePacket(packet)
        let encrypted = try encoded.encrypt(key: key, nonce: sendNonce, version: version)
        sendNonce.shuffle()
        writeQueue.append(encrypted.data)
        log?("Queued \(packet)")
        try await write()
    }

    @discardableResult
    private func write() async throws -> Bool {
        guard isConnected, writeQueue.isEmpty == false else { return false }
        let data = writeQueue.removeFirst()
        try await socket.send(data)
        log?("Sent \(data.count) bytes")
        return true
    }

    // MARK: - Dispatching

    /// Register a callback for a server packet type.
    public func register <T> (
        _ callback: @escaping @Sendable (T) async -> ()
    ) where T: MapleStoryPacket, T: Decodable, T: Sendable, T.Opcode == ServerOpcode {
        notifyList[T.opcode] = Notify(opcode: T.opcode, notify: callback)
    }

    /// Register a ``ClientHandler`` for a server packet type.
    public func register <H> (
        handler: H
    ) where H: ClientHandler,
            H.Client == MapleStoryClient<Socket, Handshake, ClientOpcode, ServerOpcode>,
            H.Packet.Opcode == ServerOpcode {
        register { [weak self] (packet: H.Packet) in
            guard let self else { return }
            do {
                try await handler.handle(packet: packet, client: self)
            } catch {
                await self.logError("Handler \(H.self) failed: \(error)")
            }
        }
    }

    public func unregister(_ opcode: ServerOpcode) {
        notifyList.removeValue(forKey: opcode)
    }

    private func logError(_ message: String) {
        log?(message)
    }

    private func dispatch(_ packet: Packet<ServerOpcode>) async throws {
        let opcode = packet.opcode
        guard let notify = notifyList[opcode] else {
            log?("Received unhandled packet \(opcode)")
            return
        }
        do {
            try await notify.handle(packetData: packet.data, decoder: decoder)
        } catch {
            log?("Unable to decode \(opcode). \(error)")
        }
    }
}

// MARK: - Supporting Types

extension MapleStoryClient {

    struct Notify <T>: ClientNotifyType where T: MapleStoryPacket, T: Decodable, T: Sendable, T.Opcode == ServerOpcode {

        let opcode: ServerOpcode

        let notify: @Sendable (T) async -> ()

        func handle(packetData: Data, decoder: MapleStoryDecoder) async throws {
            guard let packet = Packet<T.Opcode>(data: packetData) else {
                throw MapleStoryError.invalidData(packetData)
            }
            let value = try decoder.decode(T.self, from: packet)
            await notify(value)
        }
    }
}

internal protocol ClientNotifyType: Sendable {

    func handle(packetData: Data, decoder: MapleStoryDecoder) async throws
}
