//
//  CreateCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles new character creation requests.
///
/// # Character Creation Rules
///
/// ## Stat Distribution
/// - All stats (STR, DEX, INT, LUK) must be at least 4
/// - Total stat points must equal exactly 25
/// - These are beginner character requirements
///
/// ## Equipment Validation
///
/// ### Gender-Specific Equipment
/// - **Male** (gender 0):
///   - Bottom: 1060006, 1060002
///   - Top: 1040002, 1040006, 1040010
///   - Face: 20000, 20001, 20002
///   - Hair: 30000, 30020, 30030
/// - **Female** (gender 1):
///   - Bottom: 1061002, 1061008
///   - Top: 1041002, 1041006, 1041010, 1041011
///   - Face: 21000, 21001, 21002
///   - Hair: 31000, 31040, 31050
///
/// ### Universal Requirements
/// - Hair Color: 0, 2, 3, or 7
/// - Shoes: 1072001, 1072005, 1072037, 1072038
/// - Weapon: 1302000, 1322005, 1312004
/// - Skin Color: 0-3
///
/// # Creation Process
///
/// 1. Validate all character data
/// 2. Check name availability and formatting
/// 3. Validate equipment combinations
/// 4. Create character with beginner job
/// 5. Equip starting items
/// 6. Give starting ETC item (Relic - 4161001)
/// 7. Save to database
/// 8. Send response to client
///
/// # Starting Equipment
///
/// All characters start with:
/// - Top (shirt)
/// - Bottom (pants/skirt)
/// - Shoes
/// - Weapon
/// - ETC slot: Relic (1 quantity)
///
/// # GM Characters
///
/// If account is GM, character inherits GM level.
public struct CreateCharacterHandler: PacketHandler {

    public typealias Packet = MapleStory62.CreateCharacterRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await createCharacter(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension CreateCharacterHandler {

    func createCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.CreateCharacterRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.CreateCharacterResponse {
        guard let name = CharacterName(rawValue: request.name),
            let skinColor = SkinColor(rawValue: numericCast(request.skinColor)) else {
            throw MapleStoryError.invalidRequest
        }
        let values = Character.CreationValues(
            name: name,
            face: request.face,
            hair: .init(rawValue: request.hair + request.hairColor),
            skinColor: skinColor,
            top: request.top,
            bottom: request.bottom,
            shoes: request.shoes,
            weapon: request.weapon,
            gender: request.gender,
            str: numericCast(request.str),
            dex: numericCast(request.dex),
            int: numericCast(request.int),
            luk: numericCast(request.luk),
            job: .beginner
        )
        let character = try await connection.createCharacter(values)
        return .init(character: .init(character))
    }
}
