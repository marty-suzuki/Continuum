//
//  ContinuumTests.swift
//  ContinuumTests
//
//  Created by marty-suzuki on 2018/02/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Continuum

final class ContinuumTests: XCTestCase {

    func testBindingSameValueType() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingLeftValueTypeIsOptional() {
        class Dog {
            var bark: String? = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingRightValueTypeIsOptional() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound: String? = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingLeftValueTypeIsImplicitlyUnwrappedOptional() {
        class Dog {
            var bark: String! = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingRightValueTypeIsImplicitlyUnwrappedOptional() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound: String! = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testCancelObserving() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        let observer = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")

        observer.cancel()

        dog.bark = "Woof Woof"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testCancelObservingByDeinit() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        let dog = Dog()
        let cat = Cat()

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        var bag = ContinuumBag()
        center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)
            .disposed(by: bag)
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")

        bag = ContinuumBag()

        dog.bark = "Woof Woof"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testMultipleBinding() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        class Sheep {
            var sound = "Baa Baa"
        }

        let dog = Dog()
        let cat = Cat()
        let sheep = Sheep()

        XCTAssertEqual(cat.sound, "Meow")
        XCTAssertEqual(sheep.sound, "Baa Baa")

        let center = NotificationCenter()
        _ = center.continuum.observe(dog, \.bark, bindTo: cat, \.sound)
        _ = center.continuum.observe(dog, \.bark, bindTo: sheep, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")
        XCTAssertEqual(sheep.sound, "Bow wow")

        dog.bark = "Meow"
        center.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Meow")
        XCTAssertEqual(sheep.sound, "Meow")
    }

    func testMultipleNotificationCenter() {
        class Dog {
            var bark = "Bow wow"
        }

        class Cat {
            var sound = "Meow"
        }

        class Sheep {
            var sound = "Baa Baa"
        }

        let dog = Dog()
        let cat = Cat()
        let sheep = Sheep()

        XCTAssertEqual(cat.sound, "Meow")
        XCTAssertEqual(sheep.sound, "Baa Baa")

        let center1 = NotificationCenter()
        let center2 = NotificationCenter()
        _ = center1.continuum.observe(dog, \.bark, bindTo: cat, \.sound)
        _ = center2.continuum.observe(dog, \.bark, bindTo: sheep, \.sound)

        XCTAssertEqual(cat.sound, "Bow wow")
        XCTAssertEqual(sheep.sound, "Bow wow")

        dog.bark = "Woof Woof"

        center1.continuum.post(keyPath: \Dog.bark)

        XCTAssertEqual(cat.sound, "Woof Woof")
        XCTAssertEqual(sheep.sound, "Bow wow")
    }

    func testHoge() {
        
    }
}
