//
//  ConstantTests.swift
//  ContinuumTests
//
//  Created by marty-suzuki on 2018/02/08.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Continuum

final class ConstantTests: XCTestCase {
    
    func testBindingWhenConstantToSameValueType() {
        class Cat {
        var sound = "Meow"
        }

        let _barkOfDog = Variable(value: "Bow wow")
        let barkOfDog = Constant(variable: _barkOfDog)
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenConstantIsOptional() {
        class Cat {
            var sound = "Meow"
        }

        let _barkOfDog = Variable<String?>(value: "Bow wow")
        let barkOfDog = Constant<String?>(variable: _barkOfDog)
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenConstantIsNotOPtionalAndRightValueTypeIsOptional() {
        class Cat {
            var sound: String? = "Meow"
        }

        let _barkOfDog = Variable(value: "Bow wow")
        let barkOfDog = Constant(variable: _barkOfDog)
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWhenConstantIsOptionalRightValueTypeIsIuoFinallyNil() {
        class Cat {
            var sound: String! = "Meow"
        }

        let _barkOfDog = Variable<String?>(value: "Bow wow")
        let barkOfDog = Constant(variable: _barkOfDog)
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = nil

        XCTAssertNil(cat.sound)
    }

    func testBindingWhenConstantIsIuolRightValueTypeIsOptionalFinallyNil() {
        class Cat {
            var sound: String? = "Meow"
        }

        let _barkOfDog = Variable<String!>(value: "Bow wow")
        let barkOfDog = Constant(variable: _barkOfDog)
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = nil

        XCTAssertNil(cat.sound)
    }
}
