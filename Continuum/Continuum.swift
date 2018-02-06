//
//  Continuum.swift
//  Continuum
//
//  Created by marty-suzuki on 2018/02/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

public struct NotificationCenterContinuum {
    fileprivate let center: NotificationCenter
}

extension NotificationCenter {
    public var continuum: NotificationCenterContinuum {
        return .init(center: self)
    }
}

public typealias ContinuumObserver = NotificationCenterContinuum.Observer
public typealias ContinuumBag = NotificationCenterContinuum.Bag

extension NotificationCenterContinuum {
    public class Observer {
        private let rawObserver: NSObjectProtocol
        private let center: NotificationCenter
        private let mutex = PThreadMutex()

        public private(set) var isCancelled: Bool = false

        fileprivate init(rawObserver: NSObjectProtocol, center: NotificationCenter) {
            self.rawObserver = rawObserver
            self.center = center
        }

        public func cancel() {
            mutex.lock()
            center.removeObserver(rawObserver)
            isCancelled = true
            mutex.unlock()
        }

        public func disposed(by bag: Bag) {
            bag.add(self)
        }
    }

    public class Bag {
        private var observers: [Observer] = []
        private let mutex = PThreadMutex()

        deinit {
            mutex.lock()
            observers.forEach { $0.cancel() }
            observers.removeAll()
            mutex.unlock()
        }

        public init() {}

        func add(_ observer: Observer) {
            mutex.lock()
            observers.append(observer)
            mutex.unlock()
        }
    }
}

extension NotificationCenterContinuum {
    public func post<O, V>(keyPath: KeyPath<O, V>) {
        center.post(name: keyPath.notificationName, object: nil)
    }
}

extension NotificationCenterContinuum {
    public func observe<S: AnyObject, T: AnyObject, V>(_ source: S,
                                                       _ keyPath1: KeyPath<S, V>,
                                                       on queue: OperationQueue? = nil,
                                                       bindTo target: T,
                                                       _ keyPath2: ReferenceWritableKeyPath<T, V>) -> Observer {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    public func observe<S: AnyObject, V1, T: AnyObject, V2: Wrappable>(_ source: S,
                                                                       _ keyPath1: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ keyPath2: ReferenceWritableKeyPath<T, V2>) -> Observer where V1 == V2.Wrapped {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    public func observe<S: AnyObject, V1: Wrappable, T: AnyObject, V2>(_ source: S,
                                                                       _ keyPath1: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ keyPath2: ReferenceWritableKeyPath<T, V2>) -> Observer where V1.Wrapped == V2 {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    private func _observe<O1: AnyObject, V1, O2: AnyObject, V2>(_ source: O1,
                                                                _ sourceKeyPath: KeyPath<O1, V1>,
                                                                on queue: OperationQueue? = nil,
                                                                bindTo target: O2,
                                                                _ targetKeyPath: ReferenceWritableKeyPath<O2, V2>) -> Observer {
        let handler: () -> () = { [weak source, weak target] in
            guard
                let source = source,
                let target = target,
                let value = source[keyPath: sourceKeyPath] as? V2
            else { return }
            target[keyPath: targetKeyPath] = value
        }

        handler()
        let observer = center.addObserver(forName: sourceKeyPath.notificationName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }
}
