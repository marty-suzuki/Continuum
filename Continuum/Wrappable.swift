//
//  Wrappable.swift
//  Continuum
//
//  Created by marty-suzuki on 2018/02/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

public protocol Wrappable {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: Wrappable {
    public var value: Wrapped? {
        return self
    }
}

extension ImplicitlyUnwrappedOptional: Wrappable {
    public var value: Wrapped? {
        return self
    }
}
