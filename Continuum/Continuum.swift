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
    /// Continuum extensions.
    public var continuum: NotificationCenterContinuum {
        return .init(center: self)
    }
}

/// Reresents typealias of NotificationCenterContinuum.Observer.
public typealias ContinuumObserver = NotificationCenterContinuum.Observer
/// Reresents typealias of NotificationCenterContinuum.Bag.
public typealias ContinuumBag = NotificationCenterContinuum.Bag

extension NotificationCenterContinuum {
    /// Reprisents Continuum Observer.
    public class Observer {
        private let rawObserver: NSObjectProtocol
        private let center: NotificationCenter
        private let mutex = PThreadMutex()

        /// Represents observation is cannceld or not.
        public private(set) var isCancelled: Bool = false

        fileprivate init(rawObserver: NSObjectProtocol, center: NotificationCenter) {
            self.rawObserver = rawObserver
            self.center = center
        }

        /// Cancel observation.
        public func cancel() {
            mutex.lock()
            center.removeObserver(rawObserver)
            isCancelled = true
            mutex.unlock()
        }

        /// Adds observer to a bag.
        ///
        /// - parameter bag: baguage for observer.
        public func disposed(by bag: Bag) {
            bag.add(self)
        }
    }

    /// Reprisents Bag for Observer.
    public class Bag {
        private var observers: [Observer] = []
        private let mutex = PThreadMutex()

        deinit {
            mutex.lock()
            observers.forEach { $0.cancel() }
            observers.removeAll()
            mutex.unlock()
        }

        /// Initialize
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
    /// Binds  property of source object to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter keyPath1: KeyPath for source.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath2: KeyPath for target.
    /// - returns: Observer that observes a object.
    public func observe<S: AnyObject, T: AnyObject, V>(_ source: S,
                                                       _ keyPath1: KeyPath<S, V>,
                                                       on queue: OperationQueue? = nil,
                                                       bindTo target: T,
                                                       _ keyPath2: ReferenceWritableKeyPath<T, V>) -> Observer {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    /// Binds  property of source object to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter keyPath1: KeyPath for source.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath2: KeyPath for target that comfirms Wrappable.
    /// - returns: Observer that observes a object.
    public func observe<S: AnyObject, V1, T: AnyObject, V2: Wrappable>(_ source: S,
                                                                       _ keyPath1: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ keyPath2: ReferenceWritableKeyPath<T, V2>) -> Observer where V1 == V2.Wrapped {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter keyPath1: KeyPath for source that confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath2: KeyPath for target.
    /// - returns: Observer that observes a object.
    public func observe<S: AnyObject, V1: Wrappable, T: AnyObject, V2>(_ source: S,
                                                                       _ keyPath1: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ keyPath2: ReferenceWritableKeyPath<T, V2>) -> Observer where V1.Wrapped == V2 {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter keyPath1: KeyPath for source that confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath2: KeyPath for target that confirms Wrappable.
    /// - returns: Observer that observes a object.
    public func observe<S: AnyObject, V1: Wrappable, T: AnyObject, V2: Wrappable>(_ source: S,
                                                                       _ keyPath1: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ keyPath2: ReferenceWritableKeyPath<T, V2>) -> Observer where V1.Wrapped == V2.Wrapped {
        return _observe(source, keyPath1, on: queue, bindTo: target, keyPath2)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter keyPath1: KeyPath for source that confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath2: KeyPath for target that is Optional.
    /// - returns: Observer that observes a object.
    public func observe<S: AnyObject, V1: Wrappable, T: AnyObject, V2>(_ source: S,
                                                                       _ sourceKeyPath: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ targetKeyPath: ReferenceWritableKeyPath<T, Optional<V2>>) -> Observer {
        let handler: () -> () = { [weak source, weak target] in
            guard let source = source, let target = target else { return }
            target[keyPath: targetKeyPath] = source[keyPath: sourceKeyPath] as? V2
        }

        handler()
        let observer = center.addObserver(forName: sourceKeyPath.notificationName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object that value confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath: KeyPath for target that is ImplicitlyUnwrappedOptional.
    /// - returns: Observer that observes a ValueRepresentable.
    public func observe<S: AnyObject, V1: Wrappable, T: AnyObject, V2>(_ source: S,
                                                                       _ sourceKeyPath: KeyPath<S, V1>,
                                                                       on queue: OperationQueue? = nil,
                                                                       bindTo target: T,
                                                                       _ targetKeyPath: ReferenceWritableKeyPath<T, ImplicitlyUnwrappedOptional<V2>>) -> Observer {
        let handler: () -> () = { [weak source, weak target] in
            guard let source = source, let target = target else { return }
            target[keyPath: targetKeyPath] = source[keyPath: sourceKeyPath] as? V2
        }

        handler()
        let observer = center.addObserver(forName: sourceKeyPath.notificationName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }

    private func _observe<S: AnyObject, V1, T: AnyObject, V2>(_ source: S,
                                                                _ sourceKeyPath: KeyPath<S, V1>,
                                                                on queue: OperationQueue? = nil,
                                                                bindTo target: T,
                                                                _ targetKeyPath: ReferenceWritableKeyPath<T, V2>) -> Observer {
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

extension NotificationCenterContinuum {
    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath: KeyPath for target.
    /// - returns: Observer that observes a object that confirms ValueRepresentable.
    public func observe<S: ValueRepresentable, T: AnyObject, V>(_ source: S,
                                                                on queue: OperationQueue? = nil,
                                                                bindTo target: T,
                                                                _ keyPath: ReferenceWritableKeyPath<T, V>) -> Observer where S.E == V {
        return _observe(source, on: queue, bindTo: target, keyPath)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter onValueChange: Value handler.
    /// - returns: Observer that observes a object that confirms ValueRepresentable.
    public func observe<S: ValueRepresentable, V>(_ source: S,
                                                  on queue: OperationQueue? = nil,
                                                  onValueChange: @escaping (V) -> ()) -> Observer where S.E == V {
        return _observe(source, on: queue, onValueChange: onValueChange)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath: KeyPath for target that confirms Wrappable.
    /// - returns: Observer that observes a ValueRepresentable.
    public func observe<S: ValueRepresentable, T: AnyObject, V: Wrappable>(_ source: S,
                                                                           on queue: OperationQueue? = nil,
                                                                           bindTo target: T,
                                                                           _ keyPath: ReferenceWritableKeyPath<T, V>) -> Observer where S.E == V.Wrapped {
        return _observe(source, on: queue, bindTo: target, keyPath)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object that value confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath: KeyPath for target that confirms Wrappable.
    /// - returns: Observer that observes a ValueRepresentable.
    public func observe<S: ValueRepresentable, T: AnyObject, V>(_ source: S,
                                                                on queue: OperationQueue? = nil,
                                                                bindTo target: T,
                                                                _ keyPath: ReferenceWritableKeyPath<T, V>) -> Observer where S.E: Wrappable, S.E.Wrapped == V {
        return _observe(source, on: queue, bindTo: target, keyPath)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object that value confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath: KeyPath for target that is Optional.
    /// - returns: Observer that observes a ValueRepresentable.
    public func observe<S: ValueRepresentable, T: AnyObject, V>(_ source: S,
                                                                on queue: OperationQueue? = nil,
                                                                bindTo target: T,
                                                                _ keyPath: ReferenceWritableKeyPath<T, Optional<V>>) -> Observer where S.E: Wrappable, S.E.Wrapped == V {
        let handler: () -> () = { [weak source, weak target] in
            guard let target = target, let source = source else { return }
            target[keyPath: keyPath] = source.value as? V
        }

        handler()
        (source as? NotificationCenterSettable)?.setCenter(center)
        let observer = center.addObserver(forName: source.uniqueName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }

    /// Binds source.value to property of target object.
    ///
    /// - parameter source: Observed object that value confirms Wrappable.
    /// - parameter queue: Binding execution qeueue.
    /// - parameter target: Binding target.
    /// - parameter keyPath: KeyPath for target that confirms Wrappable.
    /// - returns: Observer that observes a ValueRepresentable.
    public func observe<S: ValueRepresentable, T: AnyObject, V>(_ source: S,
                                                                on queue: OperationQueue? = nil,
                                                                bindTo target: T,
                                                                _ keyPath: ReferenceWritableKeyPath<T, ImplicitlyUnwrappedOptional<V>>) -> Observer where S.E: Wrappable, S.E.Wrapped == V {
        let handler: () -> () = { [weak source, weak target] in
            guard let target = target, let source = source else { return }
            target[keyPath: keyPath] = source.value as? V
        }

        handler()
        (source as? NotificationCenterSettable)?.setCenter(center)
        let observer = center.addObserver(forName: source.uniqueName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }

    private func _observe<S: ValueRepresentable, T: AnyObject, V>(_ source: S,
                                                                  on queue: OperationQueue? = nil,
                                                                  bindTo target: T,
                                                                  _ keyPath: ReferenceWritableKeyPath<T, V>) -> Observer {
        let handler: () -> () = { [weak source, weak target] in
            guard
                let target = target,
                let value = source?.value as? V
                else { return }
            target[keyPath: keyPath] = value
        }

        // FIXME: need to dispatch on given queue if it's non-nil and different from current queue.
        handler()

        (source as? NotificationCenterSettable)?.setCenter(center)
        let observer = center.addObserver(forName: source.uniqueName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }

    private func _observe<S: ValueRepresentable, V>(_ source: S,
                                                    on queue: OperationQueue? = nil,
                                                    onValueChange: @escaping (V) -> ()) -> Observer where S.E == V {
        let handler: () -> () = { [weak source] in
            guard let value = source?.value else { return }
            onValueChange(value)
        }

        if let _queue = queue, OperationQueue.current != _queue {
            // only dispatch async if given queue is different from current
            _queue.addOperation(handler)
        } else {
            handler()
        }

        (source as? NotificationCenterSettable)?.setCenter(center)
        let observer = center.addObserver(forName: source.uniqueName, object: nil, queue: queue) { _ in handler() }
        return Observer(rawObserver: observer, center: center)
    }

}
