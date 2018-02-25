//
//  OnValueChangeClosureTests.swift
//  ContinuumTests
//
//  Created by Toshihiro Suzuki on 2018/02/25.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Continuum

final class OnValueChangeClosureTests: XCTestCase {
    private class Cat {
        var sound = "Meow"
    }

    private var _barkOfDog: Variable<String>!
    private var barkOfDog: Constant<String>!
    private var cat: Cat!

    override func setUp() {
        super.setUp()

        _barkOfDog = Variable(value: "Bow wow")
        barkOfDog = Constant(variable: _barkOfDog)
        cat = Cat()
    }

    func testBindingWithNoQueue() {

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, onValueChange: { [unowned self] barkOfDog in
            XCTAssertTrue(Thread.isMainThread)
            self.cat.sound = barkOfDog
        })

        // NOTE: No need to setup XCTestExpectation.
        //   Continuum is on main thread all the time in this case.

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWithMainQueue() {

        XCTAssertEqual(cat.sound, "Meow")

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, on: .main, onValueChange: { [unowned self] barkOfDog in
            XCTAssertTrue(Thread.isMainThread)
            self.cat.sound = barkOfDog
        })

        // NOTE: No need to setup XCTestExpectation.
        //   Continuum is on main thread all the time in this case, too.
        //   Because given queue `.main` is same as the current queue.

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = "Meow"

        XCTAssertEqual(cat.sound, "Meow")
    }

    func testBindingWithBackgroundQueue() {

        XCTAssertEqual(cat.sound, "Meow")

        let backgroundQueue = OperationQueue()

        // NOTE: We need to setup XCTestExpectation.
        //   Continuum dispatches onValueChanges handler call on given queue.
        let ex1 = expectation(description: "first expectation")
        let ex2 = expectation(description: "second expectation")
        var exs = [ex1, ex2]

        let center = NotificationCenter()
        _ = center.continuum.observe(barkOfDog, on: backgroundQueue, onValueChange: { [unowned self] barkOfDog in

            // Pretend as an expensive logic.
            usleep(200 * 1000) // 0.2 sec

            self.cat.sound = barkOfDog
            XCTAssertFalse(Thread.isMainThread)
            exs.removeFirst().fulfill()
        })

        wait(for: [ex1], timeout: 0.3)

        XCTAssertEqual(cat.sound, "Bow wow")

        _barkOfDog.value = "Meow"

        wait(for: [ex2], timeout: 0.3)

        XCTAssertEqual(cat.sound, "Meow")
    }
}
