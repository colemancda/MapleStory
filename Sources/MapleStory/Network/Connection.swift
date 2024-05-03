//
//  Connection.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import Socket

/// MapleStory Connection
public actor Connection <Socket: MapleStorySocket, ReadOpcode: MapleStoryOpcode, WriteOpcode: MapleStoryOpcode> {
    
    public nonisolated var address: MapleStoryAddress {
        socket.address
    }
    
    let socket: Socket
    
    let log: ((String) -> ())?
    
    public nonisolated let version: Version
    
    public nonisolated let region: Region
    
    let timestamp = Date()
    
    let didDisconnect: ((Error?) async -> ())?
        
    var isConnected = true
    
    public var recieveNonce = Nonce()
    
    public var sendNonce = Nonce()
    
    public let key: Key?
    
    public var username: Username?
    
    nonisolated let encoder = MapleStoryEncoder()
    
    nonisolated let decoder = MapleStoryDecoder()
    
    private var shouldEncrypt = false
    
    /// IDs for "send" ops.
    private var nextSendOpcodeID: UInt = 0
    
    /// Queue of packets ready to send
    private var writeQueue = [SendOperation]()
    
    /// List of registered callbacks.
    private var notifyList = [ReadOpcode: ConnectionNotifyType]()
    
    // MARK: - Initialization
    
    public init(
        socket: Socket,
        log: ((String) -> ())? = nil,
        version: Version,
        region: Region = .global,
        key: Key? = .default,
        didDisconnect: ((Error?) async -> ())? = nil
    ) async {
        self.version = version
        self.region = region
        self.key = key
        self.socket = socket
        self.log = log
        self.didDisconnect = didDisconnect
        run()
        self.writeQueue.reserveCapacity(10)
        self.notifyList.reserveCapacity(25)
    }
    
    // MARK: - Methods
    
    public func close() async {
        await socket.close()
    }
    
    public func startEncryption() {
        self.shouldEncrypt = true
    }
    
    public func authenticate(username: Username) {
        self.username = username
    }
    
    public func setNonce(send sendNonce: Nonce, recieve receiveNonce: Nonce) {
        self.sendNonce = sendNonce
        self.recieveNonce = receiveNonce
    }
    
    private func run() {
        Task.detached(priority: .high) { [weak self] in
            guard let stream = self?.socket.event else { return }
            for await event in stream {
                await self?.socketEvent(event)
            }
            // socket closed
        }
    }
    
    private func socketEvent(_ event: MapleStorySocketEvent) async {
        switch event {
        case .read:
            #if DEBUG
            log?("Pending read")
            #endif
            do { try await read() }
            catch {
                log?("Unable to read. \(error)")
                await self.socket.close()
            }
        case let .didRead(byteCount):
            #if DEBUG
            log?("Did read \(byteCount) bytes")
            #endif
        case let .didWrite(byteCount):
            #if DEBUG
            log?("Did write \(byteCount) bytes")
            #endif
            // try to write again
            do { try await write() }
            catch { log?("Unable to write. \(error)") }
        case let .error(error):
            #if DEBUG
            log?("Error. \(error.localizedDescription)")
            #endif
        case .close:
            isConnected = false
            await didDisconnect?(nil)
        case .connection:
            break
        case .write:
            break
        }
    }
    
    /// Performs the actual IO for recieving data.
    internal func read() async throws {
        
        // read unencrypted packet or encrypted header
        let bytesToRead = shouldEncrypt ? EncryptedPacket.minSize : Int(UInt16.max)
        let recievedData = try await socket.recieve(bytesToRead)
        
        let packet: Packet<ReadOpcode>
        if shouldEncrypt {
            // parse encrypted header
            let encryptedHeader = UInt32(
                bytes: (
                    recievedData[0],
                    recievedData[1],
                    recievedData[2],
                    recievedData[3]
                )
            )
            let length = EncryptedPacket.length(encryptedHeader)
            #if DEBUG
            log?("Recieved encrypted packet length \(length)")
            #endif
            let encryptedPacketData = try await socket.recieve(length)
            #if DEBUG
            log?("Encrypted data: \(encryptedPacketData.hexString)")
            log?("Nonce: \(recieveNonce)")
            #endif
            packet = try Packet.decrypt(
                encryptedPacketData,
                key: key,
                nonce: recieveNonce,
                version: version
            )
            recieveNonce.shuffle()
        } else {
            // parse unencrypted packet
            guard let unencryptedPacket = Packet<ReadOpcode>(data: recievedData) else {
                throw MapleStoryError.invalidData(recievedData)
            }
            packet = unencryptedPacket
        }
        
        #if DEBUG
        log?("Packet: \(packet.data.hexString)")
        #endif
        
        log?("Recieved packet \(packet.opcode) (\(packet.data.count) bytes)")
        
        try await handle(notify: packet)
    }
    
    /// Performs the actual IO for sending data.
    @discardableResult
    internal func write() async throws -> Bool {
        
        // get next write operation
        guard let sendOperation = pickNextSendOpcode()
            else { return false }
        
        #if DEBUG
        log?("Packet: \(sendOperation.packet.data.hexString)")
        #endif
        
        // encrypt packet parameters
        let data: Data
        if shouldEncrypt, case let .packet(packet) = sendOperation.packet {
            data = try packet.encrypt(
                key: key,
                nonce: sendNonce,
                version: version
            ).data
            #if DEBUG
            log?("Encrypted data: \(data.hexString)")
            log?("Nonce: \(sendNonce)")
            #endif
            sendNonce.shuffle()
        } else {
            data = sendOperation.packet.data
        }
        
        // write data to socket
        try await socket.send(data)
        
        switch sendOperation.packet {
        case .bytes(let data):
            log?("Sent \(data.count) bytes")
        case .packet(let packet):
            log?("Sent \(packet.opcode) (\(packet.data.count) bytes)")
        }
        sendOperation.didWrite?.resume()
        sendOperation.didWrite = nil
        
        return true
    }
    
    // write all pending PDUs
    private func writePending() {
        Task(priority: .high) { [weak self] in
            guard let self = self, await self.isConnected else { return }
            do { try await self.write() }
            catch Errno.socketShutdown {
                return
            }
            catch {
                log?("Unable to write. \(error)")
                await self.socket.close()
            }
        }
    }
    
    /// Registers a callback for an opcode and returns the ID associated with that callback.
    public func register <T> (
        _ callback: @escaping (T) async -> ()
    ) where T: MapleStoryPacket, T: Decodable, T.Opcode == ReadOpcode {
        let notify = Notify(
            opcode: T.opcode,
            notify: callback
        )
        notifyList[T.opcode] = notify
    }
    
    /// Unregisters the callback associated with the specified identifier.
    ///
    /// - Returns: Whether the callback was unregistered.
    public func unregister(_ opcode: ReadOpcode) {
        notifyList.removeValue(forKey: opcode)
    }
    
    /// Registers all callbacks.
    public func unregisterAll() {
        notifyList.removeAll(keepingCapacity: true)
    }
    
    /// Adds a packet to the queue to send.
    ///
    /// - Returns: Identifier of queued send operation or `nil` if the packet cannot be sent.
    @discardableResult
    public func queue <T> (
        _ packet: T,
        didWrite: CheckedContinuation<Void, Error>? = nil
    ) throws -> UInt where T: MapleStoryPacket, T: Encodable, T.Opcode == WriteOpcode {
        let encodedPacket = try encoder.encodePacket(packet)
        return try queue(.packet(encodedPacket), didWrite: didWrite)
    }
    
    /// Adds a packet to the queue to send.
    ///
    /// - Returns: Identifier of queued send operation or `nil` if the packet cannot be sent.
    public func queue(
        _ packet: Data,
        didWrite: CheckedContinuation<Void, Error>? = nil
    ) throws -> UInt {
        return try queue(.bytes(packet), didWrite: didWrite)
    }
    
    /// Adds a packet to the queue to send.
    ///
    /// - Returns: Identifier of queued send operation or `nil` if the packet cannot be sent.
    private func queue(
        _ packet: SendOperation.PacketData,
        didWrite: CheckedContinuation<Void, Error>? = nil
    ) throws -> UInt {
        
        // increment ID
        let id = nextSendOpcodeID
        nextSendOpcodeID += 1
                
        let sendOpcode = SendOperation(
            id: id,
            packet: packet,
            didWrite: didWrite
        )
        
        // Add the op to the correct queue based on its type
        writeQueue.append(sendOpcode)
        writePending()
        
        return sendOpcode.id
    }
    
    private func pickNextSendOpcode() -> SendOperation? {
        writeQueue.popFirst()
    }
    
    private func handle(notify packet: Packet<ReadOpcode>) async throws {
        
        let opcode = packet.opcode
        guard let notify = notifyList[opcode] else {
            #if DEBUG
            log?("Recieved unhandled packet \(opcode)")
            #endif
            return
        }
        
        let value: Decodable
        do {
            value = try decoder.decodeGeneric(type(of: notify).packetType, from: packet)
        }
        catch {
            #if DEBUG
            log?("Unable to decode \(opcode). \(error)")
            #endif
            throw MapleStoryError.invalidData(packet.data)
        }
        
        // execute callback
        await notify.callback(value)
    }
}

internal extension Connection {
    
    final class SendOperation {
        
        /// The operation identifier.
        let id: UInt
        
        /// The packet to send.
        let packet: PacketData
        
        fileprivate(set) var didWrite: CheckedContinuation<Void, Error>?
        
        deinit {
            didWrite?.resume(throwing: CancellationError())
        }
        
        fileprivate init(
            id: UInt,
            packet: PacketData,
            didWrite: CheckedContinuation<Void, Error>?
        ) {
            self.id = id
            self.packet = packet
            self.didWrite = didWrite
        }
    }
}

internal extension Connection.SendOperation {
    
    enum PacketData {
        case bytes(Foundation.Data)
        case packet(MapleStory.Packet<WriteOpcode>)
    }
}

internal extension Connection.SendOperation.PacketData {
    
    var data: Data {
        switch self {
        case let .bytes(data):
            return data
        case let .packet(packet):
            return packet.data
        }
    }
}

internal extension Connection {
    
    struct Notify<T>: ConnectionNotifyType, Identifiable where T: MapleStoryPacket, T: Decodable, T.Opcode == ReadOpcode {
                                
        let opcode: ReadOpcode
        
        let notify: (T) async -> ()
        
        static var packetType: Decodable.Type { T.self }
        
        var id: UInt {
            .init(opcode.rawValue)
        }
        
        var callback: (Decodable) async -> () {
            { await self.notify($0 as! T) }
        }
        
        init(
            opcode: ReadOpcode,
            notify: @escaping (T) async -> ()
        ) {
            self.opcode = opcode
            self.notify = notify
        }
    }
}

internal protocol ConnectionNotifyType {
    
    static var packetType: Decodable.Type { get }
    
    var id: UInt { get }
    
    var callback: (any Decodable) async -> () { get }
}
