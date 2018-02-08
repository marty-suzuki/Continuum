//
//  VariableTests.swift
//  ContinuumTests
//
//  Created by marty-suzuki on 2018/02/08.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Continuum

final class VariableTests: XCTestCase {
    
    func testBindingWhenVariableToSameValueType() {
        class Cat {
            var sound = "Meow"
        }

        let barkOfDog = Variable(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsOptional() {
        class Cat {
            var sound = "Meow"
        }

        let barkOfDog = Variable<String?>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsNotOPtionalAndRightValueTypeIsOptional() {
        class Cat {
            var sound: String? = "Meow"
        }

        let barkOfDog = Variable<String>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsImplicitlyUnwrappedOptional() {
        class Cat {
            var sound = "Meow"
        }

        let barkOfDog = Variable<String!>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsNotIuoRightValueTypeIsIuo() {
        class Cat {
            var sound: String! = "Meow"
        }

        let barkOfDog = Variable<String>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsOptionalRightValueTypeIsIuo() {
        class Cat {
            var sound: String! = "Meow"
        }

        let barkOfDog = Variable<String?>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsIuolRightValueTypeIsOptional() {
        class Cat {
            var sound: String? = "Meow"
        }

        let barkOfDog = Variable<String!>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenVariableIsOptionalRightValueTypeIsIuoFinallyNil() {
        class Cat {
            var sound: String! = "Meow"
        }

        let barkOfDog = Variable<String?>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = nil

        XCTAssertNil(cat.sound)
    }

    func testBindingWhenVariableIsIuolRightValueTypeIsOptionalFinallyNil() {
        class Cat {
            var sound: String? = "Meow"
        }

        let barkOfDog = Variable<String!>(value: "Bow wow")
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        barkOfDog.value = nil

        XCTAssertNil(cat.sound)
    }
}
