//
//  Variable.swift
//  Continuum
//
//  Created by 鈴木大貴 on 2018/02/08.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

public protocol ValueRepresentable: class {
    associatedtype E
    var value: E { get }
    var uniqueName: Notification.Name { get }
}

protocol NotificationCenterSettable: class {
    func setCenter(_ center: NotificationCenter)
}

public final class Variable<Element>: ValueRepresentable, NotificationCenterSettable {
    public var value: Element {
        set {
            mutex.lock()
            _value = newValue
            mutex.unlock()
            center?.post(name: uniqueName, object: nil)
        }
        get {
            defer { mutex.unlock() }; mutex.lock()
            return _value
        }
    }

    public let uniqueName = Notification.Name("Continuum.\(UUID().uuidString)")

    private var _value: Element
    private let mutex = PThreadMutex()
    private var center: NotificationCenter?

    public init(value: Element) {
        self._value = value
    }

    func setCenter(_ center: NotificationCenter) {
        self.center = center
    }
}
