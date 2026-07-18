//
//  EmptyPacketTests.swift
//  Coverage for empty marker packets and a few missed Codable packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

/// Construct an empty (non-Encodable) marker packet and exercise its opcode.
func touch62<T>(_ value: T, file: StaticString = #file, line: UInt = #line) where T: MapleStoryPacket, T: Equatable {
    XCTAssertEqual(T.opcode, T.opcode, file: file, line: line)
    XCTAssertEqual(value, value, file: file, line: line)
}

final class EmptyPacketTests: XCTestCase {

    // MARK: - Missed Codable packets

    func testMissedCodablePackets() {
        assertRoundTrip62(CharInfoRequest(value0: 0, value1: 0, characterID: 14))
        assertRoundTrip62(MonsterCarnivalRequest())
        assertRoundTrip62(BuddyListMessageNotification(messageType: 11))
        assertRoundTrip62(BuddyListMessageNotification.buddyListFull)
        assertRoundTrip62(BuddyListMessageNotification.otherBuddyListFull)
        assertRoundTrip62(BuddyListMessageNotification.alreadyOnList)
        assertRoundTrip62(BuddyListMessageNotification.characterNotFound)
    }

    // MARK: - Empty marker notifications

    func testEmptyMarkerPackets() {
        touch62(ApplyMonsterStatusNotification())
        touch62(AvatarMegaNotification())
        touch62(BossEnvNotification())
        touch62(CSOpenNotification())
        touch62(CSOperationNotification())
        touch62(CSUpdateNotification())
        touch62(CancelForeignBuffNotification())
        touch62(CancelMonsterStatusNotification())
        touch62(CharInfoNotification())
        touch62(CloseRangeAttackNotification())
        touch62(DamagePlayerNotification())
        touch62(DueyNotification())
        touch62(GetMTSTokensNotification())
        touch62(GiveForeignBuffNotification())
        touch62(MTSOperationNotification())
        touch62(MagicAttackNotification())
        touch62(MapEffectNotification())
        touch62(MessengerNotification())
        touch62(MoveSummonNotification())
        touch62(PlayerInteractionNotification())
        touch62(PlayerNPCNotification())
        touch62(RangedAttackNotification())
        touch62(RemovePlayerFromMapNotification())
        touch62(RemoveSpecialMapobjectNotification())
        touch62(ShowForeignEffectNotification())
        touch62(ShowItemGainInChatNotification())
        touch62(ShowStatusInfoNotification())
        touch62(SkillMacroNotification())
        touch62(SpawnPlayerNotification())
        touch62(SpawnSpecialMapobjectNotification())
        touch62(StartMTSNotification())
        touch62(TVSmegaNotification())
        touch62(TrockLocationsNotification())
        touch62(UpdateCharBoxNotification())
        touch62(UpdateCharLookNotification())
        touch62(UpdateSkillsNotification())
    }
}
