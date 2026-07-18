//
//  AttributeCodable.swift
//
//
//  CoreModel AttributeCodable conformances for the value types used as
//  entity attributes. RawRepresentable types whose RawValue is itself
//  AttributeCodable (all Int/UInt widths and String) get their
//  implementation for free via CoreModel's constrained extensions, so we
//  only need to declare the conformance.
//

import Foundation
import CoreModel

// MARK: - RawRepresentable attribute value types

extension Region: AttributeCodable {}

extension Version: AttributeCodable {}

extension World.Ribbon: AttributeCodable {}

extension Channel.Status: AttributeCodable {}

extension MapleStoryAddress: AttributeCodable {}

extension Gender: AttributeCodable {}

extension SkinColor: AttributeCodable {}

extension Hair: AttributeCodable {}

extension Job: AttributeCodable {}

extension Experience: AttributeCodable {}

extension CharacterName: AttributeCodable {}

extension Username: AttributeCodable {}

extension Nonce: AttributeCodable {}

extension Map.ID: AttributeCodable {}

extension GuildRank: AttributeCodable {}

extension PartyMemberStatus: AttributeCodable {}

extension Configuration.Value: AttributeCodable {}

// MARK: - Storage items

/// `Storage.items` is declared as a `.string` attribute backed by a
/// `[Int8: InventoryItem]` dictionary, so it is serialized as JSON.
extension Dictionary: @retroactive AttributeCodable where Key == Int8, Value == InventoryItem {

    public init?(attributeValue: AttributeValue) {
        guard let string = String(attributeValue: attributeValue),
              let data = string.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = value
    }

    public var attributeValue: AttributeValue {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return .string("")
        }
        return .string(string)
    }
}
