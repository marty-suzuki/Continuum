//
//  AnyKeyPath.extension.swift
//  Continuum
//
//  Created by marty-suzuki on 2018/02/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

extension AnyKeyPath {
    var notificationName: Notification.Name {
        let string = "\(type(of: self).rootType)-\(type(of: self).valueType)-\(hashValue)"
        return Notification.Name(string)
    }
}
