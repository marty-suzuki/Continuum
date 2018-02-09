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

/// Variable is wrapper for value that has getter / setter.
public final class Variable<Element>: ValueRepresentable, NotificationCenterSettable {
    /// Gets or sets current value of variable.
    ///
    /// Whenever a new value is set, all the observers are notified of the change.
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

    /// Represents unique Notification.Name for each Variables.
    public let uniqueName = Notification.Name("Continuum.\(UUID().uuidString)")

    private var _value: Element
    private let mutex = PThreadMutex()
    private var center: NotificationCenter?

    /// Initializes Variable with initial value.
    ///
    /// - parameter value: Initial value.
    public init(value: Element) {
        self._value = value
    }

    func setCenter(_ center: NotificationCenter) {
        self.center = center
    }
}
