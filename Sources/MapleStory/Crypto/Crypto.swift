//
//  Crypto.swift
//  
//
//  Created by Alsey Coleman Miller on 12/13/22.
//

import Foundation
@_implementationOnly import CMapleStory
import CryptoSwift

public extension Packet {
    
    /// Encrypt
    func encrypt(
        key: Key? = .default,
        nonce: Nonce = Nonce(),
        version: Version
    ) throws -> EncryptedPacket {
        let iv = nonce.iv
        let length = self.data.count
        var encrypted = self.data
        Crypto.Maple.encrypt(&encrypted)
        if let key {
            encrypted = try Crypto.AES.encrypt(
                encrypted,
                key: key,
                iv: iv
            )
        }
        let header = EncryptedPacket.header(
            length: length,
            iv: iv,
            version: version
        )
        return EncryptedPacket(
            header: header,
            encrypted: encrypted
        )
    }
    
    /// Decrypt packet from data (without header).
    static func decrypt(
        _ data: Data,
        key: Key? = .default,
        nonce: Nonce,
        version: Version
    ) throws -> Packet {
        let iv = nonce.iv
        var decrypted: Data
        if let key {
            decrypted = try Crypto.AES.decrypt(
                data,
                key: key,
                iv: iv
            )
        } else {
            decrypted = data
        }
        Crypto.Maple.decrypt(&decrypted)
        guard let packet = Packet(data: decrypted) else {
            throw MapleStoryError.invalidData(decrypted)
        }
        return packet
    }
}

public extension EncryptedPacket {
    
    /// Decrypt
    func decrypt<Opcode: MapleStoryOpcode>(
        key: Key? = .default,
        nonce: Nonce,
        version: Version
    ) throws -> Packet<Opcode> {
        return try Packet.decrypt(
            self.parameters,
            key: key,
            nonce: nonce,
            version: version
        )
    }
}

internal extension EncryptedPacket {
    
    static func header(
        length: Int,
        iv: Data,
        version: Version
    ) -> UInt32 {
        let nbytes = UInt16(length)
        var lowpart = UInt16(bytes: (iv[2], iv[3]))
        let version = 0xffff - UInt16(version.rawValue)
        lowpart ^= version
        let hipart = lowpart ^ nbytes
        return UInt32(lowpart) | (UInt32(hipart) << 16)
    }
    
    init(header: UInt32, encrypted: Data) {
        let headerBytes = header.bytes
        var data = Data()
        data += [
            headerBytes.0,
            headerBytes.1,
            headerBytes.2,
            headerBytes.3
        ]
        data.append(encrypted)
        self.init(data)
    }
    
    var header: UInt32 {
        UInt32(bytes: (data[0], data[1], data[2], data[3]))
    }
    
    static func length(_ header: UInt32) -> Int {
        return Int((header & 0x0000FFFF) ^ (header >> 16))
    }
}

// MARK: - Crypto Function

internal enum Crypto {
    
    enum AES {
        
        static func encrypt(_ data: Data, key: Key, iv: Data) throws -> Data {
            let aes = try CryptoSwift.AES(key: .init(key.data), blockMode: OFB(iv: .init(iv)), padding: .noPadding)
            return try Data(aes.encrypt(.init(data)))
        }
        
        static func decrypt(_ data: Data, key: Key, iv: Data) throws -> Data {
            let aes = try CryptoSwift.AES(key: .init(key.data), blockMode: OFB(iv: .init(iv)), padding: .noPadding)
            return try Data(aes.decrypt(.init(data)))
        }
    }
    
    enum Maple {
        
        /// MapleStory encrypt
        static func encrypt(_ data: inout Data) {
            let length = Int32(data.count)
            data.withUnsafeMutableBytes {
                maple_encrypt($0.baseAddress, length)
            }
        }
        
        /// MapleStory decrypt
        static func decrypt(_ data: inout Data) {
            let length = Int32(data.count)
            data.withUnsafeMutableBytes {
                maple_decrypt($0.baseAddress, length)
            }
        }
    }
}

// MARK: - IV

internal extension Nonce {
    
    var iv: Data {
        var data = Data()
        let bytes = self.rawValue.bigEndian.bytes
        for _ in 0 ..< 4 {
            withUnsafeBytes(of: bytes) {
                $0.baseAddress?.withMemoryRebound(to: UInt8.self, capacity: 4) {
                    data.append($0, count: 4)
                }
            }
        }
        return data
    }
}
