//
//  WzModelTests.swift
//
//  Tests for WZ data-model parsers driven by hand-built XML fixtures.
//

import Foundation
import XCTest
@testable import MapleStory

final class WzModelTests: XCTestCase {

    private func parse(_ xml: String) throws -> WzNode {
        try WzXMLParser().parse(Data(xml.utf8))
    }

    private func writeTemp(_ xml: String, name: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("\(name).img.xml")
        try Data(xml.utf8).write(to: url)
        return url
    }

    // MARK: - WzNode accessors

    func testWzNodeAccessors() throws {
        let node = try parse("""
        <imgdir name="root">
            <int name="i" value="5"/>
            <short name="s" value="7"/>
            <float name="f" value="1.5"/>
            <double name="d" value="2.5"/>
            <string name="str" value="hi"/>
            <uol name="link" value="../other"/>
            <vector name="v" x="3" y="4"/>
            <sound name="snd"/>
            <null name="n"/>
        </imgdir>
        """)
        XCTAssertEqual(node["i"]?.intValue, 5)
        XCTAssertEqual(node["s"]?.intValue, 7)          // short widened
        XCTAssertEqual(node["f"]?.floatValue, 1.5)
        XCTAssertEqual(node["d"]?.doubleValue, 2.5)
        XCTAssertEqual(node["d"]?.floatValue, 2.5)      // double narrowed
        XCTAssertEqual(node["f"]?.doubleValue, 1.5)     // float widened
        XCTAssertEqual(node["str"]?.stringValue, "hi")
        XCTAssertEqual(node["link"]?.stringValue, "../other")
        XCTAssertEqual(node["v"]?.vectorX, 3)
        XCTAssertEqual(node["v"]?.vectorY, 4)

        // wrong-type accessors return nil
        XCTAssertNil(node["str"]?.intValue)
        XCTAssertNil(node["i"]?.floatValue)
        XCTAssertNil(node["i"]?.doubleValue)
        XCTAssertNil(node["i"]?.stringValue)
        XCTAssertNil(node["i"]?.vectorX)
        XCTAssertNil(node["i"]?.vectorY)

        // children of a leaf are empty
        XCTAssertTrue(node["i"]!.children.isEmpty)

        // path navigation
        XCTAssertEqual(node.child(at: "i")?.intValue, 5)
        XCTAssertEqual(node.child(at: "")?.name, "root")   // empty path -> self
        XCTAssertNil(node.child(at: "does/not/exist"))
        XCTAssertNil(node["missing"])
    }

    // MARK: - WzPhysics

    func testWzPhysics() throws {
        let node = try parse("""
        <imgdir name="root">
            <double name="walkForce" value="140000"/>
            <double name="walkSpeed" value="125"/>
            <double name="walkDrag" value="80000"/>
            <double name="slipForce" value="60000"/>
            <double name="slipSpeed" value="120"/>
            <double name="floatDrag1" value="100000"/>
            <double name="floatDrag2" value="10000"/>
            <double name="floatCoefficient" value="0.01"/>
            <double name="swimForce" value="120000"/>
            <double name="swimSpeed" value="140"/>
            <double name="flyForce" value="120000"/>
            <double name="flySpeed" value="200"/>
            <double name="gravityAcc" value="2000"/>
            <double name="fallSpeed" value="670"/>
            <double name="jumpSpeed" value="555"/>
            <double name="maxFriction" value="2"/>
            <double name="minFriction" value="0.05"/>
            <double name="swimSpeedDec" value="0.9"/>
        </imgdir>
        """)
        let physics = WzPhysics(node: node)
        XCTAssertEqual(physics, .default)
        XCTAssertEqual(physics.walkForce, 140000)
        XCTAssertEqual(physics.jumpSpeed, 555)
        XCTAssertEqual(physics.minFriction, 0.05)
    }

    func testWzPhysicsContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="root">
            <double name="walkSpeed" value="125"/>
        </imgdir>
        """, name: "Physics")
        defer { try? FileManager.default.removeItem(at: url) }
        let physics = try WzPhysics(contentsOf: url)
        XCTAssertEqual(physics.walkSpeed, 125)
        XCTAssertEqual(physics.walkForce, 0) // defaulted
    }

    // MARK: - WzStringTable

    func testWzStringTableFlat() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="100100">
                <string name="name" value="Snail"/>
                <string name="desc" value="A snail"/>
            </imgdir>
            <imgdir name="100101">
                <string name="name" value="Blue Snail"/>
            </imgdir>
            <imgdir name="empty">
                <string name="desc" value="no name here"/>
            </imgdir>
        </imgdir>
        """)
        let table = WzStringTable(node: node)
        XCTAssertEqual(table["100100"]?.name, "Snail")
        XCTAssertEqual(table["100100"]?.description, "A snail")
        XCTAssertEqual(table.name(for: "100101"), "Blue Snail")
        XCTAssertNil(table["empty"]) // no name -> skipped
        XCTAssertNil(table.name(for: "999999"))
    }

    func testWzStringTableNested() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="Eqp">
                <imgdir name="Accessory">
                    <imgdir name="1012000">
                        <string name="name" value="Ribbon"/>
                        <string name="desc" value="A ribbon"/>
                        <string name="func" value="cosmetic"/>
                    </imgdir>
                </imgdir>
            </imgdir>
        </imgdir>
        """)
        let table = WzStringTable(node: node)
        XCTAssertEqual(table["1012000"]?.name, "Ribbon")
        XCTAssertEqual(table["1012000"]?.extra["func"], "cosmetic")
    }

    func testWzStringTableContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="root">
            <imgdir name="2000">
                <string name="name" value="Potion"/>
            </imgdir>
        </imgdir>
        """, name: "Consume")
        defer { try? FileManager.default.removeItem(at: url) }
        let table = try WzStringTable(contentsOf: url)
        XCTAssertEqual(table.name(for: "2000"), "Potion")
    }

    // MARK: - WzNpc

    func testWzNpc() throws {
        let node = try parse("""
        <imgdir name="9000000">
            <imgdir name="info">
                <int name="dcLeft" value="-10"/>
                <int name="dcTop" value="-20"/>
                <int name="dcRight" value="30"/>
                <int name="dcBottom" value="40"/>
                <imgdir name="script">
                    <imgdir name="0">
                        <string name="script" value="hello"/>
                    </imgdir>
                    <imgdir name="1">
                        <string name="script" value="quest"/>
                    </imgdir>
                    <imgdir name="bad">
                        <string name="script" value="ignored"/>
                    </imgdir>
                </imgdir>
            </imgdir>
        </imgdir>
        """)
        let npc = try WzNpc(id: 9000000, node: node)
        XCTAssertEqual(npc.id, 9000000)
        XCTAssertEqual(npc.bounds.left, -10)
        XCTAssertEqual(npc.bounds.top, -20)
        XCTAssertEqual(npc.bounds.right, 30)
        XCTAssertEqual(npc.bounds.bottom, 40)
        XCTAssertEqual(npc.scripts[0], "hello")
        XCTAssertEqual(npc.scripts[1], "quest")
        XCTAssertNil(npc.scripts[2])
    }

    func testWzNpcContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="9010000">
            <imgdir name="info"/>
        </imgdir>
        """, name: "9010000")
        defer { try? FileManager.default.removeItem(at: url) }
        let npc = try WzNpc(contentsOf: url)
        XCTAssertEqual(npc.id, 9010000)
        XCTAssertEqual(npc.bounds.left, 0)
        XCTAssertTrue(npc.scripts.isEmpty)
    }

    func testWzNpcInvalidFilename() throws {
        let url = try writeTemp("<imgdir name=\"root\"/>", name: "notanumber")
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertThrowsError(try WzNpc(contentsOf: url))
    }

    // MARK: - WzItemConsume

    func testWzItemConsume() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="2000000">
                <imgdir name="info">
                    <int name="price" value="10"/>
                    <int name="slotMax" value="200"/>
                    <int name="cash" value="0"/>
                </imgdir>
                <imgdir name="spec">
                    <int name="hp" value="50"/>
                    <int name="mp" value="30"/>
                    <int name="hpRate" value="5"/>
                    <int name="mpRate" value="3"/>
                    <int name="time" value="60"/>
                    <int name="exp" value="0"/>
                    <int name="success" value="90"/>
                </imgdir>
            </imgdir>
        </imgdir>
        """)
        let items = try WzItemConsume.items(from: node)
        XCTAssertEqual(items.count, 1)
        let item = items[0]
        XCTAssertEqual(item.id, 2000000)
        XCTAssertEqual(item.price, 10)
        XCTAssertEqual(item.slotMax, 200)
        XCTAssertFalse(item.isCash)
        XCTAssertEqual(item.hp, 50)
        XCTAssertEqual(item.mp, 30)
        XCTAssertEqual(item.hpRate, 5)
        XCTAssertEqual(item.mpRate, 3)
        XCTAssertEqual(item.time, 60)
        XCTAssertEqual(item.chaosScrollSuccessRate, 90)
        XCTAssertEqual(item.nuffSkill, -1)  // default
        XCTAssertEqual(item.moveTo, -1)     // default
    }

    func testWzItemConsumeDefaults() throws {
        let node = try parse("""
        <imgdir name="item">
            <imgdir name="info"/>
        </imgdir>
        """)
        let item = try WzItemConsume(id: 2000001, node: node)
        XCTAssertEqual(item.slotMax, 100) // default
        XCTAssertEqual(item.hp, 0)
    }

    func testWzItemConsumeInvalidName() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="notnumeric">
                <imgdir name="info"/>
            </imgdir>
        </imgdir>
        """)
        XCTAssertThrowsError(try WzItemConsume.items(from: node))
    }

    func testWzItemConsumeContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="root">
            <imgdir name="2000002">
                <imgdir name="info">
                    <int name="price" value="7"/>
                </imgdir>
            </imgdir>
        </imgdir>
        """, name: "0200")
        defer { try? FileManager.default.removeItem(at: url) }
        let items = try WzItemConsume.items(contentsOf: url)
        XCTAssertEqual(items.first?.price, 7)
    }

    // MARK: - WzSkill

    func testWzSkillBook() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="skill">
                <imgdir name="1000">
                    <imgdir name="level">
                        <imgdir name="1">
                            <int name="hp" value="10"/>
                            <int name="mp" value="20"/>
                            <int name="x" value="1"/>
                            <int name="y" value="2"/>
                            <int name="z" value="3"/>
                            <int name="w" value="4"/>
                            <int name="damage" value="150"/>
                            <int name="mastery" value="60"/>
                            <int name="attackCount" value="2"/>
                            <int name="bulletCount" value="1"/>
                            <int name="mobCount" value="6"/>
                            <int name="time" value="30"/>
                            <int name="jump" value="5"/>
                            <int name="speed" value="10"/>
                            <int name="prop" value="80"/>
                            <vector name="lt" x="-100" y="-50"/>
                            <vector name="rb" x="100" y="50"/>
                        </imgdir>
                        <imgdir name="notanumber"/>
                    </imgdir>
                </imgdir>
                <imgdir name="badId"/>
            </imgdir>
        </imgdir>
        """)
        let book = try WzSkillBook(node: node)
        let skill = try XCTUnwrap(book.skills[1000])
        XCTAssertEqual(skill.id, 1000)
        XCTAssertEqual(skill.maxLevel, 1)
        let level = try XCTUnwrap(skill.levels[1])
        XCTAssertEqual(level.hpCost, 10)
        XCTAssertEqual(level.mpCost, 20)
        XCTAssertEqual(level.x, 1)
        XCTAssertEqual(level.damage, 150)
        XCTAssertEqual(level.mastery, 60)
        XCTAssertEqual(level.attackCount, 2)
        XCTAssertEqual(level.mobCount, 6)
        XCTAssertEqual(level.prop, 80)
        XCTAssertEqual(level.ltX, -100)
        XCTAssertEqual(level.ltY, -50)
        XCTAssertEqual(level.rbX, 100)
        XCTAssertEqual(level.rbY, 50)
    }

    func testWzSkillBookMissingSkill() throws {
        let node = try parse("<imgdir name=\"root\"/>")
        XCTAssertThrowsError(try WzSkillBook(node: node))
    }

    func testWzSkillNoLevels() throws {
        let node = try parse("<imgdir name=\"1000\"/>")
        let skill = try WzSkill(id: 1000, node: node)
        XCTAssertEqual(skill.maxLevel, 0)
    }

    func testWzSkillBookContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="root">
            <imgdir name="skill">
                <imgdir name="2000">
                    <imgdir name="level">
                        <imgdir name="1">
                            <int name="mp" value="15"/>
                        </imgdir>
                    </imgdir>
                </imgdir>
            </imgdir>
        </imgdir>
        """, name: "Magician")
        defer { try? FileManager.default.removeItem(at: url) }
        let book = try WzSkillBook(contentsOf: url)
        XCTAssertEqual(book.skills[2000]?.levels[1]?.mpCost, 15)
    }

    // MARK: - WzMap

    func testWzMap() throws {
        let node = try parse("""
        <imgdir name="100000000">
            <imgdir name="info">
                <int name="returnMap" value="100000000"/>
                <int name="forcedReturn" value="999999999"/>
                <float name="mobRate" value="2.0"/>
                <string name="bgm" value="Bgm00/GoPicnic"/>
                <string name="mapMark" value="Henesys"/>
                <int name="town" value="1"/>
                <int name="cloud" value="0"/>
                <int name="hideMinimap" value="0"/>
                <int name="moveLimit" value="0"/>
                <int name="fieldType" value="0"/>
            </imgdir>
            <imgdir name="portal">
                <imgdir name="0">
                    <string name="pn" value="sp"/>
                    <int name="pt" value="0"/>
                    <int name="x" value="10"/>
                    <int name="y" value="20"/>
                    <int name="tm" value="999999999"/>
                    <string name="tn" value=""/>
                </imgdir>
                <imgdir name="1">
                    <string name="pn" value="west00"/>
                    <int name="pt" value="2"/>
                    <int name="x" value="-100"/>
                    <int name="y" value="0"/>
                    <int name="tm" value="100000001"/>
                    <string name="tn" value="east00"/>
                </imgdir>
                <imgdir name="incomplete">
                    <string name="pn" value="broken"/>
                </imgdir>
            </imgdir>
            <imgdir name="foothold">
                <imgdir name="0">
                    <imgdir name="1">
                        <imgdir name="1">
                            <int name="x1" value="0"/>
                            <int name="y1" value="100"/>
                            <int name="x2" value="200"/>
                            <int name="y2" value="100"/>
                            <int name="prev" value="0"/>
                            <int name="next" value="2"/>
                        </imgdir>
                        <imgdir name="bad"/>
                    </imgdir>
                </imgdir>
            </imgdir>
            <imgdir name="life">
                <imgdir name="0">
                    <string name="type" value="n"/>
                    <string name="id" value="9000000"/>
                    <int name="x" value="50"/>
                    <int name="y" value="100"/>
                    <int name="fh" value="1"/>
                    <int name="cy" value="100"/>
                    <int name="rx0" value="40"/>
                    <int name="rx1" value="60"/>
                    <int name="f" value="0"/>
                    <int name="hide" value="0"/>
                </imgdir>
                <imgdir name="1">
                    <string name="type" value="m"/>
                    <string name="id" value="100100"/>
                    <int name="x" value="70"/>
                    <int name="y" value="100"/>
                    <int name="fh" value="1"/>
                    <int name="cy" value="100"/>
                    <int name="rx0" value="60"/>
                    <int name="rx1" value="80"/>
                    <int name="mobTime" value="30"/>
                    <int name="f" value="1"/>
                    <int name="hide" value="0"/>
                </imgdir>
                <imgdir name="invalid">
                    <string name="type" value="x"/>
                    <string name="id" value="1"/>
                </imgdir>
            </imgdir>
        </imgdir>
        """)
        let map = try WzMap(id: 100000000, node: node)
        XCTAssertEqual(map.id, 100000000)
        XCTAssertEqual(map.info.returnMap, 100000000)
        XCTAssertEqual(map.info.forcedReturn, 999999999)
        XCTAssertEqual(map.info.mobRate, 2.0)
        XCTAssertEqual(map.info.bgm, "Bgm00/GoPicnic")
        XCTAssertEqual(map.info.mapMark, "Henesys")
        XCTAssertTrue(map.info.isTown)
        XCTAssertFalse(map.info.cloud)

        XCTAssertEqual(map.portals.count, 2) // incomplete skipped
        XCTAssertEqual(map.portals[0].name, "sp")
        XCTAssertEqual(map.portals[1].targetMap, 100000001)
        XCTAssertEqual(map.portals[1].targetName, "east00")

        XCTAssertEqual(map.footholds.count, 1)
        XCTAssertEqual(map.footholds[0].id, 1)
        XCTAssertEqual(map.footholds[0].x2, 200)
        XCTAssertEqual(map.footholds[0].next, 2)

        XCTAssertEqual(map.life.count, 2) // invalid type skipped
        XCTAssertEqual(map.life[0].type, .npc)
        XCTAssertEqual(map.life[0].id, "9000000")
        XCTAssertEqual(map.life[1].type, .mob)
        XCTAssertEqual(map.life[1].mobTime, 30)
        XCTAssertEqual(map.life[1].facing, 1)
    }

    func testWzMapMissingInfo() throws {
        let node = try parse("<imgdir name=\"100\"/>")
        XCTAssertThrowsError(try WzMap(id: 100, node: node))
    }

    func testWzMapContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="200000000">
            <imgdir name="info"/>
        </imgdir>
        """, name: "200000000")
        defer { try? FileManager.default.removeItem(at: url) }
        let map = try WzMap(contentsOf: url)
        XCTAssertEqual(map.id, 200000000)
        XCTAssertEqual(map.info.mobRate, 1.0) // default
        XCTAssertTrue(map.portals.isEmpty)
    }

    func testWzMapInvalidFilename() throws {
        let url = try writeTemp("<imgdir name=\"x\"><imgdir name=\"info\"/></imgdir>", name: "notanumber2")
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertThrowsError(try WzMap(contentsOf: url))
    }

    // MARK: - WzItemEquip

    func testWzItemEquip() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="100000000">
                <imgdir name="info">
                    <int name="price" value="100"/>
                    <int name="cash" value="0"/>
                    <string name="name" value="Cap"/>
                    <string name="desc" value="A cap"/>
                    <int name="reqLevel" value="10"/>
                    <int name="reqSTR" value="5"/>
                    <int name="reqDEX" value="0"/>
                    <int name="reqJob" value="1"/>
                    <int name="incSTR" value="3"/>
                    <int name="incPAD" value="7"/>
                    <int name="incMHP" value="50"/>
                    <int name="tuc" value="7"/>
                </imgdir>
            </imgdir>
        </imgdir>
        """)
        let items = try WzItemEquip.items(from: node)
        XCTAssertEqual(items.count, 1)
        let item = items[0]
        XCTAssertEqual(item.id, 100000000)
        XCTAssertEqual(item.price, 100)
        XCTAssertEqual(item.slotMax, 1) // default
        XCTAssertFalse(item.isCash)
        XCTAssertEqual(item.name, "Cap")
        XCTAssertEqual(item.description, "A cap")
        XCTAssertEqual(item.type, .hat)
        XCTAssertEqual(item.requiredLevel, 10)
        XCTAssertEqual(item.requiredStr, 5)
        XCTAssertEqual(item.job, 1)
        XCTAssertEqual(item.str, 3)
        XCTAssertEqual(item.weaponAttack, 7)
        XCTAssertEqual(item.hp, 50)
        XCTAssertEqual(item.slots, 7)
    }

    func testWzItemEquipDesignatedInit() {
        let item = WzItemEquip(
            id: 1, price: 0, slotMax: 1, isCash: false, name: nil, description: nil,
            type: .unknown, job: 0, requiredLevel: 0, requiredStr: 0, requiredDex: 0,
            requiredInt: 0, requiredLuk: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0,
            weaponAttack: 0, magicAttack: 0, weaponDefense: 0, magicDefense: 0,
            accuracy: 0, avoid: 0, speed: 0, jump: 0, slots: 0, upgradeSlots: 0, scrollSuccesses: 0
        )
        XCTAssertEqual(item.id, 1)
        XCTAssertNil(item.name)
        XCTAssertEqual(item.type, .unknown)
    }

    func testWzItemEquipTypeMapping() throws {
        func type(_ id: UInt32) throws -> WzItemEquip.EquipType {
            let node = try parse("<imgdir name=\"item\"><imgdir name=\"info\"/></imgdir>")
            return try WzItemEquip(id: id, node: node).type
        }
        XCTAssertEqual(try type(10000000), .faceAccessory)
        XCTAssertEqual(try type(10200000), .eyeAccessory)
        XCTAssertEqual(try type(10300000), .earring)
        XCTAssertEqual(try type(11200000), .pendant)
        XCTAssertEqual(try type(11100000), .ring)
        XCTAssertEqual(try type(11600000), .pocket)
        XCTAssertEqual(try type(100000000), .hat)
        XCTAssertEqual(try type(104000000), .coat)
        XCTAssertEqual(try type(106000000), .pants)
        XCTAssertEqual(try type(105000000), .longcoat)
        XCTAssertEqual(try type(107000000), .shoes)
        XCTAssertEqual(try type(108000000), .gloves)
        XCTAssertEqual(try type(110000000), .cape)
        XCTAssertEqual(try type(109000000), .shield)
        XCTAssertEqual(try type(121000000), .weapon)
        XCTAssertEqual(try type(122000000), .weapon)
        XCTAssertEqual(try type(1140000000), .medal)
        XCTAssertEqual(try type(999999), .unknown)
    }

    func testWzItemEquipInvalidName() throws {
        let node = try parse("""
        <imgdir name="root">
            <imgdir name="notnumeric">
                <imgdir name="info"/>
            </imgdir>
        </imgdir>
        """)
        XCTAssertThrowsError(try WzItemEquip.items(from: node))
    }

    func testWzItemEquipContentsOf() throws {
        let url = try writeTemp("""
        <imgdir name="root">
            <imgdir name="100000001">
                <imgdir name="info">
                    <int name="price" value="42"/>
                </imgdir>
            </imgdir>
        </imgdir>
        """, name: "0100")
        defer { try? FileManager.default.removeItem(at: url) }
        let items = try WzItemEquip.items(contentsOf: url)
        XCTAssertEqual(items.first?.price, 42)
        XCTAssertEqual(items.first?.type, .hat)
    }

    // MARK: - Parser errors

    func testParserErrors() {
        // empty document
        XCTAssertThrowsError(try parse(""))
        // unexpected element
        XCTAssertThrowsError(try parse("<imgdir name=\"root\"><bogus name=\"x\"/></imgdir>"))
        // invalid int value
        XCTAssertThrowsError(try parse("<imgdir name=\"root\"><int name=\"x\" value=\"abc\"/></imgdir>"))
        // missing required attribute
        XCTAssertThrowsError(try parse("<imgdir name=\"root\"><int name=\"x\"/></imgdir>"))
    }
}
