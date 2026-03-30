//
//  Connection+Inventory.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer
import MapleStoryServer62

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    // MARK: - Item Data

    func consumeItemData(id: UInt32) async -> WzItemConsume? {
        await ItemDataCache.shared.consume(id: id)
    }

    func scrollData(id: UInt32) async -> ScrollData? {
        await ScrollDataCache.shared.scroll(id)
    }

    func skillBookData(id: UInt32) async -> SkillBookData? {
        await SkillBookDataCache.shared.skillBook(id)
    }

    func summonBagData(id: UInt32) async -> SummonBagData? {
        await SummonBagDataCache.shared.data(for: id)
    }
}
