//
//  PlayerShopRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Client packet for all player-to-player interaction: player shops, trades, and mini-games.
public enum PlayerShopRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .playerShop }

    // MARK: - Create interactions

    case createTrade
    case createShop(description: String)
    case createOmok(description: String, pieceType: UInt8)
    case createMatchCard(description: String, pieceType: UInt8)

    // MARK: - Session management

    case invite(targetID: UInt32)
    case decline
    case visit(objectID: UInt32)
    case chat(message: String)
    case exit
    case open

    // MARK: - Trade

    case setMeso(amount: UInt32)
    case setItems(inventoryType: UInt8, slot: Int16, quantity: Int16, targetSlot: UInt8)
    case confirm

    // MARK: - Shop

    case addItem(inventoryType: UInt8, slot: Int8, bundles: Int16, perBundle: Int16, price: UInt32)
    case buy(slot: UInt8, quantity: Int16)
    case removeItem(slot: Int16)

    // MARK: - Mini-game

    case ready
    case unready
    case start
    case giveUp
    case requestTie
    case answerTie(type: UInt8)
    case skip
    case moveOmok(x: UInt32, y: UInt32, pieceType: UInt8)
    case selectCard(turn: UInt8, slot: UInt8)
    case exitAfterGame
    case cancelExit
}

extension PlayerShopRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let mode = try container.decode(UInt8.self)
        switch mode {
        case 0x00: // CREATE
            let createType = try container.decode(UInt8.self)
            switch createType {
            case 3:
                self = .createTrade
            case 4:
                let desc = try container.decode(String.self, forKey: CodingKeys.description)
                self = .createShop(description: desc)
            case 1:
                let desc = try container.decode(String.self, forKey: CodingKeys.description)
                let _ = try container.decode(UInt8.self)   // unknown
                let pieceType = try container.decode(UInt8.self)
                self = .createOmok(description: desc, pieceType: pieceType)
            case 2:
                let desc = try container.decode(String.self, forKey: CodingKeys.description)
                let _ = try container.decode(UInt8.self)   // unknown
                let pieceType = try container.decode(UInt8.self)
                self = .createMatchCard(description: desc, pieceType: pieceType)
            default:
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown create type \(createType)"))
            }
        case 0x02:
            let targetID = try container.decode(UInt32.self, forKey: CodingKeys.targetID)
            self = .invite(targetID: targetID)
        case 0x03:
            self = .decline
        case 0x04:
            let objectID = try container.decode(UInt32.self, forKey: CodingKeys.objectID)
            self = .visit(objectID: objectID)
        case 0x06:
            let message = try container.decode(String.self, forKey: CodingKeys.message)
            self = .chat(message: message)
        case 0x0A:
            self = .exit
        case 0x0B:
            self = .open
        case 0x0E:
            let inventoryType = try container.decode(UInt8.self, forKey: CodingKeys.inventoryType)
            let slot = try container.decode(Int16.self, forKey: CodingKeys.slot)
            let quantity = try container.decode(Int16.self, forKey: CodingKeys.quantity)
            let targetSlot = try container.decode(UInt8.self, forKey: CodingKeys.targetSlot)
            self = .setItems(inventoryType: inventoryType, slot: slot, quantity: quantity, targetSlot: targetSlot)
        case 0x0F:
            let amount = try container.decode(UInt32.self, forKey: CodingKeys.amount)
            self = .setMeso(amount: amount)
        case 0x10:
            self = .confirm
        case 0x13:
            let inventoryType = try container.decode(UInt8.self, forKey: CodingKeys.inventoryType)
            let slot = try container.decode(Int8.self, forKey: CodingKeys.slot8)
            let bundles = try container.decode(Int16.self, forKey: CodingKeys.bundles)
            let perBundle = try container.decode(Int16.self, forKey: CodingKeys.perBundle)
            let price = try container.decode(UInt32.self, forKey: CodingKeys.price)
            self = .addItem(inventoryType: inventoryType, slot: slot, bundles: bundles, perBundle: perBundle, price: price)
        case 0x14:
            let slot = try container.decode(UInt8.self, forKey: CodingKeys.slot8u)
            let quantity = try container.decode(Int16.self, forKey: CodingKeys.quantity)
            self = .buy(slot: slot, quantity: quantity)
        case 0x18:
            let slot = try container.decode(Int16.self, forKey: CodingKeys.slot)
            self = .removeItem(slot: slot)
        case 0x2C:
            self = .ready
        case 0x2D:
            self = .unready
        case 0x2E:
            self = .exitAfterGame
        case 0x2F:
            self = .cancelExit
        case 0x30:
            self = .start
        case 0x31:
            self = .skip
        case 0x32:
            let x = try container.decode(UInt32.self, forKey: CodingKeys.x)
            let y = try container.decode(UInt32.self, forKey: CodingKeys.y)
            let pieceType = try container.decode(UInt8.self, forKey: CodingKeys.pieceType)
            self = .moveOmok(x: x, y: y, pieceType: pieceType)
        case 0x33:
            self = .requestTie
        case 0x34:
            let type = try container.decode(UInt8.self, forKey: CodingKeys.answerType)
            self = .answerTie(type: type)
        case 0x35:
            self = .giveUp
        case 0x3E:
            let turn = try container.decode(UInt8.self, forKey: CodingKeys.turn)
            let slot = try container.decode(UInt8.self, forKey: CodingKeys.slot8u)
            self = .selectCard(turn: turn, slot: slot)
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown player interaction mode 0x\(String(mode, radix: 16))"))
        }
    }

    private enum CodingKeys: String, CodingKey {
        case description, targetID, objectID, message
        case inventoryType, slot, slot8, slot8u, quantity, targetSlot
        case amount, bundles, perBundle, price
        case x, y, pieceType, turn, answerType
    }
}
