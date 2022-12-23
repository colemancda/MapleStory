//
//  Connection.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import Socket

/// MapleStory Connection
internal actor Connection <Socket: MapleStorySocket> {
        
    let socket: Socket
    
    let log: ((String) -> ())?
    
    let version: Version
    
    let region: Region
    
    let timestamp = Date()
    
    let didDisconnect: ((Error?) async -> ())?
    
    var isConnected = true
    
    var recieveNonce = Nonce()
    
    var sendNonce = Nonce()
    
    var key: Key = .default
    
    var username: String?
        
    let encoder = MapleStoryEncoder()
    
    let decoder = MapleStoryDecoder()
    
    private var shouldEncrypt = false
        
    /// IDs for registered callbacks.
    private var nextRegisterID: UInt = 0
    
    /// IDs for "send" ops.
    private var nextSendOpcodeID: UInt = 0
    
    /// Queue of packets ready to send
    private var writeQueue = [SendOperation]()
    
    /// List of registered callbacks.
    private var notifyList = [NotifyType]()
    
    // MARK: - Initialization
    
    public init(
        socket: Socket,
        log: ((String) -> ())? = nil,
        version: Version = .v62,
        region: Region = .global,
        didDisconnect: ((Error?) async -> ())? = nil
    ) async {
        self.version = version
        self.region = region
        self.socket = socket
        self.log = log
        self.didDisconnect = didDisconnect
        run()
    }
    
    // MARK: - Methods
    
    internal func startEncryption() {
        shouldEncrypt = true
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
        case .pendingRead:
            #if DEBUG
            log?("Pending read")
            #endif
            do { try await read() }
            catch {
                log?("Unable to read. \(error)")
                await self.socket.close()
            }
        case let .read(byteCount):
            #if DEBUG
            log?("Did read \(byteCount) bytes")
            #endif
        case let .write(byteCount):
            #if DEBUG
            log?("Did write \(byteCount) bytes")
            #endif
            // try to write again
            do { try await write() }
            catch { log?("Unable to write. \(error)") }
        case let .close(error):
            #if DEBUG
            log?("Did close. \(error?.localizedDescription ?? "")")
            #endif
            isConnected = false
            await didDisconnect?(error)
        }
    }
    
    /// Performs the actual IO for recieving data.
    internal func read() async throws {
        
        // read unencrypted packet or encrypted header
        let bytesToRead = shouldEncrypt ? Packet.Encrypted.minSize : Int(UInt16.max)
        let recievedData = try await socket.recieve(bytesToRead)
        
        let packet: Packet
        if shouldEncrypt {
            // parse encrypted header
            let encryptedHeader = UInt32(bytes: (recievedData[0], recievedData[1], recievedData[2], recievedData[3]))
            let length = Packet.Encrypted.length(encryptedHeader)
            log?("Recieved encrypted packet length \(length)")
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
            guard let unencryptedPacket = Packet(data: recievedData) else {
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
        
        // encode packet
        let packet = try encoder.encodePacket(sendOperation.packet)
        
        #if DEBUG
        log?("Packet: \(packet.data.hexString)")
        #endif
        
        // encrypt packet parameters
        let data: Data
        if shouldEncrypt {
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
            data = packet.data
        }
        
        // write data to socket
        try await socket.send(data)
        
        log?("Sent packet \(packet.opcode)")
        sendOperation.didWrite?.resume()
        sendOperation.didWrite = nil
        
        return true
    }
    
    // write all pending PDUs
    private func writePending() {
        Task(priority: .high) { [weak self] in
            guard let self = self, await self.isConnected else { return }
            do { try await self.write() }
            catch {
                log?("Unable to write. \(error)")
                await self.socket.close()
            }
        }
    }
    
    /// Registers a callback for an opcode and returns the ID associated with that callback.
    @discardableResult
    public func register <T> (_ callback: @escaping (T) async -> ()) -> UInt where T: MapleStoryPacket, T: Decodable {
        
        let id = nextRegisterID
        
        // create notification
        let notify = Notify(id: id, notify: callback)
        
        // increment ID
        nextRegisterID += 1
        
        // add to queue
        notifyList.append(notify)
        
        return id
    }
    
    /// Unregisters the callback associated with the specified identifier.
    ///
    /// - Returns: Whether the callback was unregistered.
    @discardableResult
    public func unregister(_ id: UInt) -> Bool {
        
        guard let index = notifyList.firstIndex(where: { $0.id == id })
            else { return false }
        notifyList.remove(at: index)
        return true
    }
    
    /// Registers all callbacks.
    public func unregisterAll() {
        notifyList.removeAll()
    }
    
    /// Adds a packet to the queue to send.
    ///
    /// - Returns: Identifier of queued send operation or `nil` if the packet cannot be sent.
    @discardableResult
    public func queue <T> (
        _ packet: T,
        didWrite: CheckedContinuation<Void, Error>? = nil,
        response: (callback: CheckedContinuation<MapleStoryPacket, Error>, MapleStoryPacket.Type)? = nil
    ) -> UInt? where T: MapleStoryPacket, T: Encodable {
        
        // increment ID
        let id = nextSendOpcodeID
        nextSendOpcodeID += 1
        
        let sendOpcode = SendOperation(
            id: id,
            packet: packet,
            didWrite: didWrite,
            response: response
        )
        
        // Add the op to the correct queue based on its type
        writeQueue.append(sendOpcode)
        writePending()
        
        return sendOpcode.id
    }
    
    private func pickNextSendOpcode() -> SendOperation? {
        
        // See if any operations are already in the write queue
        if let sendOpcode = writeQueue.popFirst() {
            return sendOpcode
        }
        
        return nil
    }
    
    private func handle(notify packet: Packet) async throws {
        
        var foundPDU: MapleStoryPacket?
        
        let oldList = notifyList
        for notify in oldList {
            
            // try next opcode
            guard type(of: notify).packetType.opcode == packet.opcode else {
                continue
            }
            
            // attempt to deserialize
            guard let PDU = foundPDU ?? (try? type(of: notify).packetType.init(packet: packet, decoder: decoder))
                else { throw MapleStoryError.invalidData(packet.data) }
            
            foundPDU = PDU
            
            await notify.callback(PDU)
            
            // callback could remove all entries from notify list, if so, exit the loop
            if self.notifyList.isEmpty { break }
        }
    }
}

internal final class SendOperation {
    
    /// The operation identifier.
    let id: UInt
    
    /// The packet to send.
    let packet: any (MapleStoryPacket & Encodable)
    
    fileprivate(set) var didWrite: CheckedContinuation<Void, Error>?
    
    /// The response callback.
    fileprivate(set) var response: (callback: CheckedContinuation<MapleStoryPacket, Error>, responseType: MapleStoryPacket.Type)?
    
    deinit {
        didWrite?.resume(throwing: CancellationError())
        response?.callback.resume(throwing: CancellationError())
    }
    
    fileprivate init(
        id: UInt,
        packet: any (MapleStoryPacket & Encodable),
        didWrite: CheckedContinuation<Void, Error>?,
        response: (callback: CheckedContinuation<MapleStoryPacket, Error>, responseType: MapleStoryPacket.Type)?
    ) {
        self.id = id
        self.packet = packet
        self.response = response
        self.didWrite = didWrite
    }
}

internal protocol NotifyType {
    
    static var packetType: (MapleStoryPacket & Decodable).Type { get }
    
    var id: UInt { get }
    
    var callback: (MapleStoryPacket) async -> () { get }
}

internal struct Notify<Packet>: NotifyType where Packet: MapleStoryPacket, Packet: Decodable {
    
    static var packetType: (MapleStoryPacket & Decodable).Type { return Packet.self }
    
    let id: UInt
    
    let notify: (Packet) async -> ()
    
    var callback: (MapleStoryPacket) async -> () { return { await self.notify($0 as! Packet) } }
    
    init(id: UInt, notify: @escaping (Packet) async -> ()) {
        
        self.id = id
        self.notify = notify
    }
}
