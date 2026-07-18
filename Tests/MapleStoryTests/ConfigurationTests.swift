//
//  ConfigurationTests.swift
//
//  Tests for Configuration value/key types and computed properties.
//

import Foundation
import XCTest
@testable import MapleStory

final class ConfigurationTests: XCTestCase {

    func testValueBool() {
        XCTAssertEqual(Configuration.Value(bool: true).rawValue, "1")
        XCTAssertEqual(Configuration.Value(bool: false).rawValue, "0")
        XCTAssertEqual(Configuration.Value(rawValue: "1").boolValue, true)
        XCTAssertEqual(Configuration.Value(rawValue: "0").boolValue, false)
        XCTAssertNil(Configuration.Value(rawValue: "abc").boolValue)
        let literal: Configuration.Value = true
        XCTAssertEqual(literal.rawValue, "1")
    }

    func testValueInteger() {
        XCTAssertEqual(Configuration.Value(integer: 42).rawValue, "42")
        XCTAssertEqual(Configuration.Value(rawValue: "99").intValue, 99)
        XCTAssertNil(Configuration.Value(rawValue: "notanumber").intValue)
        let literal: Configuration.Value = 7
        XCTAssertEqual(literal.rawValue, "7")
        XCTAssertEqual(literal.intValue, 7)
    }

    func testValueStringLiteralAndDescription() {
        let value: Configuration.Value = "hello"
        XCTAssertEqual(value.rawValue, "hello")
        XCTAssertEqual(value.description, "hello")
        XCTAssertEqual(value.debugDescription, "hello")
    }

    func testKey() {
        let key: Configuration.Key = "myKey"
        XCTAssertEqual(key.rawValue, "myKey")
        XCTAssertEqual(key.description, "myKey")
        XCTAssertEqual(key.debugDescription, "myKey")
        XCTAssertEqual(Configuration.Key.lastUserIndex.rawValue, "lastUserIndex")
        XCTAssertEqual(Configuration.Key.website.rawValue, "website")
        XCTAssertEqual(Configuration.Key.pinEnabled.rawValue, "pinEnabled")
        XCTAssertEqual(Configuration.Key.picEnabled.rawValue, "picEnabled")
        XCTAssertEqual(Configuration.Key.autoRegister.rawValue, "autoregister")
        XCTAssertEqual(Configuration.Key.worldSelection.rawValue, "worldSelection")
        XCTAssertEqual(Configuration.Key.restrictSessionIP.rawValue, "restrictSessionIP")
        XCTAssertEqual(Configuration.Key.loginExpiration.rawValue, "loginExpiration")
    }

    func testDefaultConfiguration() {
        let config = Configuration.default
        XCTAssertFalse(config.isEmpty)
        XCTAssertEqual(config.website, URL(string: "https://github.com/ColemanCDA/MapleStory"))
        XCTAssertEqual(config.isPinEnabled, false)
        XCTAssertEqual(config.isPicEnabled, false)
        XCTAssertEqual(config.isAutoRegisterEnabled, true)
        XCTAssertEqual(config.worldSelection, .skipPrompt)
        XCTAssertEqual(config.restrictSessionIP, true)
        XCTAssertEqual(config.loginExpiration, 30)
    }

    func testDictionaryLiteralAndSubscript() {
        var config: Configuration = [
            .lastUserIndex: .init(integer: 5),
            .pinEnabled: true
        ]
        XCTAssertEqual(config.count, 2)
        XCTAssertEqual(config[.lastUserIndex]?.intValue, 5)
        XCTAssertEqual(config.lastUserIndex, 5)
        XCTAssertEqual(config.isPinEnabled, true)

        // mutate via subscript
        config[.pinEnabled] = false
        XCTAssertEqual(config.isPinEnabled, false)
        config[.pinEnabled] = nil
        XCTAssertNil(config[.pinEnabled])
    }

    func testCollectionConformance() {
        let config: Configuration = [
            .website: "https://example.com",
            .loginExpiration: 60
        ]
        XCTAssertEqual(config.count, 2)
        XCTAssertFalse(config.isEmpty)
        XCTAssertGreaterThanOrEqual(config.capacity, 2)

        // iterate
        var seen = 0
        for (_, _) in config { seen += 1 }
        XCTAssertEqual(seen, 2)

        // index navigation
        let index = config.startIndex
        XCTAssertNotEqual(index, config.endIndex)
        _ = config[config.index(after: index)]
        XCTAssertNotNil(config.index(forKey: .website))

        // roundtrip to dictionary
        let dictionary = Dictionary(config)
        XCTAssertEqual(dictionary.count, 2)
        XCTAssertEqual(dictionary[.website]?.rawValue, "https://example.com")
    }

    func testElementEntityInit() throws {
        let entities = [
            Configuration.ElementEntity(id: .website, value: "https://example.com"),
            Configuration.ElementEntity(id: .loginExpiration, value: .init(integer: 30))
        ]
        let config = Configuration(entities)
        XCTAssertEqual(config.count, 2)
        XCTAssertEqual(config[.website]?.rawValue, "https://example.com")

        // ElementEntity properties and Entity conformance
        let entity = entities[0]
        XCTAssertEqual(entity.id, .website)
        XCTAssertEqual(entity.value.rawValue, "https://example.com")
        XCTAssertFalse(Configuration.ElementEntity.attributes.isEmpty)
    }

    func testValueCodable() throws {
        XCTAssertJSONRoundTrip(Configuration.Value(rawValue: "test"))
        XCTAssertJSONRoundTrip(Configuration.Key(rawValue: "test"))
    }
}
