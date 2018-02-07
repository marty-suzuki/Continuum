//
//  Constant.swift
//  Continuum
//
//  Created by 鈴木大貴 on 2018/02/08.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

public final class Constant<Element>: ValueRepresentable, NotificationCenterSettable {
    public var value: Element {
        return _variable.value
    }

    public var uniqueName: Notification.Name {
        return _variable.uniqueName
    }

    private let _variable: Variable<E>

    public init(variable: Variable<E>) {
        self._variable = variable
    }

    func setCenter(_ center: NotificationCenter) {
        _variable.setCenter(center)
    }
}
