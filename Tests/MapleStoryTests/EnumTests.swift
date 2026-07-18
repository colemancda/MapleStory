//
//  EnumTests.swift
//
//  Tests for enumerations and option-set / raw-representable value types.
//

import Foundation
import XCTest
@testable import MapleStory

final class EnumTests: XCTestCase {

    func testJobClass() {
        // every job maps to a valid class
        for job in Job.allCases {
            let type = job.type
            XCTAssertEqual(UInt8(job.rawValue / 100), type.rawValue)
        }
        XCTAssertEqual(Job.evan10.type, .evan)
        XCTAssertEqual(Job.aran4.type, .aran)
        XCTAssertEqual(Job.legend.type, .legend)
        XCTAssertEqual(Job.noblesse.type, .noblesse)
        XCTAssertEqual(Job.mapleLeafBrigadier.type, .mapleLeaf)
    }

    func testJobRoundTrip() {
        for job in Job.allCases {
            XCTAssertEqual(Job(rawValue: job.rawValue), job)
        }
        XCTAssertNil(Job(rawValue: 99))
    }

    func testClassByte5Encoding() {
        XCTAssertEqual(Class(byte5Encoding: 2), .warrior)
        XCTAssertEqual(Class(byte5Encoding: 4), .magician)
        XCTAssertEqual(Class(byte5Encoding: 8), .bowman)
        XCTAssertEqual(Class(byte5Encoding: 16), .thief)
        XCTAssertEqual(Class(byte5Encoding: 32), .pirate)
        XCTAssertEqual(Class(byte5Encoding: 1024), .noblesse)
        XCTAssertEqual(Class(byte5Encoding: 2048), .dawnWarrior)
        XCTAssertEqual(Class(byte5Encoding: 4096), .blazeWizard)
        XCTAssertEqual(Class(byte5Encoding: 8192), .windArcher)
        XCTAssertEqual(Class(byte5Encoding: 16384), .nightWalker)
        XCTAssertEqual(Class(byte5Encoding: 32768), .thunderBreaker)
        XCTAssertEqual(Class(byte5Encoding: 0), .beginner)
        XCTAssertEqual(Class(byte5Encoding: 123456), .beginner)
    }

    func testClassCompatibility() {
        XCTAssertTrue(Class.beginner.isCompatible(for: .v62))
        XCTAssertFalse(Class.pirate.isCompatible(for: 61))
        XCTAssertTrue(Class.pirate.isCompatible(for: .v62))
        XCTAssertFalse(Class.noblesse.isCompatible(for: .v62))
        XCTAssertTrue(Class.noblesse.isCompatible(for: .v73))
        XCTAssertFalse(Class.legend.isCompatible(for: .v73))
        XCTAssertTrue(Class.legend.isCompatible(for: .v80))
        XCTAssertFalse(Class.evan.isCompatible(for: .v80))
        XCTAssertTrue(Class.evan.isCompatible(for: .v83))
        XCTAssertTrue(Class.warrior.isCompatible(for: 1))
        XCTAssertTrue(Class.magician.isCompatible(for: 1))
        XCTAssertTrue(Class.bowman.isCompatible(for: 1))
        XCTAssertTrue(Class.thief.isCompatible(for: 1))
        XCTAssertTrue(Class.mapleLeaf.isCompatible(for: 1))
        XCTAssertTrue(Class.gm.isCompatible(for: 1))
        XCTAssertTrue(Class.aran.isCompatible(for: .v80))
        XCTAssertTrue(Class.dawnWarrior.isCompatible(for: .v73))
        XCTAssertTrue(Class.blazeWizard.isCompatible(for: .v73))
        XCTAssertTrue(Class.windArcher.isCompatible(for: .v73))
        XCTAssertTrue(Class.nightWalker.isCompatible(for: .v73))
        XCTAssertTrue(Class.thunderBreaker.isCompatible(for: .v73))
    }

    func testSimpleRawEnums() {
        XCTAssertEqual(Gender.male.rawValue, 0)
        XCTAssertEqual(Gender.female.rawValue, 1)
        XCTAssertEqual(Gender.allCases.count, 2)
        XCTAssertEqual(Gender(rawValue: 1), .female)

        XCTAssertEqual(SkinColor.normal.rawValue, 0)
        XCTAssertEqual(SkinColor.pink.rawValue, 10)
        XCTAssertEqual(SkinColor(rawValue: 9), .white)
        XCTAssertEqual(SkinColor.allCases.count, 8)

        XCTAssertEqual(Hair.Color.black.rawValue, 0)
        XCTAssertEqual(Hair.Color.brown.rawValue, 7)
        XCTAssertEqual(Hair.Color.allCases.count, 8)

        XCTAssertEqual(Channel.Status.normal.rawValue, 0)
        XCTAssertEqual(Channel.Status.full.rawValue, 2)
        XCTAssertEqual(Channel.Status.allCases.count, 3)

        XCTAssertEqual(World.Ribbon.normal.rawValue, 0)
        XCTAssertEqual(World.Ribbon.hot.rawValue, 3)
        XCTAssertEqual(World.Ribbon.allCases.count, 4)

        XCTAssertEqual(PinCodeStatus.success.rawValue, 0)
        XCTAssertEqual(PinCodeStatus.enterPin.rawValue, 4)
        XCTAssertEqual(PinCodeStatus.allCases.count, 5)

        XCTAssertEqual(PicCodeStatus.register.rawValue, 0)
        XCTAssertEqual(PicCodeStatus.disabled.rawValue, 2)
        XCTAssertEqual(PicCodeStatus.allCases.count, 3)

        XCTAssertEqual(ServerMessageType.notice.rawValue, 0)
        XCTAssertEqual(ServerMessageType.lightBlueText.rawValue, 6)
        XCTAssertEqual(ServerMessageType.allCases.count, 7)

        XCTAssertEqual(NPCTalkType.dialog.rawValue, 0)
        XCTAssertEqual(NPCTalkType.accept.rawValue, 0x0C)
        XCTAssertEqual(NPCTalkType.allCases.count, 7)

        XCTAssertEqual(WorldSelectionMode.showPrompt.rawValue, 0)
        XCTAssertEqual(WorldSelectionMode.skipPrompt.rawValue, 1)
        XCTAssertEqual(WorldSelectionMode.allCases.count, 2)
    }

    func testLoginError() {
        XCTAssertEqual(LoginError.invalidUsername.rawValue, 3)
        XCTAssertEqual(LoginError.fullClientNotice.rawValue, 27)
        XCTAssertNil(LoginError(rawValue: 0))
        for error in LoginError.allCases {
            XCTAssertEqual(LoginError(rawValue: error.rawValue), error)
        }
    }

    func testMapleStoryError() {
        // exercise all cases for coverage of the enum declaration
        let errors: [MapleStoryError] = [
            .invalidAddress("x"),
            .disconnected(.loginServerDefault),
            .invalidData(Data([0x01])),
            .notAuthenticated,
            .unknownUser("bob"),
            .sessionExpired,
            .internalServerError,
            .invalidWorld,
            .invalidChannel,
            .invalidCharacter,
            .invalidRequest,
            .banned,
            .login(.invalidPassword),
            .clientStartup("boom"),
            .invalidBirthday,
            .invalidPinCode,
            .invalidPicCode
        ]
        XCTAssertEqual(errors.count, 17)
        // ensure they are throwable / representable
        for error in errors {
            XCTAssertNotNil(error.localizedDescription)
        }
    }

    func testMapleStat() {
        XCTAssertEqual(MapleStat.skin.rawValue, 0x1)
        XCTAssertEqual(MapleStat.face.rawValue, 0x2)
        XCTAssertEqual(MapleStat.hair.rawValue, 0x4)
        XCTAssertEqual(MapleStat.level.rawValue, 0x10)
        XCTAssertEqual(MapleStat.job.rawValue, 0x20)
        XCTAssertEqual(MapleStat.str.rawValue, 0x40)
        XCTAssertEqual(MapleStat.dex.rawValue, 0x80)
        XCTAssertEqual(MapleStat.int.rawValue, 0x100)
        XCTAssertEqual(MapleStat.luk.rawValue, 0x200)
        XCTAssertEqual(MapleStat.hp.rawValue, 0x400)
        XCTAssertEqual(MapleStat.maxHP.rawValue, 0x800)
        XCTAssertEqual(MapleStat.mp.rawValue, 0x1000)
        XCTAssertEqual(MapleStat.maxMP.rawValue, 0x2000)
        XCTAssertEqual(MapleStat.availableAP.rawValue, 0x4000)
        XCTAssertEqual(MapleStat.availableSP.rawValue, 0x8000)
        XCTAssertEqual(MapleStat.exp.rawValue, 0x10000)
        XCTAssertEqual(MapleStat.fame.rawValue, 0x20000)
        XCTAssertEqual(MapleStat.meso.rawValue, 0x40000)
        XCTAssertEqual(MapleStat.pet.rawValue, 0x180008)
        XCTAssertEqual(MapleStat.gachaExp.rawValue, 0x200000)

        // OptionSet behavior
        let combined: MapleStat = [.str, .dex, .int, .luk]
        XCTAssertTrue(combined.contains(.str))
        XCTAssertTrue(combined.contains(.luk))
        XCTAssertFalse(combined.contains(.hp))
        XCTAssertEqual(combined.rawValue, 0x40 | 0x80 | 0x100 | 0x200)

        XCTAssertEqual(MapleStat(byte5Encoding: 64), .str)
        XCTAssertEqual(MapleStat(byte5Encoding: 128), .dex)
        XCTAssertEqual(MapleStat(byte5Encoding: 256), .int)
        XCTAssertEqual(MapleStat(byte5Encoding: 512), .luk)
        XCTAssertNil(MapleStat(byte5Encoding: 1))
    }

    func testNPCTalkDialogButtons() {
        XCTAssertEqual(NPCTalkDialogButtons.next.rawValue, 0x0100)
        XCTAssertEqual(NPCTalkDialogButtons.previous.rawValue, 0x0001)
        let both: NPCTalkDialogButtons = [.next, .previous]
        XCTAssertTrue(both.contains(.next))
        XCTAssertTrue(both.contains(.previous))
    }

    func testExperience() {
        let exp: Experience = 100
        XCTAssertEqual(exp.rawValue, 100)
        XCTAssertEqual(exp.description, "100")
        XCTAssertEqual(exp.debugDescription, "100")
        XCTAssertEqual(Experience(rawValue: 5).rawValue, 5)
        XCTAssertFalse(Experience.advancements.isEmpty)
        // first beginner advancement value
        XCTAssertEqual(Experience.advancements.first, 15)
    }

    func testRegion() {
        let region: Region = 8
        XCTAssertEqual(region.rawValue, 8)
        XCTAssertEqual(Region.global.rawValue, 0x08)
        XCTAssertEqual(region.description, "8")
        XCTAssertEqual(region.debugDescription, "8")
        XCTAssertEqual(Region(rawValue: 3).rawValue, 3)
    }

    func testHair() {
        let hair: Hair = 30000
        XCTAssertEqual(hair.rawValue, 30000)
        XCTAssertEqual(hair.description, "30000")
        XCTAssertEqual(hair.debugDescription, "30000")
        XCTAssertEqual(Hair.toben(.black).rawValue, 30000)
        XCTAssertEqual(Hair.rebel(.red).rawValue, 30021)
        XCTAssertEqual(Hair.buzz(.black).rawValue, 30030)
        XCTAssertEqual(Hair.rockstar(.orange).rawValue, 30042)
        XCTAssertEqual(Hair.metro(.black).rawValue, 30050)
        XCTAssertEqual(Hair.catalyst(.blue).rawValue, 30065)
    }

    func testVersion() {
        let v: Version = 62
        XCTAssertEqual(v.rawValue, 62)
        XCTAssertEqual(v, .v62)
        XCTAssertEqual(v.description, "62")
        XCTAssertEqual(v.debugDescription, "62")
        XCTAssertTrue(Version.v14 < Version.v28)
        XCTAssertTrue(Version.v93 > Version.v83)
        XCTAssertFalse(Version.v62 < Version.v40)
        XCTAssertEqual(Version.v40.rawValue, 40)
        XCTAssertEqual(Version.v49.rawValue, 49)
        XCTAssertEqual(Version.v55.rawValue, 55)
        XCTAssertEqual(Version.v84.rawValue, 84)
        XCTAssertEqual(Version(rawValue: 100).rawValue, 100)
    }

    func testWorldName() {
        XCTAssertEqual(World.Name.scania.index, 0)
        XCTAssertEqual(World.Name.bera.index, 1)
        XCTAssertNil(World.Name(index: 99))
        for name in World.Name.allCases {
            XCTAssertEqual(World.Name(index: name.index), name)
        }
        // version introduced
        XCTAssertEqual(World.Name.scania.version, 1)
        XCTAssertEqual(World.Name.bera.version, 2)
        XCTAssertEqual(World.Name.broa.version, 7)
        XCTAssertEqual(World.Name.windia.version, .v14)
        XCTAssertEqual(World.Name.khaini.version, 18)
        XCTAssertEqual(World.Name.bellocan.version, .v28)
        XCTAssertEqual(World.Name.mardia.version, 35)
        XCTAssertEqual(World.Name.kradia.version, 44)
        XCTAssertEqual(World.Name.yellonde.version, 59)
        XCTAssertEqual(World.Name.demethos.version, .v62)
        XCTAssertEqual(World.Name.galicia.version, .v80)
        XCTAssertEqual(World.Name.elnido.version, .v93)
        XCTAssertEqual(World.Name.zenith.version, .v93)
        XCTAssertEqual(World.Name.chaos.version, 94)
        XCTAssertTrue(World.Name.scania.isCompatible(for: .v62))
        XCTAssertFalse(World.Name.demethos.isCompatible(for: 61))
        XCTAssertTrue(World.Name.demethos.isCompatible(for: .v62))
    }
}
